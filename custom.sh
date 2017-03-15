#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

shopt -s extglob

clear
clear

. "${ROOT_PATH}/functions.sh"
. "${ROOT_PATH}/chroot.sh"

#### functions =================================================================

function isdebian()
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

function packiso()
{
    iso_name="${config}-$1"
    iso_description="$2"

    silentsudo 'calculating md5' find "${iso_dir}/" -type f -print0 \
        | grep --null-data -v -E '/isolinux/isolinux.bin|/isolinux/boot.cat|/md5sum.txt|/.checksum.md5|/manifest.diff' \
        | xargs -0 md5sum 2>/dev/null \
        | sed "s/$(safestring "${iso_dir}")/\./g" || exit 1

    silentsudo 'Making dir for iso' mkdir -p "${res_dir}"

    if [[ -e "${res_dir}/${iso_name}" ]]
    then
        silentsudo 'Removing old iso' rm -f "${res_dir}/${iso_name}"
    fi

    silentsudo 'Generating iso' genisoimage -o "${res_dir}/${iso_name}" \
        -b "isolinux/isolinux.bin" \
        -c "isolinux/boot.cat" \
        -p "Dmitry Sorokin" -V "${iso_description}" \
        -no-emul-boot -boot-load-size 4 -boot-info-table \
        -cache-inodes -r -J -l \
        -x "${iso_dir}"/${livedir}/manifest.diff \
        -joliet-long \
        "${iso_dir}" || exit 1

    silentsudo 'Making iso hybrid' isohybrid "${res_dir}/${iso_name}" || exit 1

    if [[ -e "${res_dir}/${iso_name}.md5" ]]
    then
        silentsudo 'Removing old iso md5' rm -f "${res_dir}/${iso_name}.md5"
    fi

    silentsudo 'Generating md5 for iso' bash -c "md5sum \"${res_dir}/${iso_name}\" > \"${res_dir}/${iso_name}.md5\""

    silentsudo 'Changing rights for iso' chmod -R a+rw "${res_dir}"
}

#### ===========================================================================
#### ===========================================================================
#### ===========================================================================

### Launching as root ==========================================================

if [[ $(id -u) -ne 0 ]]
then
    echo 'Launching as root'
    sudo bash $0 $@
    exit $?
fi

### Test internet connection ===================================================

title 'testing internet connection'

if conntest
then
    msgdone
else
    msgfail
    exit 1
fi

### Check required packages installed ==========================================

if ! ispkginstalled 'syslinux-utils'
then
    appinstall 'Syslinux tools' 'syslinux-utils' || exit 1
fi

if ! ispkginstalled 'squashfs-tools'
then
    appinstall 'Squashfs tools' 'squashfs-tools' || exit 1
fi

if ! ispkginstalled 'genisoimage'
then
    appinstall 'ISO tools' 'genisoimage' || exit 1
fi

### Getting parameters =========================================================

configs="@($(ls -1 "${ROOT_PATH}/custom/tools" | tr '\n' '|' | sed 's/|$//'))"

while [[ $# -gt 0 ]]
do

    case "$1" in

    '--debug')
        debug='y'
    ;;

    '--ram')
        useram='1'
    ;;

    *.iso)
        iso_src="$1"
    ;;

    ${configs})
        config="$1"
    ;;

    esac

    shift

done

remaster_dir="/remaster/${config}"
iso_dir="${remaster_dir}/remaster-iso"
rootfs_dir="${remaster_dir}/remaster-root"
res_dir="/media/documents/Distrib/OS/custom"

common_file_path="${ROOT_PATH}/files"
custom_file_path="${ROOT_PATH}/custom/files/${config}"

if isdebian
then
    livedir='live'
else
    livedir='casper'
fi

### Check available ram ========================================================

if [[ -z "${useram}" ]]
then

    freemem=$(cat /proc/meminfo | grep MemAvailable | cut -d ":" -f 2 | sed 's/[^0-9]//g')

    if [[ $freemem -gt 12*1024*1024 ]]
    then
        let useram=1
    else
        let useram=0
    fi

fi

unset freemem

#### Checking parameters =======================================================

## Checking iso image file -----------------------------------------------------

checkfilemime 'image file' "${iso_src}" 'application/x-iso9660-image' 'iso image'

## Checking config directory ---------------------------------------------------

checkfilemime 'functions script'    "${ROOT_PATH}/functions.sh" 'text/x-shellscript' 'shell script'
checkfilemime 'folders script'      "${ROOT_PATH}/folders.sh"   'text/x-shellscript' 'shell script'

