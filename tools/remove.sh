#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

### Applications ===============================================================

## Remove ----------------------------------------------------------------------

appremove 'OEM kernel headers'      'linux-headers-oem linux-headers-4.15.0-1050-oem linux-oem-headers-4.15.0-1050'

appremove 'Apt listchanges'         'apt-listchanges'

appremove 'Brasero'                 'brasero brasero-cdrkit brasero-common'
appremove 'K3b'                     'k3b k3b-data'

appremove 'Scanning Utilities'      'simple-scan skanlite'
appremove 'LibreOffice unused apps' 'libreoffice-draw libreoffice-impress libreoffice-math'
appremove 'Games'                   'gnome-mines gnome-sudoku gnome-mahjongg aisleriot gnome-klotski gnome-chess five-or-more four-in-a-row gnome-nibbles hitori iagno lightsoff quadrapassel gnome-robots swell-foop tali gnome-taquin gnome-tetravex kpat ksudoku kmahjongg kmines'
appremove 'Firefox Extensions'      'xul-ext-ubufox xul-ext-unity xul-ext-webaccounts xul-ext-websites-integration'
appremove 'Remote desktop client'   'remmina remmina-common remmina-plugin-rdp remmina-plugin-vnc'
appremove 'Unity web browser'       'webbrowser-app'
appremove 'Thunderbird mail client' 'thunderbird'
appremove 'KDE PIM'                 'kmail kontact korganizer ktnef kaddressbook knotes'
appremove 'Onboard'                 'onboard'
appremove 'Fcitx'                   'fcitx fcitx-bin fcitx-config-common fcitx-data fcitx-modules fcitx-frontend-all'
appremove 'Mozc'                    'mozc-utils-gui'
appremove 'Anthy'                   'anthy anthy-common'
appremove 'Orca screen reader'      'gnome-orca'
appremove 'X Diagnostic utility'    'xdiagnose'
appremove 'Backup utility'          'deja-dup'
appremove 'Help'                    'yelp yelp-xsl gnome-user-guide ubuntu-docs'
appremove 'Debian references'       'debian-reference-common'
appremove 'Goldendict'              'goldendict'
appremove 'Khmer converter'         'khmerconverter'
appremove 'Hebrew calendar applet'  'hdate-applet'
appremove 'Font viewer'             'gnome-font-viewer'
appremove 'Symbols table'           'gucharmap'
appremove 'Terminals'               'xterm xiterm+thai mlterm mlterm-common mlterm-tools'
appremove 'Landscape'               'landscape-client-ui-install'
appremove 'Dconf editor'            'dconf-editor'
appremove 'Transmission'            'transmission-common transmission-gtk'
appremove 'KTorrent'                'ktorrent ktorrent-data'

appremove 'AppArmor'                'apparmor apparmor-utils'
appremove 'Apport'                  'apport apport-gtk'

appremove 'Ubuntu web launchers'    'ubuntu-web-launchers'

appremove 'Rhythmbox'               'rhythmbox rhythmbox-data'
appremove 'Gnome Music'             'gnome-music'
appremove 'Totem'                   'totem totem-common'
appremove 'VLC'                     'vlc vlc-bin vlc-data'
appremove 'Cantata music player'    'cantata'
appremove 'MPD'                     'mpd'
appremove 'Shotwell'                'shotwell shotwell-common'
appremove 'Cheese'                  'cheese'

appremove 'Sound recorder'          'gnome-sound-recorder'
appremove 'Gnome TODO'              'gnome-todo'
appremove 'Gnome Weather'           'gnome-weather'
appremove 'Gnome Maps'              'gnome-maps'

appremove 'HexChat'                 'hexchat hexchat-common'
appremove 'Akregator'               'akregator'
appremove 'Konversation IRC client' 'konversation konversation-data'
appremove 'Tomboy'                  'tomboy'

appremove 'Unattended upgrades'     'unattended-upgrades'

## Remove unused ---------------------------------------------------------------

silent 'Removing unused packages' apt autoremove --yes --force-yes --purge
