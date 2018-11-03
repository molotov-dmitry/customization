#!/bin/bash

### Copy network config ========================================================

mkdir -p "${rootfs_dir}/etc/network/interfaces.d"
cp -rf "${ROOT_PATH}/custom/files/server/eth0.interface" "${rootfs_dir}/etc/network/interfaces.d/"

