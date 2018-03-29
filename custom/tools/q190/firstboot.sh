#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

### Install Wi-FI driver =======================================================

pushd /usr/bin/drivers/rtl8812AU_8821AU_linux

silentsudo 'Building driver' make -f Makefile.dkms install

popd

