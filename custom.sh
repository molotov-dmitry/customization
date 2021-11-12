#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

shopt -s extglob

clear
clear

. "${ROOT_PATH}/functions.sh"
. "${ROOT_PATH}/tools/chroot.sh"
. "${ROOT_PATH}/tools/pack.sh"

#### Functions =================================================================

isdebian()
{
    if [[ "$(basename "${iso_src}")" == debian* ]]
    then
        return 0
    else
        return 1
    fi
}

placescript()
{
    local name="$1"
    local sourcefile="${ROOT_PATH}/custom/tools/${config}/${name}.sh"
    local destfile="${rootfs_dir}/tools/${name}.sh"

    title "Copy ${name} script"

    if [[ -f "${sourcefile}" ]]
    then
        cp -f "${sourcefile}" "${destfile}" >/dev/null 2>/dev/null
        local result=$?

        if [[ $result -eq 0 ]]
        then
            msgdone
        else
            msgfail
        fi
    else
        touch "${destfile}" >/dev/null 2>/dev/null
        local result=$?

        if [[ $result -eq 0 ]]
        then
            msgwarn '[missing]'
        else
            msgfail
        fi
    fi

    return $result
}

chroot_script()
{
    local rootfs_dir="$1"
    local name="$2"
    local config="$3"

    shift
    shift
    shift

    if [[ -z "$config" ]]
    then
        silent "Copy ${name} script" cp -f "${ROOT_PATH}/tools/${name}.sh" "${rootfs_dir}/tools/" || return 1

    elif [[ -f "${ROOT_PATH}/custom/tools/${config}/${name}.sh" ]]
    then
        silent "Copy ${name} script" cp -f "${ROOT_PATH}/custom/tools/${config}/${name}.sh" "${rootfs_dir}/tools/" || return 1

    else
        title "Copy ${name} script"
        msgwarn '[missing]'
    fi

    if [[ -f "${rootfs_dir}/tools/${name}.sh" ]]
    then
        chroot_rootfs "${rootfs_dir}" bash "/tools/${name}.sh" "$@"
    fi

    if [[ -n "$config" ]]
    then
        chroot_rootfs "${rootfs_dir}" bash /tools/bundle.sh "${name}" "${config}"
    fi

    if [[ -f "${rootfs_dir}/tools/${name}.sh" ]]
    then
        silent "Remove ${name} script" rm -rf "${rootfs_dir}/tools/${name}.sh" || return 1
    fi

    return 0
}

#### ===========================================================================
#### ===========================================================================
#### ===========================================================================

### Launching as root ==========================================================

if [[ $(id -u) -ne 0 ]]
then
    echo 'Launching as root'
    sudo bash $0 "$@"
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

if ! ispkginstalled 'xorriso'
then
    appinstall 'ISO tools' 'xorriso' || exit 1
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
        slowcomp='0'
        fastcomp='1'
    ;;

    '--slow')
        fastcomp='0'
        slowcomp='1'
    ;;

    '--test')
        nobuild='y'
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

unset comp_options

if [[ ${fastcomp} -ne 0 ]]
then
    comp_options='-comp gzip'
    comp='GZip'
elif [[ ${slowcomp} -eq 0 ]]
then
    comp_options='-comp xz'
    comp='XZ normal'
else
    comp_options='-b 1048576 -comp xz -Xdict-size 100%'
    comp='XZ ultra'
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
    silent 'Creating TMPFS for remaster' mount -t tmpfs -o size=12G tmpfs "${remaster_dir}"
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

if [[ -d "${iso_dir}/isolinux" ]]
then
    silent 'Setting default language'       sh -c "echo ru > \"${iso_dir}\"/isolinux/lang"
fi

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

## Copy user files =============================================================

if [[ -d "${ROOT_PATH}/custom/files/${config}" ]]
then
    silent 'Copy config specific files' cp -rf "${ROOT_PATH}/custom/files/${config}/." "${rootfs_dir}/"
fi

## Preparing customization scripts ---------------------------------------------

silent 'Removing Tools dir'             rm -rf   "${rootfs_dir}/tools" || exit 1
silent 'Creating Tools dir'             mkdir -p "${rootfs_dir}/tools" || exit 1
silent 'Creating Files dir'             mkdir -p "${rootfs_dir}/tools/files" || exit 1
silent 'Creating Bundle dir'            mkdir -p "${rootfs_dir}/tools/custom/tools" || exit 1

silent 'Copying functions script'       cp -f "${ROOT_PATH}/functions.sh"     "${rootfs_dir}/tools/" || exit 1
silent 'Copying bundle script'          cp -f "${ROOT_PATH}/tools/bundle.sh"  "${rootfs_dir}/tools/" || exit 1

silent 'Copying bundle scripts'         cp -rf "${ROOT_PATH}/bundles" "${rootfs_dir}/tools/" || exit 1

