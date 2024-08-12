#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

if [[ "$(lsb_release -si)" == "Ubuntu" ]]
then
    repoadd 'Google Chrome' 'http://dl.google.com/linux/chrome/deb/' 'stable' 'main' 'google-chrome.gpg' 'arch=amd64'

    mkdir -p "/etc/default"

    echo 'repo_add_once="false"'                >  "/etc/default/google-chrome"
    echo 'repo_reenable_on_distupgrade="false"' >> "/etc/default/google-chrome"
fi
