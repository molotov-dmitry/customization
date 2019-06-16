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

### Network switcher ===========================================================

appinstall 'Git'                    'git'

pushd /tmp > /dev/null

silentsudo 'Cloning Network Switcher'   git clone 'https://github.com/molotov-dmitry/network-switch.git'

pushd network-switch > /dev/null

mkdir -p /usr/local/bin
silentsudo 'Install Network Switcher'   install network-switch.sh /usr/local/bin/network-switch

popd > /dev/null
popd > /dev/null
