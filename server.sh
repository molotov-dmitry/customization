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

### Fix directory permissions ==================================================

fixpermissions '/media/documents'
fixpermissions '/media/windows'
fixpermissions '/media/something'

### Applications ===============================================================

## Updating --------------------------------------------------------------------

appupdate
appupgrade

## Install ---------------------------------------------------------------------

appinstall 'MiniDLNA'               'minidlna'
appinstall 'Transmission'           'transmission-daemon' 

### Configuration ==============================================================

## Inotify fix for MiniDLNA ----------------------------------------------------

#silentsudo 'Inotyfy max watchs fix' bash -c 'echo -e "# Increase inotify max watchs per user for local minidlna\nfs.inotify.max_user_watches = 100000" > /etc/sysctl.d/90-inotify.conf'
#silentsudo 'Inotify max watchs fix' sysctl fs.inotify.max_user_watches=100000

## -----------------------------------------------------------------------------

### Application configuration ==================================================

## MiniDLNA --------------------------------------------------------------------

#silentsudo 'Stopping MiniDLNA'      service minidlna stop
#silentsudo 'Copying MiniDLNA config' sudo cp -f "${ROOT_PATH}/files/minidlna/minidlna.conf" "/etc/"
#silentsudo 'Starting MiniDLNA'      service minidlna start

## Transmission ----------------------------------------------------------------

silentsudo 'Stopping Transmission' service transmission-daemon stop
silentsudo 'Creating dir for Transmission config' sudo mkdir -p "/etc/transmission-daemon"
silentsudo 'Copying Transmission config' sudo cp -f "${ROOT_PATH}/files/transmission/settings.json" "/etc/transmission-daemon/"
silentsudo 'Starting Transmission' service transmission-daemon start


