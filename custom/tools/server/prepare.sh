#!/bin/bash

### Bundles ====================================================================

bundle prepare 'server'

### Copy network config ========================================================

sudo mkdir -p "${rootfs_dir}/etc/network/interfaces.d"
sudo cp -rf "${ROOT_PATH}/custom/files/server/eth0.interface" "${rootfs_dir}/etc/network/interfaces.d/"

