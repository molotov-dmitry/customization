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
appremove 'Elisa music player'      'elisa'
appremove 'MPD'                     'mpd'
appremove 'Shotwell'                'shotwell shotwell-common'
appremove 'Eye of Gnome'            'eog'
appremove 'Cheese'                  'cheese'

appremove 'Sound recorder'          'gnome-sound-recorder'
appremove 'Gnome TODO'              'gnome-todo'
appremove 'Gnome Weather'           'gnome-weather'
appremove 'Gnome Maps'              'gnome-maps'

appremove 'Gnome desktop icons'     'gnome-shell-extension-desktop-icons gnome-shell-extension-desktop-icons-ng'

appremove 'HexChat'                 'hexchat hexchat-common'
appremove 'Akregator'               'akregator'
appremove 'Konversation IRC client' 'konversation konversation-data'
appremove 'Tomboy'                  'tomboy'

appremove 'Unattended upgrades'     'unattended-upgrades'
appremove 'Ubuntu telemetry'        'ubuntu-report'

appremove 'Fonts (Bengali)'         'fonts-beng fonts-beng-extra fonts-lohit-beng-assamese fonts-lohit-beng-bengali'
appremove 'Fonts (Devanagari)'      'fonts-deva fonts-gargi fonts-lohit-deva fonts-nakula fonts-sahadeva fonts-samyak-deva'
appremove 'Fonts (Gujarati)'        'fonts-gujr fonts-gujr-extra fonts-kalapi fonts-lohit-gujr fonts-samyak-gujr'
appremove 'Fonts (Punjabi)'         'fonts-guru fonts-guru-extra fonts-lohit-guru'
appremove 'Fonts (Kannada)'         'fonts-knda fonts-gubbi fonts-lohit-knda fonts-navilu'
appremove 'Fonts (Malayalam)'       'fonts-mlym fonts-lohit-mlym fonts-samyak-mlym fonts-smc'
appremove 'Fonts (Oriya)'           'fonts-orya fonts-lohit-orya fonts-orya-extra'
appremove 'Fonts (Tamil)'           'fonts-taml fonts-lohit-taml fonts-samyak-taml fonts-lohit-taml-classical'
appremove 'Fonts (Telugu)'          'fonts-telu fonts-lohit-telu fonts-lohit-telu'
appremove 'Fonts (Sourashtra)'      'fonts-pagul'
appremove 'Fonts (Indic)'           'fonts-indic'

appremove 'Fonts (KACST)'           'fonts-kacst fonts-kacst-one'
appremove 'Fonts (Cambodia)'        'fonts-khmeros-core'
appremove 'Fonts (Lao)'             'fonts-lao'
appremove 'Fonts (Sinhala)'         'fonts-lklug-sinhala'
appremove 'Fonts (Noto Extra)'      'fonts-noto-cjk fonts-noto-cjk-extra fonts-noto-unhinted'
appremove 'Fonts (Ethiopic)'        'fonts-sil-abyssinica'
appremove 'Fonts (Burmese)'         'fonts-sil-padauk'
appremove 'Fonts (Tibetan)'         'fonts-tibetan-machine'
appremove 'Fonts (Thai)'            'fonts-thai-tlwg fonts-tlwg-garuda fonts-tlwg-garuda-ttf fonts-tlwg-kinnari fonts-tlwg-kinnari-ttf fonts-tlwg-laksaman fonts-tlwg-laksaman-ttf fonts-tlwg-loma fonts-tlwg-loma-ttf fonts-tlwg-mono fonts-tlwg-mono-ttf fonts-tlwg-norasi fonts-tlwg-norasi-ttf fonts-tlwg-purisa fonts-tlwg-purisa-ttf fonts-tlwg-sawasdee fonts-tlwg-sawasdee-ttf fonts-tlwg-typewriter fonts-tlwg-typewriter-ttf fonts-tlwg-typist fonts-tlwg-typist-ttf fonts-tlwg-typo fonts-tlwg-typo-ttf fonts-tlwg-umpush fonts-tlwg-umpush-ttf fonts-tlwg-waree fonts-tlwg-waree-ttf'
appremove 'Fonts (Droid)'           'fonts-droid-fallback'
appremove 'Fonts (Libertine)'       'fonts-linuxlibertine'
appremove 'Fonts (Freefont)'        'fonts-freefont-ttf'
appremove 'Fonts (Liberation)'      'fonts-liberation2'

## Remove unused ---------------------------------------------------------------

silent 'Removing unused packages' apt autoremove --yes --force-yes --purge
