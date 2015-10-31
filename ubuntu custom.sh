#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

sudo echo -n

clear
clear

### Test internet connection ===================================================

title 'testing internet connection'

if conntest
then
    msgdone
else
    msgfail
    exit 1
fi

### Applications ===============================================================

## Remove ----------------------------------------------------------------------

appremove 'Brasero'                 'brasero brasero-cdrkit brasero-common'

appremove 'Simple Scanning Utility' 'simple-scan'
appremove 'LibreOffice unused apps' 'libreoffice-draw libreoffice-impress libreoffice-math'
#appremove 'Games'                   'gnome-mines gnome-sudoku gnome-mahjongg aisleriot'
appremove 'Firefox Extensions'      'xul-ext-ubufox xul-ext-unity xul-ext-webaccounts xul-ext-websites-integration'
#appremove 'Remote desktop client'   'remmina remmina-common remmina-plugin-rdp remmina-plugin-vnc'
appremove 'Unity web browser'       'webbrowser-app'
appremove 'Thunderbird mail client' 'thunderbird'
appremove 'Onboard'                 'onboard'
appremove 'Fcitx'                   'fcitx fcitx-bin fcitx-config-common fcitx-data fcitx-modules fcitx-frontend-all'
appremove 'Orca screen reader'      'gnome-orca'
appremove 'X Diagnostic utility'    'xdiagnose'
appremove 'Backup utility'          'deja-dup'
appremove 'Help'                    'yelp yelp-xsl gnome-user-guide ubuntu-docs'
appremove 'Font viewer'             'gnome-font-viewer'
appremove 'Symbols table'           'gucharmap'
#appremove 'xterm'                   'xterm'
appremove 'Landscape'               'landscape-client-ui-install'
appremove 'Evolution'               'evolution evolution-common evolution-plugins'
appremove 'Dconf editor'            'dconf-editor'
appremove 'Empathy'                 'empathy empathy-common'
appremove 'Web camera'              'cheese'
appremove 'Gnome applications'      'gnome-contacts gnome-weather gnome-documents gnome-maps'
appremove 'Transmission'            'transmission-common transmission-gtk'
appremove 'Rhythmbox'               'rhythmbox thythmbox-data rhythmbox-plugins'
appremove 'Shotwell'                'shotwell shotwell-common'
appremove 'Video'                   'totem totem-common totem-mozilla totem-plugins'

### Enabling 'universe' and 'multiverse' package sources -----------------------

silentsudo 'Enabling universe source' add-apt-repository universe
silentsudo 'Enabling multiverse source' add-apt-repository multiverse

## Adding PPA`s ----------------------------------------------------------------

ppaadd  'Numix Project'             'numix'
ppaadd  'LibreOffice'               'libreoffice'
ppaadd  'Elementary OS'             'elementary-os'             'daily'

## Updating --------------------------------------------------------------------

appupdate
appupgrade

## Install ---------------------------------------------------------------------

appinstall 'Chromium'               'chromium-browser chromium-browser-l10n'

appinstall 'VCS'                    'git subversion'

if ispkginstalled nautilus
then
    appinstall 'RabbitVCS'          'rabbitvcs-core rabbitvcs-nautilus'
fi

appinstall 'Numix theme'            'numix-icon-theme-circle numix-gtk-theme numix-plymouth-theme'
appinstall 'Oxygen cursors'         'oxygen-cursor-theme oxygen-cursor-theme-extra'
appinstall 'Breeze cursors'         'breeze-cursor-theme'
appinstall 'Libreoffice icons'      'libreoffice-style-sifr'
appinstall 'Elementary theme'       'elementary-icon-theme elementary-theme elementary-wallpapers'

appinstall 'ibus-gtk'               'ibus-gtk'

appinstall 'Droid fonts'            'fonts-droid'

appinstall 'Postgres'               'postgresql pgadmin3 libpq5 libpq-dev'
appinstall 'SQLite'                 'sqlite sqliteman libsqlite3-0 libsqlite3-dev'

appinstall 'Build tools'            'build-essential astyle'
appinstall 'Qt SDK'                 'qml qtbase5-dev qtdeclarative5-dev qtcreator'

appinstall 'Doxygen'                'doxygen'

appinstall 'FTP server'             'vsftpd'
appinstall 'CIFS utils'             'cifs-utils'
appinstall '7-zip'                  'p7zip-rar p7zip-full'

appinstall 'VMWare tools'           'open-vm-tools open-vm-tools-desktop fuse open-vm-tools-dkms xauth xserver-xorg-input-vmmouse xserver-xorg-video-vmware xdg-utils'

## Remove unused ---------------------------------------------------------------

silentsudo 'Removing unused packages' apt-get autoremove --yes --force-yes --purge


