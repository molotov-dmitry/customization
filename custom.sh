#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

sudo echo -n

clear
clear

#### functions =================================================================

function isdebain()
{
    if [[ "$(basename "${iso_src}")" == debian* ]]
    then
        return 0
    else
        return 1
    fi
}

function checkfilemime()
{
    filetitle="$1"
    filename="$2"
    mimetype="$3"
    filetype="$4"

    title "Checking ${filetitle}"

    if ! test -f "${filename}"
    then
        msgfail '[file not found]'
        exit 1
    fi

    filemime=$(file -b --mime-type "${filename}")

    if [[ "${filemime}" == "${mimetype}" ]]
    then
        msgdone
    else
        msgfail "[not an ${filetype}]"
        exit 1
    fi 
}

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

### Getting parameters =========================================================

iso_src="$1"
config="$2"

remaster_dir="${HOME}/tmp"
iso_dir="${remaster_dir}/remaster-iso"
rootfs_dir="${remaster_dir}/remaster-root"

#### Checking parameters =======================================================

## Checking iso image file -----------------------------------------------------

checkfilemime 'image file' "${iso_src}" 'application/x-iso9660-image' 'iso image'

## Checking config directory ---------------------------------------------------

checkfilemime 'functions script'    "${ROOT_PATH}/functions.sh" 'text/x-shellscript' 'shell script'
checkfilemime 'folders script'      "${ROOT_PATH}/folders.sh"   'text/x-shellscript' 'shell script'

checkfilemime 'create script'       "${ROOT_PATH}/custom/tools/${config}/create.sh"  'text/x-shellscript' 'shell script'
checkfilemime 'user script'         "${ROOT_PATH}/custom/tools/${config}/user.sh"    'text/x-shellscript' 'shell script'

### Showing parameters =========================================================

echo "iso image:    ${iso_src}"
echo "remaster dir: ${remaster_dir}"

read

### Generating custom CD =======================================================

## Preparing -------------------------------------------------------------------

silentsudo 'Removing old CD'                rm -rf "${remaster_dir}"

silentsudo 'Unpacking iso'                  uck-remaster-unpack-iso "${iso_src}"

if isdebain
then
    silentsudo '[DEB] Moving squashfs'      mv "${iso_dir}/live" "${iso_dir}/casper"
fi

silentsudo 'Unpacking rootfs'               uck-remaster-unpack-rootfs
silentsudo 'Removing Win32 files'           uck-remaster-remove-win32-files

silentsudo 'Setting default language'       sh -c "echo ru > \"${iso_dir}\"/isolinux/lang"

if isdebain
then
    silentsudo '[DEB] removing mtab'        rm "${rootfs_dir}/etc/mtab"
fi

## Preparing customization scripts ---------------------------------------------

silentsudo 'Removing Tools dir'             rm -rf   "${rootfs_dir}/tools"
silentsudo 'Creating Tools dir'             mkdir -p "${rootfs_dir}/tools"
silentsudo 'Creating Files dir'             mkdir -p "${rootfs_dir}/tools/files"

silentsudo 'Copying functions script'       cp -f "${ROOT_PATH}/functions.sh" "${rootfs_dir}/tools/"
silentsudo 'Copying folders script'         cp -f "${ROOT_PATH}/folders.sh"   "${rootfs_dir}/tools/"

silentsudo 'Copying create script'          cp -f "${ROOT_PATH}/custom/tools/${config}/create.sh" "${rootfs_dir}/tools/"

## Executing custom config script ----------------------------------------------

if test -f "${ROOT_PATH}/custom/tools/${config}/custom.sh"
then
    . "${ROOT_PATH}/custom/tools/${config}/custom.sh"
fi

## Executing create script -----------------------------------------------------

sudo                                        uck-remaster-chroot-rootfs "${remaster_dir}" echo -n
sudo                                        uck-remaster-chroot-rootfs "${remaster_dir}" bash /tools/create.sh

silentsudo 'Removing create script'         rm -rf "${rootfs_dir}/tools/create.sh"

## Copying user script ---------------------------------------------------------

silentsudo 'Copying user script'            cp -f "${ROOT_PATH}/custom/tools/${config}/user.sh" "${rootfs_dir}/tools/"

## Finalizing customization ----------------------------------------------------

silentsudo 'Changing tools mode'            chmod -R 777 "${rootfs_dir}/tools"

## Packing image ---------------------------------------------------------------

silentsudo 'Packing rootfs'                 uck-remaster-pack-rootfs -c

if isdebain
then
    silentsudo '[DEB] Moving squashfs back' mv "${iso_dir}/casper" "${iso_dir}/live"
fi

silentsudo 'Packing iso'                    uck-remaster-pack-iso "$(basename "${iso_src}")" -h -g -d "Custom"

