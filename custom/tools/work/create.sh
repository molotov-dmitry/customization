#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

### ============================================================================

appinstall 'RDP server' 'vino'

if [[ "$(lsb_release -si) $(lsb_release -sc)" == 'Debian stretch' ]]
then
    appinstall 'RDP client' 'vinagre'
else
    appinstall 'RDP client' 'remmina remmina-plugin-vnc remmina-plugin-rdp'
fi
