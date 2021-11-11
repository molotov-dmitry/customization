#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

appinstall 'Notify server' 'notify-server'

gnomeshellextension 1319 'GSConnect' '' 'gnome-shell-extension-gsconnect'