checkfilemime 'create script'       "${ROOT_PATH}/custom/tools/${config}/create.sh"  'text/x-shellscript' 'shell script'
checkfilemime 'config script'       "${ROOT_PATH}/custom/tools/${config}/config.sh"  'text/x-shellscript' 'shell script'
checkfilemime 'user script'         "${ROOT_PATH}/custom/tools/${config}/user.sh"    'text/x-shellscript' 'shell script'

### Showing parameters =========================================================

echo

echo "config:       ${config}"
echo "iso image:    ${iso_src}"
echo "remaster dir: ${remaster_dir}"
echo "rootfs dir:   ${livedir}"

echo -n "use ram:      "
if [[ $useram -eq 1 ]]
then
    msgdone 'yes'
else
    msgwarn 'no'
fi

if [[ "$debug" == 'y' ]]
then
    echo -n "debug:        "
    msgwarn 'yes'
fi

read

### Showing bundles ============================================================

bundlelist

read

### Unpacking image ============================================================

while [[ -n "$(mount | grep /remaster)" ]]
do
    umountpath=$(mount  | grep /remaster | head -n1 | cut -d ' ' -f 3)
    [[ -z "${umountpath}" ]] && break

    silentsudo "unmounting ${umountpath}" umount -l "${umountpath}"
done

silentsudo 'Removing old CD'                rm -rf "${remaster_dir}"
silentsudo 'Creating remaster directory'    mkdir -p "${remaster_dir}"

if [[ $useram -eq 1 ]]
then
    silentsudo 'Creating TMPFS for remaster' mount -t tmpfs -o size=12G tmpfs "${remaster_dir}"
fi

## Unpacking ISO ---------------------------------------------------------------

silentsudo '' umount /mnt
silentsudo 'Mounting iso' mount -o loop "${iso_src}" /mnt || exit 1
silentsudo 'Creating directory for image' mkdir -p "${iso_dir}" || exit 1

