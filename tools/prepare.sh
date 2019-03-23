#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

### Applications ===============================================================

## Update all packages ---------------------------------------------------------

appupdate

## Install additional packages -------------------------------------------------

appinstall 'Dir manager'            'dirmngr'

appinstall 'LSB release'            'lsb-release'
appinstall 'Base'                   'less mount grep sed wget'
appinstall 'Bash completion'        'bash-completion'

silent     'Fix sudo install'       apt-mark manual sudo

### Configuration ==============================================================

silent      'Disable lid close suspend' sed -i 's/[#]\?[[:blank:]]*HandleLidSwitch\([[:blank:]]*\)=\([[:blank:]]*\).*/HandleLidSwitch\1=\2ignore/' /etc/systemd/logind.conf

### Allow ping to be executed by any user ======================================

silent      'Set ping capabilities'     setcap cap_net_raw+ep $(which ping)
