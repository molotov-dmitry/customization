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

## Modem - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

## Wi-Fi -----------------------------------------------------------------------

cd /usr/bin/drivers

silentsudo 'Cloning wi-fi driver'   git clone https://github.com/hadess/rtl8723as.git

cd rtl8723as

for kernelver in $(kernelversionlist)
do

    cp -f Makefile Makefile.bak

    silentsudo 'Faking kernel version'  sed -i "s/uname -r/echo ${kernelver}/" Makefile
    silentsudo 'Building driver'        make
    silentsudo 'Installing driver'      make install

    mv -f Makefile.bak Makefile

done

silentsudo 'Adding module to autostart' bash -c 'echo r8723bs >> /etc/modules-load.d/rtl8723bs.conf'

## Bluetooth -------------------------------------------------------------------

cd /usr/bin/drivers

silentsudo 'Cloning bluetooth driver'   git clone https://github.com/lwfinger/rtl8723bs_bt.git

cd rtl8723bs_bt

silentsudo 'Building bluetooth driver'  make
silentsudo 'Installing bluetooth driver' make install

## battery ---------------------------------------------------------------------

appinstall 'i2c-tools'  'i2c-tools'

cd /usr/bin/drivers

silentsudo 'Cloning battery driver'   git clone https://github.com/Icenowy/axpd.git

cd axpd

silentsudo '' sed -i 's/\/usr\/libexec/\/usr\/bin\/drivers\/axpd/' axpd.service
silentsudo '' mkdir -p "${ROOT_PATH}/files/axpd/"
silentsudo '' cp -f axpd.service "${ROOT_PATH}/files/axpd/"

addservice 'AXP288 I2C Daemon' 'axpd' 'axpd'
