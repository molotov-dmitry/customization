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

### Creating directories for distrib ===========================================

silentsudo 'Creating Distrib directory'     mkdir -p /media/documents/Distrib   -m 0777
silentsudo 'Creating Books directory'       mkdir -p /media/documents/Books     -m 0777
silentsudo 'Creating Archive directory'     mkdir -p /media/documents/Archive   -m 0777
silentsudo 'Creating incomplete direcrory'  mkdir -p /media/documents/Downloads/Incomplete -m 0777

### Fix directory permissions ==================================================

fixpermissions '/media/documents'

### Configuring GitLab (if not properly configured) ============================

apt install -f
