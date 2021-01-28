#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

for file in anime/anime/episodes/*; do
    if [[ -n $(cat $file) ]]; then
        echo $file
    fi
done
