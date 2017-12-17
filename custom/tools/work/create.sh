#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

sudo echo -n

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
appremove 'Games'                   'gnome-mines gnome-sudoku gnome-mahjongg aisleriot'
appremove 'Firefox Extensions'      'xul-ext-ubufox xul-ext-unity xul-ext-webaccounts xul-ext-websites-integration'
appremove 'Unity web browser'       'webbrowser-app'
appremove 'Thunderbird mail client' 'thunderbird'
appremove 'Onboard'                 'onboard'
appremove 'Fcitx'                   'fcitx fcitx-bin fcitx-config-common fcitx-data fcitx-modules fcitx-frontend-all'
appremove 'Mozc'                    'mozc-utils-gui'
appremove 'Orca screen reader'      'gnome-orca'
appremove 'X Diagnostic utility'    'xdiagnose'
appremove 'Backup utility'          'deja-dup'
appremove 'Help'                    'yelp yelp-xsl gnome-user-guide ubuntu-docs'
appremove 'Font viewer'             'gnome-font-viewer'
appremove 'Symbols table'           'gucharmap'
appremove 'xterm'                   'xterm'
appremove 'Landscape'               'landscape-client-ui-install'
appremove 'Dconf editor'            'dconf-editor'
appremove 'Web camera'              'cheese'
appremove 'Transmission'            'transmission-common transmission-gtk'
appremove 'Rhythmbox'               'rhythmbox rhythmbox-data'
appremove 'Totem'                   'totem totem-common'
appremove 'Gnome Music'             'gnome-music'
appremove 'Gnome Photos'            'gnome-photos'
appremove 'USB creator'             'usb-creator-gtk usb-creator-common'
appremove 'AppArmor'                'apparmor apparmor-utils'
appremove 'Apport'                  'apport apport-gtk'
appremove 'Ubuntu web launchers'    'ubuntu-web-launchers'

## Remove unused ---------------------------------------------------------------

silentsudo 'Removing unused packages' apt-get autoremove --yes --force-yes --purge

## Enable all package sources --------------------------------------------------

repoaddnonfree

## Change download mirror to Yandex --------------------------------------------

changemirror 'mirror.yandex.ru'

## Add PPA`s -------------------------------------------------------------------

ppaadd  'Numix Project'             'numix'
ppaadd  'Paper Themes (Daily)'      'snwh' 'pulp' 'xenial'
ppaadd  'LibreOffice'               'libreoffice'

## Update ----------------------------------------------------------------------

appupdate
appupgrade

## Install ---------------------------------------------------------------------

## Gnome defaults  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

bundle install 'gnome'

## Qt support  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

bundle install 'qt'

## Drivers - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

bundle install 'driver'

## Appearance  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

bundle install 'appearance'

## Development - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

bundle install 'dev/build'
bundle install 'dev/analysis'
bundle install 'dev/style'
bundle install 'dev/doc'
bundle install 'dev/qt'
bundle install 'dev/db'
bundle install 'dev/json'
bundle install 'dev/net'

## VCS - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

bundle install 'vcs'

## Office  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

bundle install 'office'

## Graphic - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

bundle install 'graphics'

## Other - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

bundle install 'archive'
bundle install 'cli'


