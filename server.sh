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

### Creating directories for distrib ===========================================

silentsudo 'Creating Distrib directory' mkdir -p /media/documents/Distrib -m 0777
silentsudo 'Creating Books directory'   mkdir -p /media/documents/Books -m 0777
silentsudo 'Creating Archive directory' mkdir -p /media/documents/Archive -m 0777
silentsudo 'Creating incomplete direcrory' mkdir -p /media/documents/Downloads/Incomplete -m 0777

### Fix directory permissions ==================================================

fixpermissions '/media/documents'

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

### Configuration ==============================================================

## Inotify fix for MiniDLNA ----------------------------------------------------

silentsudo 'Inotyfy max watchs fix' bash -c 'echo -e "fs.inotify.max_user_watches = 100000" > /etc/sysctl.d/90-inotify.conf'
silentsudo 'Inotify max watchs fix' sysctl fs.inotify.max_user_watches=100000

## -----------------------------------------------------------------------------

### Application configuration ==================================================

## MiniDLNA --------------------------------------------------------------------

silentsudo 'Stopping MiniDLNA'      service minidlna stop
silentsudo 'Configuring MiniDLNA'   sudo cp -f "${ROOT_PATH}/files/minidlna/minidlna.conf" '/etc/'
silentsudo 'Starting MiniDLNA'      service minidlna start

## Transmission ----------------------------------------------------------------

silentsudo 'Stopping Transmission'  service transmission-daemon stop
silentsudo 'Creating Transmission config dir' mkdir -p '/etc/transmission-daemon'
silentsudo 'Configuring Transmission' cp -f "${ROOT_PATH}/files/transmission/settings.json" '/etc/transmission-daemon/'
silentsudo 'Starting Transmission'  service transmission-daemon start

## Samba -----------------------------------------------------------------------

silentsudo 'Stopping Samba'         service smbd stop
silentsudo 'Creating Samba config dir' mkdir -p '/etc/samba'
silentsudo 'Configuring Samba'      cp -f "${ROOT_PATH}/files/samba/smb.conf" '/etc/samba/'
silentsudo 'Starting Samba'         service smbd start

## EiskaltDC++ -----------------------------------------------------------------

silentsudo 'Stopping EiskaltDC++'           service eiskaltdcpp stop
silentsudo 'Enabling EiskaltDC++ service'   systemctl disable eiskaltdcpp
silentsudo 'Creating EiskaltDC++ config dir' mkdir -p '/etc/eiskaltdcpp'
silentsudo 'Configuring EiskaltDC++'        cp -f "${ROOT_PATH}/files/eiskaltdcpp/DCPlusPlus.xml" '/etc/eiskaltdcpp/'
silentsudo 'Configuring EiskaltDC++ Hubs'   cp -f "${ROOT_PATH}/files/eiskaltdcpp/Favorites.xml" '/etc/eiskaltdcpp/'
silentsudo 'Creating EiskaltDC++ service'   cp -f "${ROOT_PATH}/files/eiskaltdcpp/eiskaltdcpp.service" '/etc/systemd/system/'
silentsudo 'Enabling EiskaltDC++ service'   systemctl enable eiskaltdcpp
silentsudo 'Starting EiskaltDC++'           service eiskaltdcpp start

