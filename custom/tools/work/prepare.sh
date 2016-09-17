#!/bin/bash

sudo cp -rf "${ROOT_PATH}/files/vsftpd"          "${rootfs_dir}/tools/files/"
sudo cp -rf "${ROOT_PATH}/files/libreoffice" "${rootfs_dir}/tools/files/"

sudo mkdir -p "${rootfs_dir}/etc/network/interfaces.d"
sudo cp -rf "${ROOT_PATH}/custom/files/work/eth0.interface" "${rootfs_dir}/etc/network/interfaces.d/"
