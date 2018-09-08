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

appinstall 'DKMS'                           'dkms'
appinstall 'Git'                            'git'

pushd /usr/bin/drivers

silentsudo 'Cloning wi-fi driver'           git clone 'https://github.com/abperiasamy/rtl8812AU_8821AU_linux.git'

popd

silentsudo 'blacklisting default driver'    bash -c 'echo blacklist rtl8188ee > /etc/modprobe.d/rtl8188ee.conf'

