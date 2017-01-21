#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

### Creating directories for distrib ===========================================

silentsudo 'Creating Videos directory'      mkdir -p /media/documents/Video     -m 0777
silentsudo 'Creating Music directory'       mkdir -p /media/documents/Music     -m 0777
silentsudo 'Creating Images directory'      mkdir -p /media/documents/Images    -m 0777
silentsudo 'Creating Distrib directory'     mkdir -p /media/documents/Distrib   -m 0777
silentsudo 'Creating Documents directory'   mkdir -p /media/documents/Documents -m 0777
silentsudo 'Creating Books directory'       mkdir -p /media/documents/Books     -m 0777
silentsudo 'Creating Archive directory'     mkdir -p /media/documents/Archive   -m 0777
silentsudo 'Creating incomplete direcrory'  mkdir -p /media/documents/Downloads/Incomplete -m 0777

### Fix directory permissions ==================================================

fixpermissions '/media/documents' 1000

### Bundles ====================================================================

bundle firstboot 'server'
