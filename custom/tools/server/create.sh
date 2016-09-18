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

## Updating --------------------------------------------------------------------

appupdate
appupgrade

## Install ---------------------------------------------------------------------

appinstall 'MiniDLNA'               'minidlna'
appinstall 'Transmission'           'transmission-daemon'
appinstall 'Samba'                  'samba'
appinstall 'Open SSH'               'openssh-server'
appinstall 'EiskaltDC++'            'eiskaltdcpp-daemon'
appinstall 'FTP server'             'vsftpd'
appinstall 'Iperf'                  'iperf iperf3'

appinstall 'VCS'                    'git subversion colordiff'

appinstall 'Tree'                   'tree'
appinstall 'Midnight Commander'     'mc'

### Configuration ==============================================================

## Inotify fix for MiniDLNA ----------------------------------------------------

silentsudo 'Inotyfy max watchs fix' bash -c 'echo -e "fs.inotify.max_user_watches = 100000" > /etc/sysctl.d/90-inotify.conf'
silentsudo 'Inotify max watchs fix' sysctl fs.inotify.max_user_watches=100000

## -----------------------------------------------------------------------------

### Application configuration ==================================================

## MiniDLNA --------------------------------------------------------------------

silentsudo 'Configuring MiniDLNA'           sudo cp -f "${ROOT_PATH}/files/minidlna/minidlna.conf" '/etc/'

## Transmission ----------------------------------------------------------------

silentsudo 'Creating Transmission config dir' mkdir -p '/etc/transmission-daemon'
silentsudo 'Configuring Transmission'       cp -f "${ROOT_PATH}/files/transmission/settings.json" '/etc/transmission-daemon/'

## Samba -----------------------------------------------------------------------

silentsudo 'Creating Samba config dir'      mkdir -p '/etc/samba'
silentsudo 'Configuring Samba'              cp -f "${ROOT_PATH}/files/samba/smb.conf" '/etc/samba/'

## EiskaltDC++ -----------------------------------------------------------------

silentsudo 'Creating EiskaltDC++ config dir' mkdir -p '/etc/eiskaltdcpp'
silentsudo 'Configuring EiskaltDC++'        cp -f "${ROOT_PATH}/files/eiskaltdcpp/DCPlusPlus.xml" '/etc/eiskaltdcpp/'
silentsudo 'Configuring EiskaltDC++ Hubs'   cp -f "${ROOT_PATH}/files/eiskaltdcpp/Favorites.xml" '/etc/eiskaltdcpp/'

addservice 'EiskaltDC++' 'eiskaltdcpp' 'eiskaltdcpp'

#silentsudo 'Creating EiskaltDC++ service'   cp -f "${ROOT_PATH}/files/eiskaltdcpp/eiskaltdcpp.service" '/etc/systemd/system/'
#silentsudo 'Enabling Network-online target' mkdir -p /etc/systemd/system/network-online.target.wants
#silentsudo 'Enabling EiskaltDC++ service'   ln -s /etc/systemd/system/eiskaltdcpp.service /etc/systemd/system/network-online.target.wants/eiskaltdcpp.service

## FTP server ------------------------------------------------------------------

silentsudo 'Configuring vsftpd'             cp -f "${ROOT_PATH}/files/vsftpd/vsftpd.conf" '/etc/'

