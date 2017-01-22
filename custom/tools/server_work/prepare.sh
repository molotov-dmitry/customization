#!/bin/bash

### Gitlab stub ================================================================

bundle prepare 'gitlab'

### Copy config files ==========================================================

## Service unit files ----------------------------------------------------------

for srv in irbuild.service irserver.service timesync.service
do
    silentsudo "Copy ${srv//.*} unit" cp -f "${custom_file_path}/${srv}" "${rootfs_dir}/tools/files/"
done

## Application config files ----------------------------------------------------

bundle prepare 'server/ftp'
bundle prepare 'server/smb'
bundle prepare 'server/svn'

## Network configuration -------------------------------------------------------

sudo mkdir -p "${rootfs_dir}/etc/network/interfaces.d"
sudo cp -rf "${custom_file_path}/eth0.interface" "${rootfs_dir}/etc/network/interfaces.d/"
