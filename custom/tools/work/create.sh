#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

### CD burning =================================================================

appinstall 'Xorriso'                'xorriso'

### Wi-Fi driver ===============================================================

appinstall 'DKMS'                   'dkms [linux-headers-generic]'
appinstall 'Git'                    'git'
silent 'Cloning wi-fi driver'       git clone --depth 1 'https://github.com/gordboy/rtl8812au.git' /usr/src/rtl8812au-5.2.20

### Report builder =============================================================

appinstall 'Git'                    'git'
appinstall 'Build tools'            'g++ qtbase5-dev'

pushd /tmp > /dev/null

silent 'Cloning Work Report'        git clone --depth 1 'https://github.com/molotov-dmitry/work-report.git'

pushd work-report > /dev/null

silent 'Prepare Work Report'        qmake -qt=qt5 work-report.pro
silent 'Build Work Report'          make -j $(nproc)
silent 'Install Work Report'        bash install.sh

popd > /dev/null
popd > /dev/null

rm -rf /tmp/work-report

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
