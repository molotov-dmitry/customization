#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")/.." && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

bundle="$1"

scriptpath="${ROOT_PATH}/bundles/$(basename "$0")"

case "${bundle}" in

### ============================================================================
### Gnome ======================================================================
### ============================================================================

"gnome")

;;

### ============================================================================
### Qt =========================================================================
### ============================================================================

"qt")

;;

### ============================================================================
### Drivers ====================================================================
### ============================================================================

"driver")

    bash "${scriptpath}" 'driver/intel'
    bash "${scriptpath}" 'driver/firmware'
    bash "${scriptpath}" 'driver/fs'

;;

### Intel drivers ==============================================================

"driver/intel")

;;

### Firmwares ==================================================================

"driver/firmware")

;;

### Filesystems support ========================================================

"driver/fs")

;;

### ============================================================================
### Server =====================================================================
### ============================================================================

"server")

    bash "${scriptpath}" 'server/ssh'
    bash "${scriptpath}" 'server/ftp'
    bash "${scriptpath}" 'server/smb'
    bash "${scriptpath}" 'server/svn'
    bash "${scriptpath}" 'server/db'
    bash "${scriptpath}" 'server/iperf'
    bash "${scriptpath}" 'server/media'
    bash "${scriptpath}" 'server/download'
    bash "${scriptpath}" 'server/proxy'

;;

### OpenSSH server =============================================================

"server/ssh")

;;

### FTP server =================================================================

"server/ftp")

;;

### SMB server =================================================================

"server/smb")

;;

### SVN server =================================================================

"server/svn")

;;

### DB server ==================================================================

"server/db")

;;

### Postgres -------------------------------------------------------------------

"server/db/postgres")

;;

### Iperf server ===============================================================

"server/iperf")

;;

### Media server ===============================================================

"server/media")

    sleep 30

    su -c 'export LD_LIBRARY_PATH=/usr/lib/plexmediaserver; /usr/lib/plexmediaserver/Plex\ Media\ Scanner -n "Музыка" --type 8 --location "/media/documents/Music"' - plex
    su -c 'export LD_LIBRARY_PATH=/usr/lib/plexmediaserver; /usr/lib/plexmediaserver/Plex\ Media\ Scanner -n "Видео" --type 1 --location "/media/documents/Video"' - plex

;;

### Download server ============================================================

"server/download")

;;

### Proxy server ===============================================================

"server/proxy")

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

    bash "${scriptpath}" 'dev/build'
    bash "${scriptpath}" 'dev/analysis'
    bash "${scriptpath}" 'dev/style'
    bash "${scriptpath}" 'dev/doc'
    bash "${scriptpath}" 'dev/man'
    bash "${scriptpath}" 'dev/x11'
    bash "${scriptpath}" 'dev/opengl'
    bash "${scriptpath}" 'dev/qt'
    bash "${scriptpath}" 'dev/qt4'
    bash "${scriptpath}" 'dev/gtk'
    bash "${scriptpath}" 'dev/gnome'
    bash "${scriptpath}" 'dev/db'
    bash "${scriptpath}" 'dev/json'
    bash "${scriptpath}" 'dev/net'
    bash "${scriptpath}" 'dev/ti'

;;

### Build tools ================================================================

"dev/build")

;;

### Code analysis tools ========================================================

"dev/analysis")

;;

### Code formatting ============================================================

"dev/style")

;;

### Documentation tools ========================================================

"dev/doc")

;;

### Documentation and references ===============================================

"dev/man")

;;

### X11 SDK ====================================================================

"dev/x11")

;;

### OpenGL SDK =================================================================

"dev/opengl")

;;

### Qt SDK =====================================================================

"dev/qt")

;;

### Qt4 SDK ====================================================================

"dev/qt4")

;;

### KDE SDK ====================================================================

"dev/kde")

;;

### GTK SDK ====================================================================

"dev/gtk")

;;

### Gnome SDK ==================================================================

"dev/gnome")

;;

### Database ===================================================================

"dev/db")

;;

