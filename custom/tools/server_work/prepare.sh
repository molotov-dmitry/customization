#!/bin/bash

### Copy config files ==========================================================

mkdir -p "${rootfs_dir}/etc/network/interfaces.d"
cp -rf "${custom_file_path}/eth0.interface" "${rootfs_dir}/etc/network/interfaces.d/"
