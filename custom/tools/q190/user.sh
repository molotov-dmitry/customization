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

## Disable LDAP user configuration for non-RCZI users --------------------------

if [[ $UID -ne 1000 ]]
then
    mkdir -p "${HOME}/.config/user-ldap-config"
    echo "autostart=false" > "${HOME}/.config/user-ldap-config/setup-done"
fi

## Hide unused applications ----------------------------------------------------

if [[ $UID -eq 1000 ]]
then
    hideapp 'org.gnome.Geary'
    hideapp 'io.github.GnomeMpv'
    hideapp 'io.github.TransmissionRemoteGtk'
    hideapp 'mpv'
    hideapp 'org.gnome.Maps'
    hideapp 'org.gnome.Totem'
    hideapp 'org.gnome.Weather'
    hideapp 'rhythmbox'
    hideapp 'telegramdesktop'
else
    hideapp 'org.gnome.Evolution'
    hideapp 'local.rczifort.ex01'
    hideapp 'local.rczifort.git'
    hideapp 'local.rczifort.redmine'
fi
