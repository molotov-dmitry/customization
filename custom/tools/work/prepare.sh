#!/bin/bash

### Copy config files ==========================================================

## Service unit files ----------------------------------------------------------

for srv in irbuild.service irserver.service timesync.service
do
    silentsudo "Copy ${srv//.*} unit" cp -f "${custom_file_path}/${srv}" "${rootfs_dir}/tools/files/"
done

## Application config files ----------------------------------------------------

bundle prepare 'server/ftp'
bundle prepare 'server/svn'

bundle prepare 'office'
