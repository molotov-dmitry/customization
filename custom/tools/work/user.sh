#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

## Set any user as work account ================================================

mkdir -p "${HOME}/.config"
touch    "${HOME}/.config/is-work-account"

### Add network switch =========================================================

if ispkginstalled network-switch
then
    nettype=eth

    mkdir -p "${HOME}/.config/autostart"

    cat > "${HOME}/.config/autostart/network-switch.desktop" << _EOF
[Desktop Entry]
Version=1.0
Name=Network switcher
Comment=Network switcher
Exec=network-switch ${nettype}
Terminal=false
Type=Application
Categories=Network
_EOF

    unset nettype
fi

## Clear launcher ==============================================================

launcherclear
