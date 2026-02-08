#!/bin/bash -eu

set -eu

NAME=$1

if [ $# -ne 1 ]; then
    echo "Please set just 1 argument!" 1>&2
    exit 1
else
    zellij action rename-session "$NAME"
    guake --rename-current-tab="$NAME"
    exit 0
fi
