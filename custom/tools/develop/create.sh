#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

### Network switcher ===========================================================

gitinstall 'Network Switcher'       'https://github.com/molotov-dmitry/network-switch.git' make

### LDAP user configuration script =============================================

appinstall 'LDAP utilities'         'ldap-utils'
gitinstall 'LDAP user config'       'https://github.com/molotov-dmitry/work-user-ldap-config.git' make