silentsudo 'Unpacking iso'                  rsync --exclude=/${livedir}/filesystem.squashfs -a /mnt/ "${iso_dir}/" || exit 1
silentsudo 'Removing Win32 files'           rm -rf ${iso_dir}/*.exe ${iso_dir}/*.ini ${iso_dir}/*.inf ${iso_dir}/*.ico ${iso_dir}/*.bmp ${iso_dir}/programs ${iso_dir}/bin ${iso_dir}/disctree ${iso_dir}/pics

## Unpacking SquashFS ----------------------------------------------------------

silentsudo 'Unpacking rootfs' unsquashfs -f -d "${rootfs_dir}" "/mnt/${livedir}/filesystem.squashfs" || exit 1

## -----------------------------------------------------------------------------

silentsudo 'Unmounting iso' umount /mnt

### Generating custom CD =======================================================

## Preparing -------------------------------------------------------------------

silentsudo 'Setting default language'       sh -c "echo ru > \"${iso_dir}\"/isolinux/lang"

if [[ -e "${rootfs_dir}/etc/udev/rules.d/80-net-setup-link.rules" || -e /lib/udev/rules.d/80-net-setup-link.rules ]]
then
    silentsudo 'Disabling the assignment of fixed interface names' ln -sf /dev/null "${rootfs_dir}/etc/udev/rules.d/80-net-setup-link.rules"
fi

## Preparing customization scripts ---------------------------------------------

silentsudo 'Removing Tools dir'             rm -rf   "${rootfs_dir}/tools" || exit 1
silentsudo 'Creating Tools dir'             mkdir -p "${rootfs_dir}/tools" || exit 1
silentsudo 'Creating Files dir'             mkdir -p "${rootfs_dir}/tools/files" || exit 1

silentsudo 'Copying functions script'       cp -f "${ROOT_PATH}/functions.sh" "${rootfs_dir}/tools/" || exit 1
silentsudo 'Copying folders script'         cp -f "${ROOT_PATH}/folders.sh"   "${rootfs_dir}/tools/" || exit 1

silentsudo 'Copying create script'          cp -f "${ROOT_PATH}/custom/tools/${config}/create.sh" "${rootfs_dir}/tools/" || exit 1
silentsudo 'Copying config script'          cp -f "${ROOT_PATH}/custom/tools/${config}/config.sh" "${rootfs_dir}/tools/" || exit 1

silentsudo 'Copying usersboot script'       cp -f "${ROOT_PATH}/startup.sh" "${rootfs_dir}/tools/" || exit 1

silentsudo 'Copying bundle scripts'         cp -rf "${ROOT_PATH}/bundles" "${rootfs_dir}/tools/" || exit 1

silentsudo 'Copying firstboot service'      cp -f "${ROOT_PATH}/files/startup/custom-startup.service" "${rootfs_dir}/tools/files" || exit 1
silentsudo 'Copying firstboot service'      cp -f "${ROOT_PATH}/files/startup/enable-startup.sh" "${rootfs_dir}/tools" || exit 1

## Executing custom config script ----------------------------------------------

if test -f "${ROOT_PATH}/custom/tools/${config}/prepare.sh"
then
    . "${ROOT_PATH}/custom/tools/${config}/prepare.sh"
else
   msgwarn '[no prepare script]'
fi

## Executing create script -----------------------------------------------------

start_chroot "${rootfs_dir}"

chroot_rootfs "${rootfs_dir}" bash /tools/create.sh
chroot_rootfs "${rootfs_dir}" bash /tools/config.sh
chroot_rootfs "${rootfs_dir}" apt-get autoremove --yes --force-yes -qq
chroot_rootfs "${rootfs_dir}" bash /tools/enable-startup.sh

if [[ "$debug" == 'y' ]]
then
    chroot_rootfs "${rootfs_dir}" bash
fi

finish_chroot "${rootfs_dir}"

silentsudo 'Removing create script'         rm -rf "${rootfs_dir}/tools/create.sh"
silentsudo 'Removing config script'         rm -rf "${rootfs_dir}/tools/create.sh"
silentsudo 'Removing statrup gen script'    rm -rf "${rootfs_dir}/tools/enable-startup.sh"

## Copying first boot script ---------------------------------------------------

silentsudo 'Copying first boot script'      cp -f "${ROOT_PATH}/custom/tools/${config}/firstboot.sh" "${rootfs_dir}/tools/"

## Copying user script ---------------------------------------------------------

silentsudo 'Copying user script'            cp -f "${ROOT_PATH}/custom/tools/${config}/user.sh" "${rootfs_dir}/tools/"

## Finalizing customization ----------------------------------------------------

silentsudo 'Changing tools mode'            chmod -R 777 "${rootfs_dir}/tools"

## Packing image ===============================================================

## Pack rootfs -----------------------------------------------------------------

silentsudo 'Updating package list' bash -c "chroot "${rootfs_dir}" dpkg-query -W --showformat='${Package} ${Version}\n' > \"${iso_dir}/${livedir}/filesystem.manifest\""

if [[ -e "${iso_dir}/${livedir}/manifest.diff" ]]
then
    silentsudo 'Getting versions from manifest' bash -c "cat \"${iso_dir}/${livedir}/filesystem.manifest\" | cut -d ' ' -f 1 > \"${iso_dir}/filesystem.manifest.tmp\""
    silentsudo 'Diff manifests'                 bash -c "diff --unchanged-group-format='' \"${iso_dir}/filesystem.manifest.tmp\" \"${iso_dir}/${livedir}/manifest.diff\" > \"${iso_dir}/filesystem.manifest-desktop.tmp\""
    silentsudo 'Building manifest desktop file' bash -c "chroot \"${rootfs_dir}\"  dpkg-query -W --showformat='${Package} ${Version}\n' $(cat "${iso_dir}/filesystem.manifest-desktop.tmp") | egrep '.+ .+' > \"${iso_dir}/${livedir}/filesystem.manifest-desktop\""
    silentsudo 'Removing temp files'            bash -c "rm \"${iso_dir}/filesystem.manifest.tmp\" \"${iso_dir}/filesystem.manifest-desktop.tmp\""
else
   silentsudo 'Creating desktop manifest' cp -f "${iso_dir}/${livedir}/filesystem.manifest" "${iso_dir}/${livedir}/filesystem.manifest-desktop"
fi

if [[ -e "${iso_dir}/${livedir}/filesystem.squashfs" ]]
then
    silentsudo 'Removing old rootfs' rm -f "${iso_dir}/${livedir}/filesystem.squashfs"
fi

silentsudo 'Packing rootfs' mksquashfs "${rootfs_dir}" "${iso_dir}/${livedir}/filesystem.squashfs" || exit 1

## Modify package manifest -----------------------------------------------------

if grep '^cifs-utils$' "${iso_dir}/${livedir}/filesystem.manifest-remove" > /dev/null 2>&1
then
    silentsudo 'Removing cifs-utils from remove manifest' sed -i '/^cifs-utils$/d' "${iso_dir}/${livedir}/filesystem.manifest-remove"
fi

## Adding EFI x32 --------------------------------------------------------------

if test -d "${iso_dir}/EFI/BOOT" && ! isdebian
then
    silentsudo 'Getting EFI 32 image'       wget https://github.com/jfwells/linux-asus-t100ta/raw/master/boot/bootia32.efi -O "${iso_dir}/EFI/BOOT/bootia32.efi"
fi

## Packing ISO -----------------------------------------------------------------

packiso "$(basename "${iso_src}")" "${config}"

### Unmounting remaster dir ====================================================

if [[ $useram -eq 1 ]]
then
    silentsudo 'Unmounting remaster dir' umount -l "${remaster_dir}"
fi
