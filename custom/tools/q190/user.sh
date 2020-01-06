#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

### Add network switch =========================================================

if ispkginstalled network-switch
then
    if [[ $UID -eq 1000 ]]
    then
        nettype=eth
    else
        nettype=wifi
    fi

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

### Customization ==============================================================

## Clear launcher --------------------------------------------------------------

launcherclear

## Add mail client -------------------------------------------------------------

if [[ $UID -eq 1000 ]]
then
    launcheradd 'org.gnome.Evolution'
else
    launcheradd 'org.gnome.Geary.desktop'
fi
