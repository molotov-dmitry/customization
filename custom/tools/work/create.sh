#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

### ============================================================================

appinstall 'RDP server' 'vino'

if [[ "$(lsb_release -si) $(lsb_release -sc)" == 'Debian stretch' ]]
then
    appinstall 'RDP client' 'vinagre'
else
    appinstall 'RDP client' 'remmina remmina-plugin-vnc remmina-plugin-rdp remmina-plugin-xdmcp'
fi

### CD burning =================================================================

appinstall 'Xorriso'                'xorriso'

### Wi-Fi driver ===============================================================

appinstall 'DKMS'                   'dkms [linux-headers-generic]'
appinstall 'Git'                    'git'
silentsudo 'Cloning wi-fi driver'   git clone --depth 1 'https://github.com/gordboy/rtl8812au.git' /usr/src/rtl8812au-5.2.20

### Report builder =============================================================

appinstall 'Git'                    'git'
appinstall 'Build tools'            'g++ qtbase5-dev'

pushd /tmp > /dev/null

silentsudo 'Cloning Work Report'    git clone 'https://github.com/molotov-dmitry/work-report.git'

pushd work-report > /dev/null

silentsudo 'Prepare Work Report'    qmake -qt=qt5 work-report.pro
silentsudo 'Build Work Report'      make -j $(nproc)
silentsudo 'Install Work Report'    bash install.sh

popd > /dev/null
popd > /dev/null

### Network switcher ===========================================================

appinstall 'Git'                    'git'

pushd /tmp > /dev/null

silentsudo 'Cloning Network Switcher'   git clone 'https://github.com/molotov-dmitry/network-switch.git'

pushd network-switch > /dev/null

mkdir -p /usr/local/bin
silentsudo 'Install Network Switcher'   install network-switch.sh /usr/local/bin/network-switch

popd > /dev/null
popd > /dev/null
