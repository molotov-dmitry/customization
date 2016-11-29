#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

clear
clear

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

function unpackiso()
{
    isopath="$1"

    silentsudo '' umount /mnt
    silentsudo 'Mounting iso' mount -o loop "${isopath}" /mnt || exit 1
    silentsudo 'Creating directory for image' mkdir -p "${iso_dir}" || exit 1
    silentsudo 'Unpacking iso' cp -rfa /mnt/. "${iso_dir}" || exit 1
    silentsudo 'Unmounting iso' umount /mnt
}

function unpackroot()
{
    silentsudo 'Unpacking rootfs' unsquashfs -f -d "${rootfs_dir}" "${iso_dir}/casper/filesystem.squashfs" || exit 1
}

function packroot()
{
    silentsudo 'Updating package list' bash -c "chroot "${rootfs_dir}" dpkg-query -W --showformat='${Package} ${Version}\n' > \"${iso_dir}/casper/filesystem.manifest\""

    if [[ -e "${iso_dir}/casper/manifest.diff" ]]
    then
        silentsudo 'Getting versions from manifest' bash -c "cat \"${iso_dir}/casper/filesystem.manifest\" | cut -d ' ' -f 1 > \"${iso_dir}/filesystem.manifest.tmp\""
        silentsudo 'Diff manifests'                 bash -c "diff --unchanged-group-format='' \"${iso_dir}/filesystem.manifest.tmp\" \"${iso_dir}/casper/manifest.diff\" > \"${iso_dir}/filesystem.manifest-desktop.tmp\""
        silentsudo 'Building manifest desktop file' bash -c "chroot \"${rootfs_dir}\"  dpkg-query -W --showformat='${Package} ${Version}\n' $(cat "${iso_dir}/filesystem.manifest-desktop.tmp") | egrep '.+ .+' > \"${iso_dir}/casper/filesystem.manifest-desktop\""
        silentsudo 'Removing temp files'            bash -c "rm \"${iso_dir}/filesystem.manifest.tmp\" \"${iso_dir}/filesystem.manifest-desktop.tmp\""
    else
        silentsudo 'Creating desktop manifest' cp -f "${iso_dir}/casper/filesystem.manifest" "${iso_dir}/casper/filesystem.manifest-desktop"
    fi

    silentsudo 'Removing old rootfs' rm -f "${iso_dir}/casper/filesystem.squashfs"
    silentsudo 'Packing rootfs' mksquashfs "${rootfs_dir}" "${iso_dir}/casper/filesystem.squashfs" || exit 1
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
        -x "${iso_dir}"/casper/manifest.diff \
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

### Check UCK is installed =====================================================

if ! ispkginstalled 'uck'
then
    appinstall 'UCK' 'uck' || exit 1
fi

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

if ! ispkginstalled qemu || ! ispkginstalled qemu-kvm || ! ispkginstalled qemu-system-x86
then
    appinstall 'QEMU' 'qemu qemu-kvm qemu-system-x86'
fi

### Getting parameters =========================================================

iso_src="$1"
config="$2"

remaster_dir="/tmp/remaster/${config}"
iso_dir="${remaster_dir}/remaster-iso"
rootfs_dir="${remaster_dir}/remaster-root"
res_dir="/media/documents/Distrib/OS/custom"

common_file_path="${ROOT_PATH}/files"
custom_file_path="${ROOT_PATH}/custom/files/${config}"

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

echo "iso image:    ${iso_src}"
echo "remaster dir: ${remaster_dir}"

### Showing bundles ============================================================

bundlelist

read

### Generating custom CD =======================================================

## Preparing -------------------------------------------------------------------

silentsudo 'Removing old CD'                rm -rf "${remaster_dir}"

unpackiso                                   "${iso_src}"

if isdebian
then
    silentsudo '[DEB] Moving squashfs'      mv "${iso_dir}/live" "${iso_dir}/casper"
fi

unpackroot

silentsudo 'Removing Win32 files'           uck-remaster-remove-win32-files

silentsudo 'Setting default language'       sh -c "echo ru > \"${iso_dir}\"/isolinux/lang"

if [[ -e "${rootfs_dir}/etc/resolv.conf" ]]
then
    silentsudo 'backing up resolv.conf'     mv -f "${rootfs_dir}/etc/resolv.conf" "${rootfs_dir}/etc/resolv.conf.bak"
fi

if isdebian
then
#    silentsudo '[DEB] copying resolv.conf'  cp /etc/resolv.conf "${rootfs_dir}/etc/resolv.conf"
    silentsudo '[DEB] removing mtab'        rm "${rootfs_dir}/etc/mtab"
fi

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

sudo                                        uck-remaster-chroot-rootfs "${remaster_dir}" echo -n
sudo                                        uck-remaster-chroot-rootfs "${remaster_dir}" bash /tools/create.sh
sudo                                        uck-remaster-chroot-rootfs "${remaster_dir}" bash /tools/config.sh
sudo                                        uck-remaster-chroot-rootfs "${remaster_dir}" bash /tools/enable-startup.sh

silentsudo 'Removing create script'         rm -rf "${rootfs_dir}/tools/create.sh"
silentsudo 'Removing config script'         rm -rf "${rootfs_dir}/tools/create.sh"
silentsudo 'Removing statrup gen script'    rm -rf "${rootfs_dir}/tools/enable-startup.sh"

## Cleaning up chroot ----------------------------------------------------------

if [[ -e "${rootfs_dir}/etc/resolv.conf.bak" ]]
then
    silentsudo 'Restoring resolv.conf'      mv -f "${rootfs_dir}/etc/resolv.conf.bak" "${rootfs_dir}/etc/resolv.conf"
fi

## Copying first boot script ---------------------------------------------------

silentsudo 'Copying first boot script'      cp -f "${ROOT_PATH}/custom/tools/${config}/firstboot.sh" "${rootfs_dir}/tools/"

## Copying user script ---------------------------------------------------------

silentsudo 'Copying user script'            cp -f "${ROOT_PATH}/custom/tools/${config}/user.sh" "${rootfs_dir}/tools/"

## Finalizing customization ----------------------------------------------------

silentsudo 'Changing tools mode'            chmod -R 777 "${rootfs_dir}/tools"

## Packing image ---------------------------------------------------------------

packroot

if grep '^cifs-utils$' "${iso_dir}/casper/filesystem.manifest-remove" > /dev/null 2>&1
then
    silentsudo 'Removing cifs-utils from remove manifest' sed -i '/^cifs-utils$/d' "${iso_dir}/casper/filesystem.manifest-remove"
fi

if isdebian
then
    silentsudo '[DEB] Moving squashfs back' mv "${iso_dir}/casper" "${iso_dir}/live"
fi

## Adding EFI x32 --------------------------------------------------------------

if test -d "${iso_dir}/EFI/BOOT" && ! isdebian
then
    silentsudo 'Getting EFI 32 image'       wget https://github.com/jfwells/linux-asus-t100ta/raw/master/boot/bootia32.efi -O "${iso_dir}/EFI/BOOT/bootia32.efi"
fi

## Packing ISO -----------------------------------------------------------------

packiso "$(basename "${iso_src}")" "${config}"

