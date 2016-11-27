#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

clear

### Test internet connection ===================================================

title 'Testing internet connection'

if conntest
then
    msgdone
else
    msgfail
    exit 1
fi

### Applications ===============================================================

## Remove ----------------------------------------------------------------------

appremove 'Apt listchanges'         'apt-listchanges'

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
appremove 'xterm'                   'xterm'
appremove 'Landscape'               'landscape-client-ui-install'
appremove 'Evolution'               'evolution evolution-common evolution-plugins'
appremove 'Dconf editor'            'dconf-editor'
appremove 'Empathy'                 'empathy empathy-common'
appremove 'Web camera'              'cheese'
appremove 'Gnome applications'      'gnome-contacts gnome-weather gnome-documents gnome-maps'
appremove 'Transmission'            'transmission-common transmission-gtk'
appremove 'Rhythmbox'               'rhythmbox rhythmbox-data'
appremove 'Totem'                   'totem totem-common'
appremove 'GNOME Music'             'gnome-music'
appremove 'GNOME Calendar'          'gnome-calendar'
appremove 'USB creator'             'usb-creator-gtk usb-creator-common'
appremove 'AppArmor'                'apparmor apparmor-utils'

## Remove unused ---------------------------------------------------------------

silentsudo 'Removing unused packages' apt-get autoremove --yes --force-yes --purge

## Enable all package sources --------------------------------------------------

repoaddnonfree

## Add PPA`s -------------------------------------------------------------------

ppaadd  'Numix Project'             'numix'
ppaadd  'Paper Themes (Daily)'      'snwh' 'pulp' 'xenial'
ppaadd  'LibreOffice'               'libreoffice'

## Update ----------------------------------------------------------------------

appupdate
appupgrade

## Install ---------------------------------------------------------------------

## Gnome - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

bundle install 'gnome'
bundle install 'qt'

## Themes  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

bundle install 'appearance'

### VCS  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

bundle install 'vcs'

## Development - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

bundle install 'dev'

## Office  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

bundle install 'office'

## Graphic - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

bundle install 'graphics'

## Other - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

bundle install 'archive'
bundle install 'cli/files'

bundle install 'server/ssh'
bundle install 'server/ftp'
bundle install 'server/svn'
bundle install 'server/iperf'

## VMWare tools  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

bundle install 'vm'


