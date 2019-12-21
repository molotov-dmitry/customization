#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

### CD burning =================================================================

appinstall 'Xorriso'                'xorriso'

### Wi-Fi driver ===============================================================

appinstall 'RTL8812AU driver'       'rtl8812au-dkms'

### Report builder =========================================================

appinstall 'Work report'            'work-report report-builder'
