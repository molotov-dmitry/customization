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
    appinstall 'RDP client' 'remmina remmina-plugin-vnc remmina-plugin-rdp remmina-plugin-xdmcp'
fi

### Network switcher ===========================================================

appinstall 'Git'                    'git'

pushd /tmp > /dev/null

silent 'Cloning Network Switcher'   git clone --depth 1 'https://github.com/molotov-dmitry/network-switch.git'

pushd network-switch > /dev/null

mkdir -p /usr/local/bin
silent 'Install Network Switcher'   install network-switch.sh /usr/local/bin/network-switch

popd > /dev/null
popd > /dev/null

rm -rf /tmp/network-switch

### LDAP user configuration script =============================================

appinstall 'LDAP utilities'         'ldap-utils'

appinstall 'Git'                    'git'

silent 'Cloning LDAP user config'   git clone --depth 1 'https://github.com/molotov-dmitry/work-user-ldap-config.git' /tmp/work-user-ldap-config
silent 'Install LDAP user config'   make -C /tmp/work-user-ldap-config install desktop-skel

rm -rf /tmp/work-user-ldap-config
