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

### Customization ==============================================================

title 'Customization'

## -----------------------------------------------------------------------------

msgdone

### Application customization ==================================================

title 'Configuring applications'

## MiniDLNA --------------------------------------------------------------------

sudo cp -f "${ROOT_PATH}/files/minidlna/minidlna.conf" "/etc/"

## -----------------------------------------------------------------------------

msgdone


