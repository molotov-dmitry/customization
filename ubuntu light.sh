#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

sudo echo -n

clear
clear

### Test internet connection ===================================================

title 'testing internet connection'

if conntest
then
    msgdone
else
    msgfail
    exit 1
fi

### Check UCK is installed =====================================================

title 'Checking UCK is installed'

if ispkginstalled 'uck'
then
    msgdone
else
    msgwarn '[not installed]'

    if ! appinstall 'UCK' 'uck'
    then
        exit 2
    fi
fi

### Preparing ISO ==============================================================

iso_src="$1"
[[ -z "${iso_src}" ]] && iso_src="${HOME}/ubuntu-15.10-desktop-amd64.iso"

remaster_dir="${HOME}/tmp"
iso_dir="${remaster_dir}/remaster-iso"
rootfs_dir="${remaster_dir}/remaster-root"

echo "iso image:    ${iso_src}"
echo "remaster dir: ${remaster_dir}"

read

silentsudo 'Removing old CD'                rm -rf "${remaster_dir}"

silentsudo 'Unpacking iso'                  uck-remaster-unpack-iso "${iso_src}"
silentsudo 'Unpacking rootfs'               uck-remaster-unpack-rootfs
silentsudo 'Removing Win32 files'           uck-remaster-remove-win32-files

silentsudo 'Setting default language'       sh -c "echo ru > \"${iso_dir}\"/isolinux/lang"

silentsudo 'Removing Tools dir'             rm -rf "${rootfs_dir}/tools"
silentsudo 'Creating Tools dir'             mkdir -p "${rootfs_dir}/tools"

silentsudo 'Copying functions script'       cp -f "${ROOT_PATH}/functions.sh" "${rootfs_dir}/tools/"
silentsudo 'Copying create script'          cp -f "${ROOT_PATH}/light_tools/create.sh" "${rootfs_dir}/tools/"

silentsudo 'Copying net config'             cp -f "${ROOT_PATH}/light_files/interfaces" "${rootfs_dir}/etc/network/interfaces"
silentsudo 'Copying init script'            cp -f "${ROOT_PATH}/light_files/rc.local" "${rootfs_dir}/etc/rc.local"

sudo                                        uck-remaster-chroot-rootfs "${remaster_dir}" bash /tools/create.sh

silentsudo 'Removing create script'         rm -rf "${rootfs_dir}/tools/create.sh" "${rootfs_dir}/tools/functions.sh"

silentsudo 'Copying functions script #2'    cp -f "${ROOT_PATH}/functions.sh" "${rootfs_dir}/tools/"
silentsudo 'Copying folders script'         cp -f "${ROOT_PATH}/folders.sh" "${rootfs_dir}/tools/"
silentsudo 'Copying after install script'   cp -f "${ROOT_PATH}/light_tools/after_install.sh" "${rootfs_dir}/tools/"
#silentsudo 'Copying financedb script'       cp -f "${ROOT_PATH}/financedb.sh" "${rootfs_dir}/tools/"

silentsudo 'Changing tools mode'            chmod -R 777 "${rootfs_dir}/tools"

silentsudo 'Packing rootfs'                 uck-remaster-pack-rootfs -c
silentsudo 'Packing iso'                    uck-remaster-pack-iso ubuntu-15.10-light-amd64.iso -h -g -d "Ubuntu 15.10"

