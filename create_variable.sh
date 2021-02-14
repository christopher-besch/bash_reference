#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

t="Test"

# doesn't change t
echo ${t:="Hi"}
echo $t

# create x and set value
echo ${x:="Hi"}
echo $x
