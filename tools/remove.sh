#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

### Applications ===============================================================

## Remove ----------------------------------------------------------------------

appremove 'Apt listchanges'         'apt-listchanges'

appremove 'Brasero'                 'brasero brasero-cdrkit brasero-common'

appremove 'Simple Scanning Utility' 'simple-scan'
appremove 'LibreOffice unused apps' 'libreoffice-draw libreoffice-impress libreoffice-math'
appremove 'Games'                   'gnome-mines gnome-sudoku gnome-mahjongg aisleriot gnome-klotski gnome-chess five-or-more four-in-a-row gnome-nibbles hitori iagno lightsoff quadrapassel gnome-robots swell-foop tali gnome-taquin gnome-tetravex'
appremove 'Firefox Extensions'      'xul-ext-ubufox xul-ext-unity xul-ext-webaccounts xul-ext-websites-integration'
appremove 'Remote desktop client'   'remmina remmina-common remmina-plugin-rdp remmina-plugin-vnc'
appremove 'Unity web browser'       'webbrowser-app'
appremove 'Thunderbird mail client' 'thunderbird'
appremove 'Onboard'                 'onboard'
appremove 'Fcitx'                   'fcitx fcitx-bin fcitx-config-common fcitx-data fcitx-modules fcitx-frontend-all'
appremove 'Mozc'                    'mozc-utils-gui'
appremove 'Anthy'                   'anthy anthy-common'
appremove 'Goldendict'              'goldendict'
appremove 'Orca screen reader'      'gnome-orca'
appremove 'X Diagnostic utility'    'xdiagnose'
appremove 'Backup utility'          'deja-dup'
appremove 'Help'                    'yelp yelp-xsl gnome-user-guide ubuntu-docs'
appremove 'Font viewer'             'gnome-font-viewer'
appremove 'Symbols table'           'gucharmap'
appremove 'Terminals'               'xterm mlterm mlterm-common mlterm-tools'
appremove 'Landscape'               'landscape-client-ui-install'
appremove 'Dconf editor'            'dconf-editor'
appremove 'Transmission'            'transmission-common transmission-gtk'
appremove 'Gnome Music'             'gnome-music'
appremove 'AppArmor'                'apparmor apparmor-utils'
appremove 'Apport'                  'apport apport-gtk'
appremove 'Ubuntu web launchers'    'ubuntu-web-launchers'

appremove 'Rhythmbox'               'rhythmbox rhythmbox-data'
appremove 'Totem'                   'totem totem-common'
appremove 'Shotwell'                'shotwell shotwell-common'
appremove 'Cheese'                  'cheese'
appremove 'Gnome TODO'              'gnome-todo'

appremove 'HexChat'                 'hexchat hexchat-common'
appremove 'Tomboy'                  'tomboy'

appremove 'Unattended upgrades'     'unattended-upgrades'

## Remove unused ---------------------------------------------------------------

silent 'Removing unused packages' apt-get autoremove --yes --force-yes --purge
