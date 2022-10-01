#!/bin/bash

function copy_to_rootfs()
{
    local dir="$1"
    local file="$2"

    if [[ -f "${file}" ]]
    then
        backup "${dir}" "${file}"

        mkdir -p "$(dirname "${dir}/${file}")"
        silent_fail "Copy ${file} to rootfs" cp -f ${file} "${dir}/${file}"
	fi

    return 0
}

function backup()
{
    local dir="$1"
    local file="$2"

    if [[ -f "${dir}/${file}" ]]
    then
        silent_fail "Backup ${file}" mv -f "${dir}/${file}" "${dir}/${file}.bak"
	fi

    return 0
}

function restore()
{
    local dir="$1"
    local file="$2"

    if [[ -f "${dir}/${file}.bak" ]]
    then
        silent_fail "Restore ${file}" mv -f "${dir}/${file}.bak" "${dir}/${file}"
    elif [[ -f "${dir}/${file}" ]]
    then
        silent_fail "Removing ${file}" rm -rf "${dir}/${file}"
	fi

    return 0
}

function deactivate()
{
    local dir="$1"
    local file="$2"

    if [[ -f "${dir}/${file}" ]]
    then
        silent_fail "Deactivating ${file}" chroot "${dir}" bash -c "dpkg-divert --local --rename --add \"${file}\" && ln -s /bin/true \"${file}\""
    fi

    return 0
}

function reactivate()
{
    local dir="$1"
    local file="$2"

    if [[ -f "${dir}/${file}" ]]
    then
        silent_fail "Reactivating ${file}" chroot "${dir}" bash -c "rm -f \"${file}\"; dpkg-divert --rename --remove \"${file}\""
	fi

    return 0
}

function clear_directory()
{
    local dir="$1"
    local dir_rm="$2"

    if [[ -e "${dir}/${dir_rm}" ]]
    then
        silent_fail "Clearing ${dir_rm}" find "${dir}/${dir_rm}" -mindepth 1 -delete
    fi

    return 0
}

function start_chroot()
{
    ROOTFS_DIR="$1"

    silent_fail 'Mounting /dev'      mount --bind /dev/ "${ROOTFS_DIR}/dev"

    silent_fail 'Mounting /proc'     chroot "${ROOTFS_DIR}" mount none -t proc   "/proc"
    silent_fail 'Mounting /sys'      chroot "${ROOTFS_DIR}" mount none -t sysfs  "/sys"
    silent_fail 'Mounting /dev/pts'  chroot "${ROOTFS_DIR}" mount none -t devpts "/dev/pts"

    backup "${ROOTFS_DIR}" "/etc/fstab"

    copy_to_rootfs "${ROOTFS_DIR}" "/etc/resolv.conf"

    silent_fail 'Generating D-Bus UUID' chroot "${ROOTFS_DIR}" dbus-uuidgen --ensure

    deactivate "${ROOTFS_DIR}" "/sbin/initctl"
    deactivate "${ROOTFS_DIR}" "/usr/sbin/update-grub"
    deactivate "${ROOTFS_DIR}" "/usr/sbin/grub-probe"
}

function finish_chroot()
{
    ROOTFS_DIR="$1"

    silent_fail 'Clearing APT cache' chroot "${ROOTFS_DIR}" apt clean

    reactivate "${ROOTFS_DIR}" "/sbin/initctl"
    reactivate "${ROOTFS_DIR}" "/usr/sbin/update-grub"
    reactivate "${ROOTFS_DIR}" "/usr/sbin/grub-probe"

    silent_fail 'Removing D-Bus UUID' rm -f "${ROOTFS_DIR}/var/lib/dbus/machine-id"

    silent_fail 'Unmounting /dev/pts'  chroot "${ROOTFS_DIR}" umount "/dev/pts"
    silent_fail 'Unmounting /sys'      chroot "${ROOTFS_DIR}" umount "/sys"

    if [[ -n "$(mount | grep "${ROOTFS_DIR}/proc/sys/fs/binfmt_misc")" ]]
    then
        silent_fail 'Unmounting binfmt'    chroot "${ROOTFS_DIR}" umount "/proc/sys/fs/binfmt_misc"
    fi

    silent_fail 'Unmounting /proc'     chroot "${ROOTFS_DIR}" umount "/proc"

    silent_fail 'Unmounting /dev'      umount "${ROOTFS_DIR}/dev"

    restore "${ROOTFS_DIR}" "/etc/fstab"
    restore "${ROOTFS_DIR}" "/etc/resolv.conf"

    silent_fail 'Removing mtab' rm -f "${ROOTFS_DIR}/etc/mtab"

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


