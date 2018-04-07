#!/bin/bash

### Copy config files ==========================================================

sudo mkdir -p "${rootfs_dir}/etc/network/interfaces.d"
sudo cp -rf "${custom_file_path}/eth0.interface" "${rootfs_dir}/etc/network/interfaces.d/"
