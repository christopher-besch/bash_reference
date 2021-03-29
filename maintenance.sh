#!/bin/bash
set -euo pipefail
IFS=$'\n\t'
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

############
# settings #
############

# original files
tasks_folder="${DIR}/tasks"
transcripts_folder="${DIR}/transcripts"
# sym links
sym_tasks_folder="${DIR}/sym/tsk"
transcripts_sym_folder="${DIR}/sym/pro"
# new tasks dump
new_tasks_folder="${DIR}/sym/nsk"
# what is a task folder?
task_pattern=".*/\\d\\d_\\d\\d_\\d\\d"

declare -A aliases
aliases[english]=eng
aliases[german]=ger
aliases[history]=his
aliases[math]=mat
aliases[sport]=spo
aliases[physics]=phy
aliases[politics]=wir
aliases[religion]=rel
aliases[seminar]=sem
aliases[spo]=run

function get_task_name() {
    read task_name
    if [[ -n $task_name ]]; then
        task_name="_$task_name"
    fi
    echo $task_name
}

function resolve_alias() {
    # is alias defined?
    for alias in "${!aliases[@]}"; do
        if [[ $alias == $1 ]]; then
            echo ${aliases[$alias]}
            return 0
        fi
    done
    echo $1
}

function revert_alias() {
    for alias in "${!aliases[@]}"; do
        if [[ ${aliases[$alias]} == $1 ]]; then
            echo $alias
            return 0
        fi
    done
    echo $1
}

function create_latest_sym() {
    subject_folder=$tasks_folder/$1
    subject=$(resolve_alias $1)

    # check if at least one task folder exists
    if [[ -z $(find "$subject_folder" -mindepth 1 -maxdepth 1 -type d | grep -P $task_pattern) ]]; then
        echo "Can't find most recent task for ${1}!" 1>&2
        exit 1
    fi

    # find most recent task
    task_path=$(find "$subject_folder" -mindepth 1 -maxdepth 1 -type d | grep -P $task_pattern | sort | tail -1)
    # create sym link
    ln -s $task_path "$sym_tasks_folder/$subject"
}

function create_sym() {
    task_path=$transcripts_folder/$1
    subject=$(resolve_alias $subject)

    ln -s $task_path "$transcripts_sym_folder/$subject"
}

###################
# parse arguments #
###################

optstring=":dh"
delete=0

while getopts $optstring arg; do
    case $arg in
    d)
        delete=1
        ;;
    h)
        # todo: help page is missing
        echo "help page is missing"
        exit 0
        ;;
    ?)
        echo "Invalid option: -$OPTARG" 1>&2
        exit 1
        ;;
    esac
done

########
# prep #
########

# create folders if not existent already
mkdir -p $sym_tasks_folder $transcripts_sym_folder $new_tasks_folder

# create empty folders for new tasks
for subject_folder in ${tasks_folder}/*; do
    subject=${subject_folder##*$'/'}
    subject=$(resolve_alias $subject)
    mkdir -p "$new_tasks_folder/$subject"
done

# delete old sym links
find $sym_tasks_folder $transcripts_sym_folder -mindepth 1 -maxdepth 1 -exec rm -r {} \;

#############################
# create and fill new tasks #
#############################

for subject_folder in $new_tasks_folder/*; do
    if [[ -d $subject_folder ]]; then
        subject=${subject_folder##*$'/'}
        reverted_subject=$(revert_alias $subject)
        new_task_folder_base="$tasks_folder/$reverted_subject/$(date +'%y_%m_%d')"

        # is folder filled?
        if [[ "$(ls -A $subject_folder)" ]]; then
            # get task name
            printf "input name for new $subject task: "
            task_name=$(get_task_name)
            new_task_folder=""
            new_task_folder="${new_task_folder_base}${task_name}"

            echo "creating and moving new task for $subject"
            mkdir -p $new_task_folder
            mv $new_tasks_folder/$subject/* $new_task_folder
        else
            # is folder requested?
            for requested_task in "$@"; do
                if [[ $(resolve_alias $requested_task) == $subject ]]; then
                    # get task name
                    printf "input name for new $subject task: "
                    task_name=$(get_task_name)
                    new_task_folder=""
                    new_task_folder="${new_task_folder_base}${task_name}"

                    echo "creating new empty task for $subject"
                    mkdir -p $new_task_folder
                    break
                fi
            done
        fi
    else
        echo "$subject_folder is not a directory"
    fi
done

#############################################
# find and delete empty folders if required #
#############################################

for folder in $(find "$DIR/tasks" "$DIR/transcripts" -mindepth 1 -type d | grep -P -v ".*/\..*"); do
    if [[ ! $(ls -A $folder) ]]; then
        if [[ $delete -ne 0 ]]; then
            echo "removing empty folder $folder"
            rm -r $folder
        else
            echo "$folder is empty"
        fi
    fi
done

#########################
# create task sym links #
#########################

# go through all subjects
for subject_folder in $tasks_folder/*; do
    subject=${subject_folder##*$'/'}
    if [[ -d $subject_folder ]]; then
        create_latest_sym $subject
    else
        echo "$subject_folder is not a directory"
    fi
done

###############################
# create transcript sym links #
###############################

for subject_folder in $transcripts_folder/*; do
    subject=${subject_folder##*$'/'}
    if [[ -d $subject_folder ]]; then
        create_sym $subject
    else
        echo "$subject_folder is not a directory"
    fi
done

echo "read $(find $tasks_folder -mindepth 2 -maxdepth 2 -type d | grep -P $task_pattern | wc -l) tasks"
