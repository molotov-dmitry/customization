#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

### Network switcher ===========================================================

gitinstall 'Network Switcher'       'https://github.com/molotov-dmitry/network-switch.git' make
