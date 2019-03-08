#!/bin/bash

function copy_to_rootfs()
{
    dir="$1"
    file="$2"

    if [[ -f "${file}" ]]
    then
        backup "${dir}" "${file}"

        mkdir -p "$(dirname "${dir}/${file}")"
        silent "Copy ${file} to rootfs" cp -f ${file} "${dir}/${file}"
	fi

    return 0
}

function backup()
{
    dir="$1"
    file="$2"

    if [[ -f "${dir}/${file}" ]]
    then
		silent "Backup ${file}" mv -f "${dir}/${file}" "${dir}/${file}.bak"
	fi

    return 0
}

function restore()
{
    dir="$1"
    file="$2"

    if [[ -f "${dir}/${file}.bak" ]]
    then
		silent "Restore ${file}" mv -f "${dir}/${file}.bak" "${dir}/${file}"
    elif [[ -f "${dir}/${file}" ]]
    then
        silent "Removing ${file}" rm -rf "${dir}/${file}"
	fi

    return 0
}

function deactivate()
{
    dir="$1"
    file="$2"

    if [[ -f "${dir}/${file}" ]]
    then
        silent "Deactivating ${file}" chroot "${dir}" bash -c "dpkg-divert --local --rename --add \"${file}\" && ln -s /bin/true \"${file}\""
    fi

    return 0
}

function reactivate()
{
    dir="$1"
    file="$2"

    if [[ -f "${dir}/${file}" ]]
    then
		silent "Reactivating ${file}" chroot "${dir}" bash -c "rm -f \"${file}\"; dpkg-divert --rename --remove \"${file}\""
	fi

    return 0
}

function clear_directory()
{
    dir="$1"
    dir_rm="$2"

    if [[ -e "${dir}/${dir_rm}" ]]
    then
        silent "Clearing ${dir_rm}" find "${dir}/${dir_rm}" -mindepth 1 -delete
    fi

    return 0
}

function start_chroot()
{
    ROOTFS_DIR="$1"

    silent 'Mounting /dev'      mount --bind /dev/ "${ROOTFS_DIR}/dev"

    silent 'Mounting /proc'     chroot "${ROOTFS_DIR}" mount none -t proc   "/proc"
    silent 'Mounting /sys'      chroot "${ROOTFS_DIR}" mount none -t sysfs  "/sys"
    silent 'Mounting /dev/pts'  chroot "${ROOTFS_DIR}" mount none -t devpts "/dev/pts"

    backup "${ROOTFS_DIR}" "/etc/fstab"

    copy_to_rootfs "${ROOTFS_DIR}" "/etc/resolv.conf"

    silent 'Generating D-Bus UUID' chroot "${ROOTFS_DIR}" dbus-uuidgen --ensure

    deactivate "${ROOTFS_DIR}" "/sbin/initctl"
    deactivate "${ROOTFS_DIR}" "/usr/sbin/update-grub"
    deactivate "${ROOTFS_DIR}" "/usr/sbin/grub-probe"
}

function finish_chroot()
{
    ROOTFS_DIR="$1"

    silent 'Clearing APT cache' chroot "${ROOTFS_DIR}" apt-get clean

    reactivate "${ROOTFS_DIR}" "/sbin/initctl"
    reactivate "${ROOTFS_DIR}" "/usr/sbin/update-grub"
    reactivate "${ROOTFS_DIR}" "/usr/sbin/grub-probe"

    silent 'Removing D-Bus UUID' rm -f "${ROOTFS_DIR}/var/lib/dbus/machine-id"

    silent 'Unmounting /dev/pts'  chroot "${ROOTFS_DIR}" umount "/dev/pts"
    silent 'Unmounting /sys'      chroot "${ROOTFS_DIR}" umount "/sys"

    if [[ -n "$(mount | grep "${ROOTFS_DIR}/proc/sys/fs/binfmt_misc")" ]]
    then
        silent 'Unmounting binfmt'    chroot "${ROOTFS_DIR}" umount "/proc/sys/fs/binfmt_misc"
    fi

    silent 'Unmounting /proc'     chroot "${ROOTFS_DIR}" umount "/proc"

    silent 'Unmounting /dev'      umount "${ROOTFS_DIR}/dev"

    restore "${ROOTFS_DIR}" "/etc/fstab"
    restore "${ROOTFS_DIR}" "/etc/resolv.conf"

    silent 'Removing mtab' rm -f "${ROOTFS_DIR}/etc/mtab"

    clear_directory "${ROOTFS_DIR}" /tmp
    clear_directory "${ROOTFS_DIR}" /var/crash
}

function chroot_rootfs()
{
    ROOTFS_DIR="$1"
    shift

    if [[ ! -d "${ROOTFS_DIR}" ]]
    then
        msgfail "${ROOTFS_DIR} is not a directory"
        exit 1
    fi

    chroot "$ROOTFS_DIR" "$@"
    status=$?

    return $status
}


