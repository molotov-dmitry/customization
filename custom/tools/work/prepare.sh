#!/bin/bash

### Copy config files ==========================================================

## Service unit files ----------------------------------------------------------

for srv in irbuild.service irserver.service svnserve.service timesync.service
do
    silentsudo "Copy ${srv//.*} unit" cp -f "${custom_file_path}/${srv}" "${rootfs_dir}/tools/files/"
done

## Application config files ----------------------------------------------------

silentsudo "Copy vsftpd config" cp -rf "${ROOT_PATH}/files/vsftpd"          "${rootfs_dir}/tools/files/"
silentsudo "Copy Libreoffice config" cp -rf "${ROOT_PATH}/files/libreoffice" "${rootfs_dir}/tools/files/"

## Network interface config ----------------------------------------------------

sudo mkdir -p "${rootfs_dir}/etc/network/interfaces.d"
silentsudo "Copy network interface config" cp -rf "${custom_file_path}/eth0.interface" "${rootfs_dir}/etc/network/interfaces.d/"
