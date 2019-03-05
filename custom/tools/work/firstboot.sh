#!/bin/bash

### Setup DNS names ============================================================

cat << EOF >> /etc/hosts
172.16.56.14    rczifort.local
172.16.56.15    redmine.rczifort.local
172.16.56.16    chat.rczifort.local
172.16.56.17    ex01.rczifort.local
172.16.56.22    git.rczifort.local
172.16.56.23    data.rczifort.local

EOF

### Install Wi-Fi driver =======================================================

pushd /usr/bin/drivers/rtl8812AU_8821AU_linux > /dev/null
make -f Makefile.dkms install
popd > /dev/null
