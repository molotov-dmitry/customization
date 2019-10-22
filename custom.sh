#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

shopt -s extglob

clear
clear

. "${ROOT_PATH}/functions.sh"
. "${ROOT_PATH}/tools/chroot.sh"
. "${ROOT_PATH}/tools/check.sh"
. "${ROOT_PATH}/tools/pack.sh"

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

    '--noram')
        useram='0'
    ;;

    '--fast')
        fastcomp='1'
    ;;

    '--test')
        nobuild='y'
    ;;

    '--quiet')
        nobeep='y'
    ;;

    '--no-progress')
        noprogress='y'
    ;;

    '--notify')
        notify='y'
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

remaster_dir="/remaster"
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

if [[ ${fastcomp} -eq 0 ]]
then
    comp=xz
else
    comp=gzip
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

#checkfilemime 'image file' "${iso_src}" 'application/x-iso9660-image' 'iso image'

## Checking config directory ---------------------------------------------------

checkfilemime 'functions script'    "${ROOT_PATH}/functions.sh" 'text/x-shellscript'    'shell script'
checkfilemime 'folders script'      "${ROOT_PATH}/tools/folders.sh"                     'text/x-shellscript' 'shell script'

checkfilemime 'create script'       "${ROOT_PATH}/custom/tools/${config}/create.sh"     'text/x-shellscript' 'shell script'
checkfilemime 'config script'       "${ROOT_PATH}/custom/tools/${config}/config.sh"     'text/x-shellscript' 'shell script'
checkfilemime 'user script'         "${ROOT_PATH}/custom/tools/${config}/user.sh"       'text/x-shellscript' 'shell script'

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

if [[ "$nobuild" == 'y' ]]
then
    echo -n "skip mkfs:    "
    msgwarn 'yes'
fi

if [[ "$nobeep" == 'y' ]]
then
    echo -n "no beep:      "
    msgwarn 'yes'
fi

if [[ "$noprogress" == 'y' ]]
then
    echo -n "no progress:  "
    msgwarn 'yes'
fi

echo "compress:     ${comp}"

read

### Showing bundles ============================================================

bundlelist

read

### Unpack image ===============================================================

while [[ -n "$(mount | grep /remaster)" ]]
do
    umountpath=$(mount  | grep /remaster | head -n1 | cut -d ' ' -f 3)
    [[ -z "${umountpath}" ]] && break

    silent "unmounting ${umountpath}" umount -l "${umountpath}"
done

silent 'Removing old CD'                rm -rf "${remaster_dir}"
silent 'Creating remaster directory'    mkdir -p "${remaster_dir}"

if [[ $useram -eq 1 ]]
then
    silent 'Creating TMPFS for remaster' mount -t ramfs -o size=12G ramfs "${remaster_dir}"
fi

## Unpacking ISO ---------------------------------------------------------------

silent '' umount /mnt
silent 'Mounting iso' mount -o loop "${iso_src}" /mnt || exit 1
silent 'Creating directory for image' mkdir -p "${iso_dir}" || exit 1

