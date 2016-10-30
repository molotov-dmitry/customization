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

appremove 'Apt listchanges'         'apt-listchanges'

appremove 'Brasero'                 'brasero brasero-cdrkit brasero-common'

appremove 'Simple Scanning Utility' 'simple-scan'
appremove 'LibreOffice unused apps' 'libreoffice-draw libreoffice-impress libreoffice-math'
appremove 'Games'                   'gnome-mines gnome-sudoku gnome-mahjongg aisleriot'
appremove 'Firefox Extensions'      'xul-ext-ubufox xul-ext-unity xul-ext-webaccounts xul-ext-websites-integration'
appremove 'Remote desktop client'   'remmina remmina-common remmina-plugin-rdp remmina-plugin-vnc'
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
appremove 'Dconf editor'            'dconf-editor'
appremove 'Transmission'            'transmission-common transmission-gtk'
appremove 'Gnome Music'             'gnome-music'

## Remove unused ---------------------------------------------------------------

silentsudo 'Removing unused packages' apt-get autoremove --yes --force-yes --purge

## Enable all package sources --------------------------------------------------

repoaddnonfree

## Add PPA`s -------------------------------------------------------------------

ppaadd  'Numix Project'             'numix'
ppaadd  'Paper Themes (Daily)'      'snwh' 'pulp' 'xenial'
#ppaadd  'LibreOffice'               'libreoffice'
ppaadd  'Web Upd8'                  'nilarimogard' 'webupd8'

## Update ----------------------------------------------------------------------

appupdate
appupgrade

## Install ---------------------------------------------------------------------

## Gnome defaults  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

bundle install 'gnome'

## Qt support  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

bundle install 'qt'

## Appearance  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

bundle install 'appearance'

## Development - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

#bundle install 'dev'

## VCS - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

bundle install 'vcs'

## Network - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

#bundle install 'network'
#bundle install 'network-remote'

## Office  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

#bundle install 'office'

## Media - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

#bundle install 'media'
#bundle install 'media-online'

## Graphic - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

#bundle install 'graphics'

## Other - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

bundle install 'archive'
bundle install 'cli/files'

#appinstall 'Iperf'                  'iperf iperf3'

## Modem - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

appinstall 'Modem tools' 'libmbim-utils libqmi-utils minicom'

### Drivers ====================================================================

silentsudo 'Creating directory for drivers' mkdir -p /usr/bin/drivers

## Kernel headers --------------------------------------------------------------

bundle install 'dev/build'

for kernelver in $(kernelversionlist)
do
    appinstall "${kernelver} kernel headers"     "linux-headers-${kernelver}"
done

if [[ "$(lsb_release -si)" == "Ubuntu" ]]
then
    appinstall 'Generic kernel headers'     'linux-headers-generic'
fi

## Wi-Fi -----------------------------------------------------------------------

cd /usr/bin/drivers

silentsudo 'Cloning wi-fi driver'   git clone https://github.com/hadess/rtl8723as.git

cd rtl8723as

for kernelver in $(kernelversionlist)
do

    cp -f Makefile Makefile.bak

    silentsudo 'Faking kernel version'  sed -i "s/uname -r/echo ${kernelver}/" Makefile
    silentsudo 'Building driver'        make
    silentsudo 'Installing driver'      make install

    mv -f Makefile.bak Makefile

done

silentsudo 'Adding module to autostart' bash -c 'echo r8723bs >> /etc/modules-load.d/rtl8723bs.conf'

## Bluetooth -------------------------------------------------------------------

cd /usr/bin/drivers

silentsudo 'Cloning bluetooth driver'   git clone https://github.com/lwfinger/rtl8723bs_bt.git

cd rtl8723bs_bt

silentsudo 'Building bluetooth driver'  make
silentsudo 'Installing bluetooth driver' make install

## battery ---------------------------------------------------------------------

appinstall 'i2c-tools'  'i2c-tools'

cd /usr/bin/drivers

silentsudo 'Cloning battery driver'   git clone https://github.com/Icenowy/axpd.git

cd axpd

silentsudo '' mkdir -p "${ROOT_PATH}/files/axpd/"
silentsudo '' cp -f axpd.service "${ROOT_PATH}/files/axpd/"

addservice 'AXP288 I2C Daemon' 'axpd' 'axpd'

### Cleaning up ================================================================

#silentsudo 'Removing unused packages' apt-get autoremove --yes --force-yes --purge


