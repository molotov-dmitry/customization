#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

### CD burning =================================================================

appinstall 'Xorriso'                'xorriso'

### Wi-Fi driver ===============================================================

appinstall 'RTL8812AU driver'       'rtl8812au-dkms'
appinstall 'RTL8192EU driver'       'rtl8192eu-config rtl8192eu-dkms'

### Report builder =========================================================

appinstall 'Work report'            'work-report report-builder report-builder-html'

### Chromium/Chrome ============================================================

if [[ "$(lsb_release -si)" != "Ubuntu" ]]
then
    appinstall 'Chromium'           'chromium chromium-l10n libnss3-tools'
else
    appinstall 'Google Chrome'      'google-chrome-stable libnss3-tools'
fi

if ispkginstalled gnome-shell
then
    appinstall 'Gnome browser integration' 'gnome-browser-connector'
fi
