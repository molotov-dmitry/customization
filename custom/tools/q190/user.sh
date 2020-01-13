#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

## Set first created user as work account ======================================

if [[ $UID -eq 1000 ]]
then
    mkdir -p "${HOME}/.config"
    touch    "${HOME}/.config/is-work-account"
fi

### Add network switch =========================================================

if ispkginstalled network-switch
then
    if [[ -f "${HOME}/.config/is-work-account" ]]
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

if [[ ! -f "${HOME}/.config/is-work-account" ]]
then
    mkdir -p "${HOME}/.config/user-ldap-config"
    echo "autostart=false" > "${HOME}/.config/user-ldap-config/setup-done"
fi

## Hide unused applications ----------------------------------------------------

if [[ -f "${HOME}/.config/is-work-account" ]]
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
    hideapp 'shotwell'
    hideapp 'shotwell-viewer'
else
    hideapp 'org.gnome.Evolution'
    hideapp 'local.rczifort.ex01'
    hideapp 'local.rczifort.git'
    hideapp 'local.rczifort.redmine'
    hideapp 'local.rczifort.ex01-gnome'
    hideapp 'local.rczifort.git-gnome'
    hideapp 'local.rczifort.redmine-gnome'
fi
