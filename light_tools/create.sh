#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

sudo echo -n

#clear
#clear

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
appremove 'Network manager'         'network-manager network-manager-pptp'

appremove 'Apport'                  'apport apport-gtk'

appremove 'Unused ES language'      'language-pack-es language-pack-es-base language-pack-gnome-es language-pack-gnome-es-base'
appremove 'Unused ZH language'      'language-pack-gnome-zh-hans language-pack-gnome-zh-hans-base language-pack-zh-hans language-pack-zh-hans-base'

## Remove unused ---------------------------------------------------------------

silentsudo 'Removing unused packages' apt-get autoremove --yes --force-yes --purge

### Enabling 'universe' and 'multiverse' package sources -----------------------

silentsudo 'Enabling universe source' add-apt-repository universe
silentsudo 'Enabling multiverse source' add-apt-repository multiverse

silentsudo 'Accepting EULA license' sh -c 'echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections'

## Adding PPA`s ----------------------------------------------------------------

ppaadd  'Numix Project'             'numix'
ppaadd  'LibreOffice'               'libreoffice'
ppaadd  'Elementary OS'             'elementary-os'             'daily'

## Updating --------------------------------------------------------------------

appupdate
appupgrade

## Install ---------------------------------------------------------------------

## Themes  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

appinstall 'Numix theme'            'numix-icon-theme-circle numix-gtk-theme'
appinstall 'Breeze theme'           'breeze-cursor-theme breeze-icon-theme'
appinstall 'Oxygen cursors'         'oxygen-cursor-theme oxygen-cursor-theme-extra'
appinstall 'Elementary theme'       'elementary-icon-theme elementary-theme elementary-wallpapers'

## Fonts - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

#appinstall 'Droid fonts'            'fonts-droid-fallback'
appinstall 'MS TTF core fonts'      'ttf-mscorefonts-installer'
appinstall 'Noto fonts'             'fonts-noto'

### VCS  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

appinstall 'VCS'                    'git subversion'

if ispkginstalled nautilus
then
    appinstall 'RabbitVCS'          'rabbitvcs-core rabbitvcs-nautilus'
fi

## Development - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

appinstall 'Build tools'            'build-essential astyle unifdef'
appinstall 'Multilib tools'         'gcc-multilib g++-multilib'
appinstall 'Static analysis tools'  'cppcheck cppcheck-gui'
appinstall 'Dynamic analysis tools' 'valgrind'

appinstall 'X11 sdk'                'libx11-dev'

appinstall 'OpenGL sdk'             'freeglut3 freeglut3-dev libglew1.10 libglew-dbg libglu1-mesa libglu1-mesa-dev libgl1-mesa-glx libgl1-mesa-dev'

appinstall 'Qt SDK'                 'qml qtbase5-dev qtdeclarative5-dev qt5-doc'
appinstall 'Qt Libs'                'libqt5svg5 libqt5webkit5-dev'
appinstall 'Qt IDE'                 'qtcreator'

appinstall 'GTK+ SDK'               'libgtk-3-dev libgtkmm-3.0-dev libtool libtool-bin'
appinstall 'GTK+ Libs'              'libgtksourceview-3.0-dev libgtksourceview-3.0-1 libgtksourceviewmm-3.0-0v5 libgtksourceview-3.0-dev libpeas-1.0-0 libpeas-dev libgit2-glib-1.0-dev libgit2-glib-1.0-0'
appinstall 'GTK+ IDE'               'anjuta glade'

appinstall 'GNOME IDE'              'gnome-builder'

appinstall 'Doxygen'                'doxygen graphviz'

appinstall 'Postgres'               'postgresql pgadmin3 libpq5 libpq-dev'
appinstall 'SQLite'                 'sqlite sqliteman libsqlite3-0 libsqlite3-dev'

## Graphic - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

appinstall 'GIMP'                   'gimp'
appinstall 'Imagemagick'            'imagemagick'

## Other - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

appinstall 'FTP server'             'vsftpd'
appinstall 'Samba'                  'cifs-utils samba'
appinstall '7-zip'                  'p7zip-rar p7zip-full'
appinstall 'ibus-gtk'               'ibus-gtk'

## VMWare tools  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

appinstall 'VMWare tools'           'open-vm-tools open-vm-tools-desktop fuse xauth xserver-xorg-input-vmmouse xserver-xorg-video-vmware xdg-utils'

## Localization  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

appinstall 'Language support'       'hyphen-ru language-pack-gnome-ru language-pack-gnome-ru-base language-pack-ru language-pack-ru-base libreoffice-l10n-ru'
appinstall 'Locales for apps'       'gimp-help-ru libreoffice-help-ru firefox-locale-ru mythes-ru hunspell-ru'

## Additional moves ------------------------------------------------------------

cd /tools
silentsudo 'Downloading cifs-utils package' apt-get download cifs-utils
cd "${ROOT_PATH}"
