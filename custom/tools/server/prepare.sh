#!/bin/bash

sudo cp -rf "${ROOT_PATH}/files/eiskaltdcpp"     "${rootfs_dir}/tools/files/"
sudo cp -rf "${ROOT_PATH}/files/minidlna"        "${rootfs_dir}/tools/files/"
sudo cp -rf "${ROOT_PATH}/files/samba"           "${rootfs_dir}/tools/files/"
sudo cp -rf "${ROOT_PATH}/files/transmission"    "${rootfs_dir}/tools/files/"
sudo cp -rf "${ROOT_PATH}/files/vsftpd"          "${rootfs_dir}/tools/files/"


sudo mkdir -p "${rootfs_dir}/etc/network/interfaces.d"
sudo cp -rf "${ROOT_PATH}/custom/files/server/eth0.interface" "${rootfs_dir}/etc/network/interfaces.d/"
