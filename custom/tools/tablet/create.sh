#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

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

silent 'Creating directory for drivers' mkdir -p /usr/bin/drivers

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

silent 'Cloning audio configs'      git clone --depth 1 https://github.com/plbossart/UCM.git

cd UCM

silent 'Installing configs'         cp -rf ./ /usr/share/alsa/ucm/

silent 'Blacklist audio module'     sh -c "echo 'blacklist snd_hdmi_lpe_audio' > /etc/modprobe.d/blacklist-snd-hdmi-lpe-audio.conf"

## Bluetooth -------------------------------------------------------------------

cd /usr/bin/drivers

silent 'Cloning bluetooth driver'   git --depth 1 clone https://github.com/lwfinger/rtl8723bs_bt.git

cd rtl8723bs_bt

silent 'Building bluetooth driver'  make
silent 'Installing bluetooth driver' make install
