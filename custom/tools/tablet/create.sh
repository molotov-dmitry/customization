#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

sudo echo -n

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

appinstall 'Git' 'git'

## Modem -----------------------------------------------------------------------

appinstall 'Modem tools' 'libmbim-utils libqmi-utils minicom'

### Drivers ====================================================================

silentsudo 'Creating directory for drivers' mkdir -p /usr/bin/drivers

## Kernel headers --------------------------------------------------------------

bundle install 'dev/build'

for kernelver in $(kernelversionlist)
do
    appinstall "${kernelver} kernel headers"     "linux-headers-${kernelver}"
done

if [[ "$(lsb_release -si)" == "Ubuntu" ]]
then
    appinstall 'Generic kernel headers'     'linux-headers-generic'
fi

## Audio -----------------------------------------------------------------------

cd /usr/bin/drivers

silentsudo 'Cloning audio configs'      git clone https://github.com/plbossart/UCM.git

cd UCM

silentsudo 'Installing configs'         cp -rf ./ /usr/share/alsa/ucm/

## Bluetooth -------------------------------------------------------------------

cd /usr/bin/drivers

silentsudo 'Cloning bluetooth driver'   git clone https://github.com/lwfinger/rtl8723bs_bt.git

cd rtl8723bs_bt

silentsudo 'Building bluetooth driver'  make
silentsudo 'Installing bluetooth driver' make install
