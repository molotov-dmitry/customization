#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

echo alias svndiff=\'svn --diff-cmd "colordiff" --extensions '"-y -W $(( $(tput cols) - 2 ))"' diff\' >> ~/.bash_aliases

clear
clear

