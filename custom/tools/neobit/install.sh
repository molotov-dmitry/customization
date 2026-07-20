#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

### Chromium/Chrome ============================================================

if [[ "$(lsb_release -si)" != "Ubuntu" ]]
then
    appinstall 'Chromium'           'chromium chromium-l10n libnss3-tools'
else
    appinstall 'Google Chrome'      'google-chrome-stable libnss3-tools'
fi

if ispkginstalled gnome-shell
then
    appinstall 'Gnome browser integration' 'gnome-browser-connector'
fi

if kdebased
then
    appinstall 'KDE browser integration' 'plasma-browser-integration'
fi

### Cool Retro Term ============================================================

if kdebased
then
    appinstall 'Cool Retro Term'    'cool-retro-term'
fi

### GOST hash ==================================================================

appinstall 'GOST hashes'            'gostsum'
appinstall 'CtrlSum'                'ctrlsum'
appinstall 'GetCRC'                 'getcrc'

### CD burning =================================================================

appinstall 'Xorriso'                'xorriso'

## Web services ================================================================

if havegraphics
then
    appinstall 'SPICE client'       'virt-viewer'
fi

### Mail clients ===============================================================

if gnomebased
then
    appinstall 'Evolution mail client'  'evolution evolution-data-server evolution-ews evolution-plugins'
fi

if kdebased
then
    appinstall 'KDE PIM'                'kmail kontact korganizer kaddressbook accountwizard'

    if ispkginstalled 'akonadi-backend-mysql'
    then
        appinstall 'Akonadi SQLite backend' 'akonadi-backend-sqlite'
        appremove 'Akonadi MySQL backend' 'akonadi-backend-mysql'
    fi
fi

## Chat clients ================================================================

if gnomebased
then
    appinstall 'Gajim'  'gajim'
    appinstall 'Dino'   'dino-im'
    appinstall 'Pidgin' 'pidgin [pidgin-indicator] [libcanberra-gtk-module] [libgail-common] [appmenu-gtk2-module]'
fi

if kdebased
then
    appinstall 'Kaidan' 'kaidan'
fi

## Sublime =====================================================================

appinstall 'Sublime Text'   'sublime-text'
appinstall 'Sublime Merge'  'sublime-merge'

## VS Code =====================================================================

appinstall 'VS Code'        'code'

## VirtualBox ==================================================================

appinstall 'VirtualBox'     'virtualbox-7.2'

## APT offline =================================================================

appinstall 'APT offline'    'apt-offline'
