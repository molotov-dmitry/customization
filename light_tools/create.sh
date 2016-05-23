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

appremove 'Apt listchanges'         'apt-listchanges'

## Remove unused ---------------------------------------------------------------

silentsudo 'Removing unused packages' apt-get autoremove --yes --force-yes --purge

### Enabling 'universe' and 'multiverse' package sources -----------------------

#changerelease 'stretch'
repoaddnonfree

silentsudo 'Accepting EULA license' sh -c 'echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections'

## Adding PPA`s ----------------------------------------------------------------

ppaadd  'Numix Project'             'numix'
ppaadd  'LibreOffice'               'libreoffice'

## Updating --------------------------------------------------------------------

appupdate
appdistupgrade

## Install ---------------------------------------------------------------------

## Themes  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

appinstall 'Numix theme'            'numix-icon-theme-circle numix-gtk-theme'
#appinstall 'Breeze theme'           'breeze-cursor-theme breeze-icon-theme'
appinstall 'Oxygen cursors'         'oxygencursors'

## Fonts - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

#appinstall 'Droid fonts'            'fonts-droid-fallback'
appinstall 'MS TTF core fonts'      'ttf-mscorefonts-installer'
appinstall 'Noto fonts'             'fonts-noto'

### VCS  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

appinstall 'VCS'                    'git subversion'

#if ispkginstalled nautilus
#then
#    appinstall 'RabbitVCS'          'rabbitvcs-core rabbitvcs-nautilus'
#fi

## Development - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

#appinstall 'Build tools'            'build-essential astyle unifdef'
#appinstall 'Multilib tools'         'gcc-multilib g++-multilib'
#appinstall 'Static analysis tools'  'cppcheck cppcheck-gui'
#appinstall 'Dynamic analysis tools' 'valgrind'

#appinstall 'X11 sdk'                'libx11-dev'

#appinstall 'OpenGL sdk'             'freeglut3 freeglut3-dev libglew1.10 libglew-dbg libglu1-mesa libglu1-mesa-dev libgl1-mesa-glx libgl1-mesa-dev'

#appinstall 'Qt SDK'                 'qml qtbase5-dev qtdeclarative5-dev qt5-doc'
#appinstall 'Qt Libs'                'libqt5svg5 libqt5webkit5-dev'
#appinstall 'Qt IDE'                 'qtcreator'

#appinstall 'GTK+ SDK'               'libgtk-3-dev libgtkmm-3.0-dev libtool libtool-bin'
#appinstall 'GTK+ Libs'              'libgtksourceview-3.0-dev libgtksourceview-3.0-1 libgtksourceviewmm-3.0-0v5 libgtksourceview-3.0-dev libpeas-1.0-0 libpeas-dev libgit2-glib-1.0-dev libgit2-glib-1.0-0'
#appinstall 'GTK+ IDE'               'anjuta glade'

#appinstall 'GNOME IDE'              'gnome-builder'

#appinstall 'Doxygen'                'doxygen graphviz'

#appinstall 'Postgres'               'postgresql pgadmin3 libpq5 libpq-dev'
#appinstall 'SQLite'                 'sqlite sqliteman libsqlite3-0 libsqlite3-dev'

## Graphic - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

#appinstall 'GIMP'                   'gimp'
#appinstall 'Imagemagick'            'imagemagick'

## Other - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

#appinstall 'FTP server'             'vsftpd'
#appinstall 'Samba'                  'cifs-utils samba'
#appinstall '7-zip'                  'p7zip-rar p7zip-full'
#appinstall 'ibus-gtk'               'ibus-gtk'

## VMWare tools  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

#appinstall 'VMWare tools'           'open-vm-tools open-vm-tools-desktop fuse xauth xserver-xorg-input-vmmouse xserver-xorg-video-vmware xdg-utils'

## Localization  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

#appinstall 'Language support'       'hyphen-ru language-pack-gnome-ru language-pack-gnome-ru-base language-pack-ru language-pack-ru-base libreoffice-l10n-ru'
#appinstall 'Locales for apps'       'gimp-help-ru libreoffice-help-ru firefox-locale-ru mythes-ru hunspell-ru'

## Additional moves ------------------------------------------------------------

##cd /tools
##silentsudo 'Downloading cifs-utils package' apt-get download cifs-utils
##cd "${ROOT_PATH}"
