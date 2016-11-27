#!/bin/bash

bundle prepare 'server/ftp'
bundle prepare 'server/smb'
bundle prepare 'server/svn'

sudo mkdir -p "${rootfs_dir}/etc/network/interfaces.d"
sudo cp -rf "${ROOT_PATH}/custom/files/server_work/eth0.interface" "${rootfs_dir}/etc/network/interfaces.d/"