### JSON libraries =============================================================

"dev/json")

;;

### Network ====================================================================

"dev/net")

    for userinfo in $(cat /etc/passwd | grep -v '^root:' | grep -v nologin | grep -v /bin/false | grep -v /bin/sync | grep -v '^postgres:' | grep -v '^ftp' | cut -d ':' -f 1,6)
    do
        user_name=$(echo "${userinfo}" | cut -d ':' -f 1)

        usermod -a -G wireshark ${user_name}
    done

;;

### TI TMS320C64XX =============================================================

"dev/ti")

;;


### ============================================================================
### Version control system =====================================================
### ============================================================================

"vcs")

;;

### ============================================================================
### Appearance =================================================================
### ============================================================================

"appearance")

    bash "${scriptpath}" 'appearance/themes'
    bash "${scriptpath}" 'appearance/fonts'

;;

### Desktop theme ==============================================================

"appearance/themes")

;;

### System fonts ===============================================================

"appearance/fonts")

;;

### ============================================================================
### Office applications ========================================================
### ============================================================================

"office")

;;

### ============================================================================
### Multimedia applications ====================================================
### ============================================================================

### Local music/video  =========================================================

"media")

;;

### Online video ===============================================================

"media-online")

;;

### ============================================================================
### Network and communication ==================================================
### ============================================================================

"network")

    bash "${scriptpath}" 'network/browser'
    bash "${scriptpath}" 'network/mail'
    bash "${scriptpath}" 'network/chat'
    bash "${scriptpath}" 'network/chat-extra'
    bash "${scriptpath}" 'network/office'
    bash "${scriptpath}" 'network/services'
    bash "${scriptpath}" 'network/remote'
    
;;

### Browser ====================================================================

"network/browser")

;;

### Mail =======================================================================

"network/mail")

;;

### Chat =======================================================================

"network/chat")

;;

### Chat extra protocols =======================================================

"network/chat-extra")

;;

### Office =====================================================================

"network/office")

;;

### Online services ============================================================

"network/services")

;;

### Remote clients =============================================================

"network/remote")

;;

### ============================================================================
### Graphic applications =======================================================
### ============================================================================

"graphics")

;;

### ============================================================================
### Compressing applications ===================================================
### ============================================================================

"archive")

;;

### ============================================================================
### Command line ===============================================================
### ============================================================================

"cli")

    bash "${scriptpath}" 'cli/files'
    bash "${scriptpath}" 'cli/monitor'
    bash "${scriptpath}" 'cli/net'
    bash "${scriptpath}" 'cli/time'
    bash "${scriptpath}" 'cli/ttycolors'

;;

### Command line file manager applications =====================================

"cli/files")

;;

### Command line monitor applications ==========================================

"cli/monitor")

;;

### Command line network applications ==========================================

"cli/net")

;;

### Command line tools for time sync ===========================================

"cli/time")

;;

### TTY colors =================================================================

"cli/ttycolors")

;;

### ============================================================================
### Folders setup ==============================================================
### ============================================================================

"folders")

    for userinfo in $(cat /etc/passwd | grep -v '^root:' | grep -v nologin | grep -v /bin/false | grep -v /bin/sync | grep -v '^postgres:' | grep -v '^ftp' | cut -d ':' -f 1,3,4,6)
    do
        user_name=$(echo "${userinfo}" | cut -d ':' -f 1)
        user_id=$(echo "${userinfo}" | cut -d ':' -f 2)

        mkdir -p "/media/documents/${user_name}"
        chown -R "${user_name}:${user_name}" "/media/documents/${user_name}"

        fixpermissions "/media/documents/" "${user_id}"
    done

;;

### ============================================================================
### Optimizations ==============================================================
### ============================================================================

