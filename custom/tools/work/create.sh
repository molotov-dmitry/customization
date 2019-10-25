#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

### CD burning =================================================================

appinstall 'Xorriso'                'xorriso'

### Wi-Fi driver ===============================================================

appinstall 'DKMS'                   'dkms [linux-headers-generic]'
appinstall 'Git'                    'git'
silent     'Cloning wi-fi driver'   git clone --depth 1 'https://github.com/gordboy/rtl8812au.git' /usr/src/rtl8812au-5.2.20

### Report builder =============================================================

gitinstall 'Work report'            'https://github.com/molotov-dmitry/work-report.git' qt5

### Network switcher ===========================================================

gitinstall 'Network Switcher'       'https://github.com/molotov-dmitry/network-switch.git' make

### LDAP user configuration script =============================================

appinstall 'LDAP utilities'         'ldap-utils'
gitinstall 'LDAP user config'       'https://github.com/molotov-dmitry/work-user-ldap-config.git' make
