#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")/.." && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

bundle="$1"

scriptpath="${ROOT_PATH}/bundles/$(basename "$0")"

case "${bundle}" in

### ============================================================================
### Server =====================================================================
### ============================================================================

"server")

    bash "${scriptpath}" 'server/media'

;;

### Media server ===============================================================

"server/media")

    sleep 30

    su -c 'export LD_LIBRARY_PATH=/usr/lib/plexmediaserver; /usr/lib/plexmediaserver/Plex\ Media\ Scanner -n "Музыка" --type 8 --location "/media/documents/Music"' - plex
    su -c 'export LD_LIBRARY_PATH=/usr/lib/plexmediaserver; /usr/lib/plexmediaserver/Plex\ Media\ Scanner -n "Видео" --type 1 --location "/media/documents/Video"' - plex
;;

### GitLab =====================================================================

"gitlab")

    debconfselect 'gitlab' 'gitlab/ssl'         'false'
    debconfselect 'gitlab' 'gitlab/letsencrypt' 'false'
    debconfselect 'gitlab' 'gitlab/fqdn'        'gitlab.local'

    #debinstall 'Gitlab' 'gitlab' '' 'all'
    #appremove  'Gitlab stub' 'gitlab-stub'

;;

### ============================================================================
### Development ================================================================
### ============================================================================

"dev")

    bash "${scriptpath}" 'dev/net'

;;

### Network ====================================================================

"dev/net")

    for userinfo in $(cat /etc/passwd | grep -v '^root:' | grep -v nologin | grep -v /bin/false | grep -v /bin/sync | grep -v '^postgres:' | grep -v '^ftp' | cut -d ':' -f 1,6)
    do
        user_name=$(echo "${userinfo}" | cut -d ':' -f 1)

        usermod -a -G wireshark ${user_name}
    done

;;

### ============================================================================
### Optimizations ==============================================================
### ============================================================================

"optimize")

    bash "${scriptpath}" 'optimize/tmpfs'
    bash "${scriptpath}" 'optimize/chrome-ramdisk'
;;

### Mount directories with high I/O as tmpfs ===================================

"optimize/tmpfs")

    for userinfo in $(cat /etc/passwd | grep -v '^root:' | grep -v nologin | grep -v /bin/false | grep -v /bin/sync | grep -v '^postgres:' | grep -v '^ftp' | cut -d ':' -f 1,3,4,6)
    do
        user_name=$(echo "${userinfo}" | cut -d ':' -f 1)
        user_id=$(echo "${userinfo}" | cut -d ':' -f 2)
        user_group=$(echo "${userinfo}" | cut -d ':' -f 3)
        user_home=$(echo "${userinfo}" | cut -d ':' -f 4)
        mount_name=$(systemd-escape -p --suffix=mount "${user_home}/.cache")
        safe_home=$(echo "${user_home}" | sed 's/\//\\\//g')
        safe_mount=$(echo "${user_home}" | sed 's/\\/\\\\/g')

        ## make dir ------------------------------------------------------------

        sudo -u ${user_name} mkdir -p "${user_home}/.cache"

        ## Mount point ---------------------------------------------------------

        sed "s/<USER>/${user_name}/g;s/<UID>/${user_id}/g;s/<GID>/${user_group}/g;s/<HOME>/${safe_home}/g;s/<MOUNT>/${safe_mount}/g" "${ROOT_PATH}/files/chrome-ramdisk/cache-ramdisk.mount" > "/etc/systemd/system/${mount_name}"
        systemctl enable ${mount_name}

    done

;;

### Keep Chromium's RAM disk between power-offs ================================

"optimize/chrome-ramdisk")

    for userinfo in $(cat /etc/passwd | grep -v '^root:' | grep -v nologin | grep -v /bin/false | grep -v /bin/sync | grep -v '^postgres:' | grep -v '^ftp' | cut -d ':' -f 1,3,4,6)
    do
        user_name=$(echo "${userinfo}" | cut -d ':' -f 1)
        user_id=$(echo "${userinfo}" | cut -d ':' -f 2)
        user_group=$(echo "${userinfo}" | cut -d ':' -f 3)
        user_home=$(echo "${userinfo}" | cut -d ':' -f 4)
        mount_name=$(systemd-escape -p --suffix=mount "${user_home}/.config/chromium")
        safe_home=$(echo "${user_home}" | sed 's/\//\\\//g')
        safe_mount=$(echo "${user_home}" | sed 's/\\/\\\\/g')

        ## make dir ------------------------------------------------------------

        sudo -u ${user_name} mkdir -p "${user_home}/.config/chromium"

        ## Mount point ---------------------------------------------------------

        sed "s/<USER>/${user_name}/g;s/<UID>/${user_id}/g;s/<GID>/${user_group}/g;s/<HOME>/${safe_home}/g;s/<MOUNT>/${safe_mount}/g" "${ROOT_PATH}/files/chrome-ramdisk/chrome-ramdisk.mount" > "/etc/systemd/system/${mount_name}"
        systemctl enable ${mount_name}

        ## User service --------------------------------------------------------

        sed "s/<USER>/${user_name}/g;s/<UID>/${user_id}/g;s/<GID>/${user_group}/g;s/<HOME>/${safe_home}/g;s/<MOUNT>/${safe_mount}/g" "${ROOT_PATH}/files/chrome-ramdisk/chrome-ramdisk.service" > "/etc/systemd/system/chrome-ramdisk-${user_name}.service"        
        systemctl enable chromium-ramdisk-${user_name}.service

    done

;;

### ============================================================================
### ============================================================================
### ============================================================================

esac
