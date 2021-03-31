#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

silent 'Removed unnecessary packages' apt autoremove --yes --force-yes --allow-downgrades --allow-remove-essential --purge -qq
silent 'Cleaning up'                  apt autoclean

if ispkginstalled dkms
then
    dkmsinstall
fi