"optimize")

    bash "${scriptpath}" 'optimize/tmpfs'
    bash "${scriptpath}" 'optimize/chrome-ramdisk'
    bash "${scriptpath}" 'optimize/disable-tracker'
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
        safe_mount=$(echo "${mount_name}" | sed 's/\\/\\\\\\/g')

        ## make dir ------------------------------------------------------------

        sudo -u ${user_name} mkdir -p "${user_home}/.cache"

        ## Mount point ---------------------------------------------------------

        sed "s/<USER>/${user_name}/g;s/<UID>/${user_id}/g;s/<GID>/${user_group}/g;s/<HOME>/${safe_home}/g;s/<MOUNT>/${safe_mount}/g" "${ROOT_PATH}/files/tmpfs/cache-ramdisk.mount" > "/etc/systemd/system/${mount_name}"
        systemctl enable ${mount_name}

        ## Clear and mount directory -------------------------------------------

        find "${user_home}/.cache" -mindepth 1 -delete
        systemctl start ${mount_name}

    done

;;

### Keep Chromium's RAM disk between power-offs ================================

"optimize/chrome-ramdisk")

    for userinfo in $(cat /etc/passwd | grep -v '^root:' | grep -v nologin | grep -v /bin/false | grep -v /bin/sync | grep -v '^postgres:' | grep -v '^ftp:' | cut -d ':' -f 1,3,4,6)
    do
        user_name=$(echo "${userinfo}" | cut -d ':' -f 1)
        user_id=$(echo "${userinfo}" | cut -d ':' -f 2)
        user_group=$(echo "${userinfo}" | cut -d ':' -f 3)
        user_home=$(echo "${userinfo}" | cut -d ':' -f 4)
        mount_name=$(systemd-escape -p --suffix=mount "${user_home}/.config/chromium")
        safe_home=$(echo "${user_home}" | sed 's/\//\\\//g')
        safe_mount=$(echo "${mount_name}" | sed 's/\\/\\\\\\/g')

        ## make dir ------------------------------------------------------------

        sudo -u ${user_name} mkdir -p "${user_home}/.config/chromium"

        ## Mount point ---------------------------------------------------------

        sed "s/<USER>/${user_name}/g;s/<UID>/${user_id}/g;s/<GID>/${user_group}/g;s/<HOME>/${safe_home}/g;s/<MOUNT>/${safe_mount}/g" "${ROOT_PATH}/files/chrome-ramdisk/chrome-ramdisk.mount" > "/etc/systemd/system/${mount_name}"
        systemctl enable ${mount_name}

        ## User service --------------------------------------------------------

        sed "s/<USER>/${user_name}/g;s/<UID>/${user_id}/g;s/<GID>/${user_group}/g;s/<HOME>/${safe_home}/g;s/<MOUNT>/${safe_mount}/g" "${ROOT_PATH}/files/chrome-ramdisk/chrome-ramdisk.service" > "/etc/systemd/system/chrome-ramdisk-${user_name}.service"        
        systemctl enable chrome-ramdisk-${user_name}.service

        ## Clear and mount directory -------------------------------------------

        find "${user_home}/.config/chromium" -mindepth 1 -delete
        systemctl start chrome-ramdisk-${user_name}.service

    done

;;

### Disable Gnome tracker ======================================================

"optimize/disable-tracker")

;;

### ============================================================================
### Virtual machine tools ======================================================
### ============================================================================

"vm-guest")

    bash "${scriptpath}" 'vm-guest/vmware'
    bash "${scriptpath}" 'vm-guest/vbox'
;;

"vm-guest/vmware")

;;

"vm-guest/vbox")

;;

### ============================================================================
### Virtual machine host tools =================================================
### ============================================================================

"vm-host")

    bash "${scriptpath}" 'vm-host/vbox'

;;

"vm-host/vbox")

    for userinfo in $(cat /etc/passwd | grep -v '^root:' | grep -v nologin | grep -v /bin/false | grep -v /bin/sync | grep -v '^postgres:' | grep -v '^ftp' | cut -d ':' -f 1,6)
    do
        user_name=$(echo "${userinfo}" | cut -d ':' -f 1)

        usermod -a -G vboxusers ${user_name}
    done

;;

### ============================================================================
### ============================================================================
### ============================================================================

esac
