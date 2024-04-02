#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

### Purge unused ===============================================================

appremove 'CUPS'                    'libcups2'
appremove 'WPA supplicant'          'wpasupplicant'

### Root CA Certificate ========================================================

appinstall 'RCZI Root CA cert'      'ca-rczifort'

### GOST hash ==================================================================

appinstall 'GOST hashes'            'gostsum ctrlsum'

### QEMU guest agent ===========================================================

appinstall 'QEMU guest agent'       'qemu-guest-agent'
