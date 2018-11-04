#!/bin/bash

### Copy network config ========================================================

sudo mkdir -p "${rootfs_dir}/etc/network/interfaces.d"
sudo cp -rf "${ROOT_PATH}/custom/files/device/eth0.interface" "${rootfs_dir}/etc/network/interfaces.d/"

