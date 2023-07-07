#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

if [[ "$(lsb_release -si)" == "Debian" ]] && ispkginstalled dkms
then
    DEBIAN_FRONTEND=noninteractive silent 'Installing Linux kernel headers' apt install --yes --force-yes --allow-downgrades --allow-remove-essential -qq 'linux-headers-generic'
fi

DEBIAN_FRONTEND=noninteractive silent 'Remove unnecessary packages' apt autoremove --yes --force-yes --allow-downgrades --allow-remove-essential --purge -qq
DEBIAN_FRONTEND=noninteractive silent 'Cleaning up'                 apt autoclean

if ispkginstalled dkms
then
    dkmsinstall
fi