silent 'Unpacking iso'                  rsync --exclude=/${livedir}/filesystem.squashfs -a /mnt/ "${iso_dir}/" || exit 1
silent 'Removing Win32 files'           rm -rf ${iso_dir}/*.exe ${iso_dir}/*.ini ${iso_dir}/*.inf ${iso_dir}/*.ico ${iso_dir}/*.bmp ${iso_dir}/programs ${iso_dir}/bin ${iso_dir}/disctree ${iso_dir}/pics

## Unpacking SquashFS ----------------------------------------------------------

silent 'Unpacking rootfs' unsquashfs -f -d "${rootfs_dir}" "/mnt/${livedir}/filesystem.squashfs" || exit 1

## -----------------------------------------------------------------------------

silent 'Unmounting iso' umount /mnt

### Generating custom CD =======================================================

## Preparing -------------------------------------------------------------------

silent 'Setting default language'       sh -c "echo ru > \"${iso_dir}\"/isolinux/lang"

if isdebian
then
        silent '[DEB] Disabling fixed interface names' ln -sf /dev/null "${rootfs_dir}/etc/systemd/network/99-default.link"
else
    if [[ -e "${rootfs_dir}/etc/udev/rules.d/80-net-setup-link.rules" || -e /lib/udev/rules.d/80-net-setup-link.rules ]]
    then
        silent 'Disabling fixed interface names' ln -sf /dev/null "${rootfs_dir}/etc/udev/rules.d/80-net-setup-link.rules"
    fi
fi

if [[ -e "${rootfs_dir}/etc/apt/sources.list.d/base.list" && ! -e "${rootfs_dir}/etc/apt/sources.list" ]]
then
	silent 'Move sources.list' mv "${rootfs_dir}/etc/apt/sources.list.d/base.list" "${rootfs_dir}/etc/apt/sources.list"
fi

## Preparing user customization script -----------------------------------------

title 'Creating user configuration script directory'

mkdir -p "${rootfs_dir}/etc/usercustom.d" || exit 1

cat >> "${rootfs_dir}/etc/skel/.profile" << "_EOF" || exit 1

for f in /etc/usercustom.d/*
do
    test -f "$f" && source "$f"
done
_EOF

msgdone

## Preparing customization scripts ---------------------------------------------

silent 'Removing Tools dir'             rm -rf   "${rootfs_dir}/tools" || exit 1
silent 'Creating Tools dir'             mkdir -p "${rootfs_dir}/tools" || exit 1
silent 'Creating Files dir'             mkdir -p "${rootfs_dir}/tools/files" || exit 1
silent 'Creating Bundle dir'            mkdir -p "${rootfs_dir}/tools/custom/tools" || exit 1

silent 'Copying functions script'       cp -f "${ROOT_PATH}/functions.sh"     "${rootfs_dir}/tools/" || exit 1
silent 'Copying folders script'         cp -f "${ROOT_PATH}/tools/folders.sh" "${rootfs_dir}/tools/" || exit 1
silent 'Copying bundle script'          cp -f "${ROOT_PATH}/tools/bundle.sh"  "${rootfs_dir}/tools/" || exit 1
silent 'Copying remove script'          cp -f "${ROOT_PATH}/tools/remove.sh"  "${rootfs_dir}/tools/" || exit 1
silent 'Copying prepare script'         cp -f "${ROOT_PATH}/tools/prepare.sh" "${rootfs_dir}/tools/" || exit 1
silent 'Copying mirror script'          cp -f "${ROOT_PATH}/tools/mirror.sh"  "${rootfs_dir}/tools/" || exit 1

silent 'Copying repo script'            cp -f "${ROOT_PATH}/custom/tools/${config}/repo.sh"   "${rootfs_dir}/tools/" || exit 1
silent 'Copying create script'          cp -f "${ROOT_PATH}/custom/tools/${config}/create.sh" "${rootfs_dir}/tools/" || exit 1
silent 'Copying config script'          cp -f "${ROOT_PATH}/custom/tools/${config}/config.sh" "${rootfs_dir}/tools/" || exit 1

silent 'Copying usersboot script'       cp -f "${ROOT_PATH}/tools/startup.sh" "${rootfs_dir}/tools/" || exit 1

silent 'Copying bundle scripts'         cp -rf "${ROOT_PATH}/bundles" "${rootfs_dir}/tools/" || exit 1

silent 'Copying bundles list'           cp -f "${ROOT_PATH}/custom/tools/${config}.bundle" "${rootfs_dir}/tools/custom/tools/" || exit 1
silent 'Copying bundles list'           cp -f "${ROOT_PATH}/custom/tools/${config}.bundle" "${rootfs_dir}/tools/custom/tools/firstboot.bundle" || exit 1
silent 'Copying bundles list'           cp -f "${ROOT_PATH}/custom/tools/${config}.bundle" "${rootfs_dir}/tools/custom/tools/user.bundle" || exit 1

silent 'Copying firstboot service'      cp -f "${ROOT_PATH}/files/startup/custom-startup.service" "${rootfs_dir}/tools/files" || exit 1
silent 'Copying firstboot service'      cp -f "${ROOT_PATH}/files/startup/enable-startup.sh" "${rootfs_dir}/tools" || exit 1

## Executing custom config script ----------------------------------------------

if test -f "${ROOT_PATH}/custom/tools/${config}/prepare.sh"
then
    . "${ROOT_PATH}/custom/tools/${config}/prepare.sh"
    . "${ROOT_PATH}/tools/bundle.sh" prepare "${config}"
else
   msgwarn '[no prepare script]'
fi

## Executing create script -----------------------------------------------------

start_chroot "${rootfs_dir}"

chroot_rootfs "${rootfs_dir}" bash /tools/remove.sh
chroot_rootfs "${rootfs_dir}" bash /tools/prepare.sh

chroot_rootfs "${rootfs_dir}" bash /tools/repo.sh
chroot_rootfs "${rootfs_dir}" bash /tools/bundle.sh repo "${config}"
chroot_rootfs "${rootfs_dir}" bash /tools/mirror.sh

chroot_rootfs "${rootfs_dir}" bash /tools/create.sh
chroot_rootfs "${rootfs_dir}" bash /tools/bundle.sh install "${config}"

chroot_rootfs "${rootfs_dir}" bash /tools/config.sh
chroot_rootfs "${rootfs_dir}" bash /tools/bundle.sh config "${config}"

chroot_rootfs "${rootfs_dir}" apt-get autoremove --yes -qq || exit 1

chroot_rootfs "${rootfs_dir}" bash /tools/enable-startup.sh

if [[ "$debug" == 'y' ]]
then
    chroot_rootfs "${rootfs_dir}" bash
fi

if [[ $(lsof -t "${remaster_dir}" | wc -l) -gt 0 ]]
then
    silent 'Killing remaining processes' kill $(lsof -t "${remaster_dir}")
fi

finish_chroot "${rootfs_dir}"

## Clean up after chroot step --------------------------------------------------

silent 'Removing remove script'         rm -rf "${rootfs_dir}/tools/remove.sh"
silent 'Removing prepare script'        rm -rf "${rootfs_dir}/tools/prepare.sh"
silent 'Removing repo script'           rm -rf "${rootfs_dir}/tools/repo.sh"
silent 'Removing mirror script'         rm -rf "${rootfs_dir}/tools/mirror.sh"
silent 'Removing create script'         rm -rf "${rootfs_dir}/tools/create.sh"
silent 'Removing config script'         rm -rf "${rootfs_dir}/tools/config.sh"
silent 'Removing statrup gen script'    rm -rf "${rootfs_dir}/tools/enable-startup.sh"

silent 'Removing bundle list'           rm -f  "${rootfs_dir}/tools/custom/tools/${config}.bundle"

## Copying first boot script ---------------------------------------------------

silent 'Copying first boot script'      cp -f "${ROOT_PATH}/custom/tools/${config}/firstboot.sh" "${rootfs_dir}/tools/"

## Copying user script ---------------------------------------------------------

silent 'Copying user script'            cp -f "${ROOT_PATH}/custom/tools/${config}/user.sh" "${rootfs_dir}/tools/"

## Finalizing customization ----------------------------------------------------

silent 'Changing tools mode'            chmod -R 777 "${rootfs_dir}/tools"

## Packing image ===============================================================

if [[ "$nobuild" != 'y' ]]
then

    ## Pack rootfs -------------------------------------------------------------

    silent 'Updating package list' bash -c "chroot "${rootfs_dir}" dpkg-query -W --showformat='${Package} ${Version}\n' > \"${iso_dir}/${livedir}/filesystem.manifest\""

    if [[ -e "${iso_dir}/${livedir}/manifest.diff" ]]
    then
        silent 'Getting versions from manifest' bash -c "cat \"${iso_dir}/${livedir}/filesystem.manifest\" | cut -d ' ' -f 1 > \"${iso_dir}/filesystem.manifest.tmp\""
        silent 'Diff manifests'                 bash -c "diff --unchanged-group-format='' \"${iso_dir}/filesystem.manifest.tmp\" \"${iso_dir}/${livedir}/manifest.diff\" > \"${iso_dir}/filesystem.manifest-desktop.tmp\""
        silent 'Building manifest desktop file' bash -c "chroot \"${rootfs_dir}\"  dpkg-query -W --showformat='${Package} ${Version}\n' $(cat "${iso_dir}/filesystem.manifest-desktop.tmp") | egrep '.+ .+' > \"${iso_dir}/${livedir}/filesystem.manifest-desktop\""
        silent 'Removing temp files'            bash -c "rm \"${iso_dir}/filesystem.manifest.tmp\" \"${iso_dir}/filesystem.manifest-desktop.tmp\""
    else
        silent 'Creating desktop manifest' cp -f "${iso_dir}/${livedir}/filesystem.manifest" "${iso_dir}/${livedir}/filesystem.manifest-desktop"
    fi

    if [[ -e "${iso_dir}/${livedir}/filesystem.squashfs" ]]
    then
        silent 'Removing old rootfs' rm -f "${iso_dir}/${livedir}/filesystem.squashfs"
    fi

    if [[ "$noprogress" == 'y' ]]
    then
        silent 'build rootfs' mksquashfs "${rootfs_dir}" "${iso_dir}/${livedir}/filesystem.squashfs" -comp ${comp} || exit 1
    else
        mksquashfs "${rootfs_dir}" "${iso_dir}/${livedir}/filesystem.squashfs" -comp ${comp} || exit 1
    fi

    ## Modify package manifest -------------------------------------------------

    if grep '^sudo$' "${iso_dir}/${livedir}/filesystem.manifest-remove" > /dev/null 2>&1
    then
        silent 'Removing sudo from remove manifest'       sed -i '/^sudo$/d' "${iso_dir}/${livedir}/filesystem.manifest-remove"
    fi

    if grep '^cifs-utils$' "${iso_dir}/${livedir}/filesystem.manifest-remove" > /dev/null 2>&1
    then
        silent 'Removing cifs-utils from remove manifest' sed -i '/^cifs-utils$/d' "${iso_dir}/${livedir}/filesystem.manifest-remove"
    fi

    ## Adding EFI x32 ----------------------------------------------------------

    if test -d "${iso_dir}/EFI/BOOT" && ! isdebian
    then
        silent 'Getting EFI 32 image'       wget https://github.com/jfwells/linux-asus-t100ta/raw/master/boot/bootia32.efi -O "${iso_dir}/EFI/BOOT/bootia32.efi"
    fi

    ## Packing ISO -------------------------------------------------------------

    packiso "$(basename "${iso_src}")" "${config}"

fi

### Unmounting remaster dir ====================================================

if [[ $useram -eq 1 ]]
then
    silent 'Unmounting remaster dir' umount "${remaster_dir}"
    silent 'Dropping cached memory' su -c 'echo 3 > /proc/sys/vm/drop_caches'
fi

### Send notify ================================================================

if [[ "$notify" == 'y' ]]
then
    echo "media-optical:${config}-$(basename "${iso_src}") build completed" | nc -b -w1 -u 255.255.255.255 14993
fi

### Finish signal ==============================================================

if [[ "$nobeep" != 'y' ]]
then
    silent '' beep -f 2050 -r 2 -d 100 -l 30
fi