silent 'Copying bundles list'           cp -f "${ROOT_PATH}/custom/tools/${config}.bundle" "${rootfs_dir}/tools/custom/tools/" || exit 1
silent 'Copying bundles list'           cp -f "${ROOT_PATH}/custom/tools/${config}.bundle" "${rootfs_dir}/tools/custom/tools/firstboot.bundle" || exit 1
silent 'Copying bundles list'           cp -f "${ROOT_PATH}/custom/tools/${config}.bundle" "${rootfs_dir}/tools/custom/tools/firstbootuser.bundle" || exit 1
silent 'Copying bundles list'           cp -f "${ROOT_PATH}/custom/tools/${config}.bundle" "${rootfs_dir}/tools/custom/tools/user.bundle" || exit 1

## Copy startup files ----------------------------------------------------------

silent 'Copy startup files'             cp -rfP "${ROOT_PATH}/tools/startup/." "${rootfs_dir}/" || exit 1

## Executing custom config script ----------------------------------------------

if test -f "${ROOT_PATH}/custom/tools/${config}/prepare.sh"
then
    . "${ROOT_PATH}/custom/tools/${config}/prepare.sh"
else
    title 'Launching prepare script'
    msgwarn '[missing]'
fi

. "${ROOT_PATH}/tools/bundle.sh" prepare "${config}"

## Executing create script -----------------------------------------------------

start_chroot "${rootfs_dir}"

chroot_script "${rootfs_dir}" 'remove'
chroot_script "${rootfs_dir}" 'prepare'
chroot_script "${rootfs_dir}" 'repo' "${config}"
chroot_script "${rootfs_dir}" 'mirror'
chroot_script "${rootfs_dir}" 'install' "${config}"
chroot_script "${rootfs_dir}" 'config' "${config}"
chroot_script "${rootfs_dir}" 'afterbuild'

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

silent 'Removing bundle list'           rm -f  "${rootfs_dir}/tools/custom/tools/${config}.bundle"

## Copying first boot script ---------------------------------------------------

placescript 'firstboot'
placescript 'firstbootuser'
placescript 'user'

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
        silent 'build rootfs' mksquashfs "${rootfs_dir}" "${iso_dir}/${livedir}/filesystem.squashfs" ${comp_options} || exit 1
    else
        mksquashfs "${rootfs_dir}" "${iso_dir}/${livedir}/filesystem.squashfs" ${comp_options} || exit 1
    fi

    ## Modify package manifest -------------------------------------------------

    for pkg in '^sudo$' '^cifs-utils$' '^libgail'
    do
        pkgname="$(echo "$pkg" | tr -d '^$')"

        if grep "${pkg}" "${iso_dir}/${livedir}/filesystem.manifest-remove" > /dev/null 2>&1
        then
            silent "Removing ${pkgname} from remove manifest" sed -i "/${pkg}/d" "${iso_dir}/${livedir}/filesystem.manifest-remove"
        fi
    done

    ## Modify package manifest for minimal installation ------------------------

    if [[ "${config}" == "work" || "${config}" == "develop" || "${config}" == "q190" ]]
    then
        if [[ -f "${iso_dir}/${livedir}/filesystem.manifest-minimal-remove" && -f "${iso_dir}/${livedir}/filesystem.manifest-remove" ]]
        then
            silent 'Creating minimal remove manifest' cp -f "${iso_dir}/${livedir}/filesystem.manifest-remove" "${iso_dir}/${livedir}/filesystem.manifest-minimal-remove"

            for package in ti-cgt ccs-pjt-editor-qt kmx32-gcc kmx32-eclipse
            do
                echo "$package" >> "${iso_dir}/${livedir}/filesystem.manifest-minimal-remove"
            done

            silent 'Updating minimal remove manifest' sed -i '/-ru-/d;/-ru$/d' "${iso_dir}/${livedir}/filesystem.manifest-minimal-remove"
        fi
    fi

    ## Adding EFI x32 ----------------------------------------------------------

    if test -d "${iso_dir}/EFI/BOOT"
    then
        efi_boot_dir='BOOT'

    elif test -d "${iso_dir}/EFI/boot"
    then
        efi_boot_dir='boot'

    else
        efi_boot_dir='BOOT'
        silent 'Creating EFI dir' mkdir -p "${iso_dir}/EFI/${efi_boot_dir}"
    fi

    for efi in bootia32.efi BOOTx64.EFI grubx64.efi mmx64.efi
    do
        if ! test -f "${iso_dir}/EFI/${efi_boot_dir}/${efi}" && ! test -f "${iso_dir}/EFI/${efi_boot_dir}/${efi,,}"
        then
            silent "Downloading ${efi}" wget "https://github.com/molotov-dmitry/efi-images/raw/master/${efi}" -O "${iso_dir}/EFI/${efi_boot_dir}/${efi}"
        fi
    done

    unset efi_boot_dir

    ## Packing ISO -------------------------------------------------------------

    packiso "$(basename "${iso_src}")" "${config}" "${iso_src}"

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
