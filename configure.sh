#!/bin/bash

if [[ $(id -u) -ne 0 ]]
then
    echo 'Launching as root'
    sudo bash "$0" "$@"
    exit $?
fi

shopt -s extglob

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

#### Functions =================================================================

isdebian()
{
    if [[ "$(lsb_release -si)" == 'Debian' ]]
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
    
    pushd "${rootfs_dir}/" >/dev/null

    if [[ -f "tools/${name}.sh" ]]
    then
        bash "tools/${name}.sh" "$@"
    fi

    if [[ -n "$config" ]]
    then
        bash tools/bundle.sh "${name}" "${config}"
    fi
    
    popd >/dev/null

    if [[ -f "${rootfs_dir}/tools/${name}.sh" ]]
    then
        silent "Remove ${name} script" rm -rf "${rootfs_dir}/tools/${name}.sh" || return 1
    fi

    return 0
}

### Getting parameters =========================================================

### Getting parameters =========================================================

configs="@($(ls -1 "${ROOT_PATH}/custom/tools" | tr '\n' '|' | sed 's/|$//'))"

while [[ $# -gt 0 ]]
do

    case "$1" in

    '--notify')
        notify='y'
    ;;

    ${configs})
        config="$1"
    ;;
    
    *)
        echo "$1"
    ;;

    esac

    shift

done

rootfs_dir=''

common_file_path="${ROOT_PATH}/files"
custom_file_path="${ROOT_PATH}/custom/files/${config}"

### Showing bundles ============================================================

bundlelist

read

### Configure system ===========================================================

## Preparing -------------------------------------------------------------------

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
silent 'Copy GPG keys'                  cp -rfP "${ROOT_PATH}/tools/keys"      "${rootfs_dir}/tools/" || exit 1

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

## Clean up after chroot step --------------------------------------------------

silent 'Removing bundle list'           rm -f  "${rootfs_dir}/tools/custom/tools/${config}.bundle"
silent 'Removing GPG keys'              rm -rf "${rootfs_dir}/tools/keys"

## Copying first boot script ---------------------------------------------------

placescript 'firstboot'
placescript 'firstbootuser'
placescript 'user'

## Finalizing customization ----------------------------------------------------

silent 'Changing tools mode'            chmod -R 777 "${rootfs_dir}/tools"

### Copy files from skeleton ===================================================

while read userinfo
do
    user_name="$(echo "${userinfo}" | cut -d ':' -f 1)"
    user_id="$(echo "${userinfo}" | cut -d ':' -f 3)"
    user_group="$(echo "${userinfo}" | cut -d ':' -f 4)"
    user_comment="$(echo "${userinfo}" | cut -d ':' -f 5)"
    user_home="$(echo "${userinfo}" | cut -d ':' -f 6)"
    user_login="$(echo "${userinfo}" | cut -d ':' -f 7)"

    if [[ ${user_id} -lt 999 || ${user_id} -ge 60000 || -z "${user_home}" || "$(basename "${user_login}")" == 'nologin' ]]
    then
        continue
    fi
    
    su -c "cp -rf /etc/skel/. \"${user_home}/\"" - "${user_name}"

done < /etc/passwd

