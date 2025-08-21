#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

if [[ "$(lsb_release -si)" == "Debian" ]] && ispkginstalled dkms
then
    DEBIAN_FRONTEND=noninteractive silent 'Installing Linux kernel headers' apt install --yes --force-yes --allow-downgrades --allow-remove-essential -qq 'linux-headers-generic'
fi

### GNOME/GTK2 theme for Qt5/Qt6 applications ==================================

if gnomebased
then

    if ispkginstalled custom-config-qt-gtk2-theme
    then
        if ispkginstalled libqt5widgets5 || ispkginstalled libqt5widgets5t64
        then
            appinstall 'GTK2 style for Qt5'     'qt5-gtk2-platformtheme'
        fi

        if ispkginstalled libqt6widgets6 || ispkginstalled libqt6widgets6t64
        then
            appinstall 'GTK2 style for Qt6'     'qt6gtk2'
        fi
    fi

    if ispkginstalled custom-config-qt-gnome-theme
    then
        if ispkginstalled libqt5widgets5 || ispkginstalled libqt5widgets5t64
        then
            appinstall 'GNOME style for Qt5'    'xdg-desktop-portal-gnome qgnomeplatform-qt5 libadwaitaqt1 adwaita-qt'
        fi

        if ispkginstalled libqt6widgets6 || ispkginstalled libqt6widgets6t64
        then
            appinstall 'GNOME style for Qt6'    'xdg-desktop-portal-gnome qgnomeplatform-qt6 libadwaitaqt6-1 adwaita-qt6'
        fi
    fi
fi

### ============================================================================

DEBIAN_FRONTEND=noninteractive silent 'Remove unnecessary packages' apt autoremove --yes --force-yes --allow-downgrades --allow-remove-essential --purge -qq
DEBIAN_FRONTEND=noninteractive silent 'Cleaning up'                 apt autoclean

if ispkginstalled dkms
then
    dkmsinstall
fi

