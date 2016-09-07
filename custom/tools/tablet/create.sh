#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

sudo echo -n

clear
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

#appremove 'Brasero'                 'brasero brasero-cdrkit brasero-common'

#appremove 'Simple Scanning Utility' 'simple-scan'
#appremove 'LibreOffice unused apps' 'libreoffice-draw libreoffice-impress libreoffice-math'
#appremove 'Games'                   'gnome-mines gnome-sudoku gnome-mahjongg aisleriot'
#appremove 'Firefox Extensions'      'xul-ext-ubufox xul-ext-unity xul-ext-webaccounts xul-ext-websites-integration'
#appremove 'Remote desktop client'   'remmina remmina-common remmina-plugin-rdp remmina-plugin-vnc'
#appremove 'Unity web browser'       'webbrowser-app'
#appremove 'Thunderbird mail client' 'thunderbird'
#appremove 'Onboard'                 'onboard'
#appremove 'Fcitx'                   'fcitx fcitx-bin fcitx-config-common fcitx-data fcitx-modules fcitx-frontend-all'
#appremove 'Orca screen reader'      'gnome-orca'
#appremove 'X Diagnostic utility'    'xdiagnose'
#appremove 'Backup utility'          'deja-dup'
#appremove 'Help'                    'yelp yelp-xsl gnome-user-guide ubuntu-docs'
#appremove 'Font viewer'             'gnome-font-viewer'
#appremove 'Symbols table'           'gucharmap'
#appremove 'xterm'                   'xterm'
#appremove 'Landscape'               'landscape-client-ui-install'
#appremove 'Firefox'                 'firefox'
#appremove 'Evolution'               'evolution evolution-common evolution-plugins'
#appremove 'Dconf editor'            'dconf-editor'
#appremove 'Empathy'                 'empathy empathy-common'
#appremove 'Web camera'              'cheese'
#appremove 'Gnome applications'      'gnome-contacts gnome-weather gnome-documents gnome-maps'
#appremove 'Transmission'            'transmission-common transmission-gtk'

### Enable all package sources -------------------------------------------------

repoaddnonfree

silentsudo 'Accepting EULA license' sh -c 'echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections'

## Adding PPA`s ----------------------------------------------------------------

ppaadd  'LibreOffice'               'libreoffice'
ppaadd  'Numix Project'             'numix'
ppaadd  'Elementary OS'             'elementary-os'             'daily'
ppaadd  'Paper theme'               'snwh'                      'pulp'

## Update ----------------------------------------------------------------------

appupdate
#appupgrade


## Install ---------------------------------------------------------------------

## Themes  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

#appinstall 'Numix theme'            'numix-icon-theme-circle numix-gtk-theme'
#appinstall 'Breeze theme'           'breeze-cursor-theme breeze-icon-theme'
#appinstall 'Oxygen cursors'         'oxygen-cursor-theme oxygen-cursor-theme-extra'
#appinstall 'Elementary theme'       'elementary-icon-theme elementary-theme elementary-wallpapers'
#appinstall 'Paper theme'            'paper-gtk-theme paper-icon-theme'
#debinstall 'Arc theme'              'arc-theme' "${ROOT_PATH}/files/arc/arc-theme_1465131682.3095952_all.deb"

## Fonts - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

#appinstall 'Droid fonts'            'fonts-droid-fallback'
#appinstall 'MS TTF core fonts'      'ttf-mscorefonts-installer'
#appinstall 'Noto fonts'             'fonts-noto'

## Internet  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

#appinstall 'Chromium'               'chromium-browser chromium-browser-l10n'

### VCS  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

appinstall 'VCS'                    'git subversion'

#if ispkginstalled nautilus
#then
#    appinstall 'RabbitVCS'          'rabbitvcs-core rabbitvcs-nautilus'
#fi

## Other - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

#appinstall 'Restricted extras'		'ubuntu-restricted-extras'
#appinstall '7-zip'                  'p7zip-rar p7zip-full'
#appinstall 'ibus-gtk'               'ibus-gtk'

## Upgrade ---------------------------------------------------------------------

appdistupgrade

### Drivers ====================================================================

## Kernel headers --------------------------------------------------------------

appinstall 'Build tools'            'build-essential'

if [[ "$(lsb_release -si)" == "Ubuntu" ]]
then
    appinstall 'Kernel headers'     'linux-headers-generic'
elif [[ "$(lsb_release -si)" == "Debian" ]]
then
    appinstall 'Kernel headers'     "linux-headers-$(kernelversion)"
fi

## Wi-Fi -----------------------------------------------------------------------

silentsudo 'Creating directory for drivers' mkdir -p /usr/bin/drivers

cd /usr/bin/drivers

silentsudo 'Cloning wi-fi driver'   git clone https://github.com/hadess/rtl8723as.git

cd rtl8723as

silentsudo 'Faking kernel version'  sed -i "s/uname -r/echo $(kernelversion)/" Makefile
silentsudo 'Building driver'        make
silentsudo 'Installing driver'      make install

silentsudo 'Adding module to autostart' bash -c 'echo r8723bs >> /etc/modules-load.d/rtl8723bs.conf'

## Bluetooth -------------------------------------------------------------------



### Cleaning up ================================================================

#silentsudo 'Removing unused packages' apt-get autoremove --yes --force-yes --purge


