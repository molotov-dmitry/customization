#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")/.." && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

bundle="$1"

user_name="$2"
user_id="$3"
user_group="$4"
user_comment="$5"
user_home="$6"
user_login="$7"

shift

scriptpath="${ROOT_PATH}/bundles/$(basename "$0")"

case "${bundle}" in

### ============================================================================
### Base system ================================================================
### ============================================================================

### Base system ================================================================

"base")

    for group in adm cdrom dip plugdev lxd lpadmin
    do
        if grep "^${group}:" /etc/group > /dev/null 2> /dev/null
        then
            usermod -a -G "${group}" "${user_name}"
        fi
    done

;;

### Base GUI ===================================================================

"gui")

;;

### GTK-based GUI ==============================================================

"gtk")

;;

### ============================================================================
### DM =========================================================================
### ============================================================================

### Gnome ======================================================================

"gnome")

;;

### Cinnamon ===================================================================

"cinnamon")

;;

### KDE ========================================================================

"kde")

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

    bash "${scriptpath}" 'driver/intel' "$@"
    bash "${scriptpath}" 'driver/firmware' "$@"
    bash "${scriptpath}" 'driver/wifi' "$@"
    bash "${scriptpath}" 'driver/printer' "$@"
    bash "${scriptpath}" 'driver/fs' "$@"

;;

### Intel drivers ==============================================================

"driver/intel")

;;

### Firmwares ==================================================================

"driver/firmware")

;;

### Wi-Fi drivers ==============================================================

"driver/wifi")

;;

### Printer drivers and PPDs ===================================================

"driver/printer")

;;

### Filesystems support ========================================================

"driver/fs")

;;

### ============================================================================
### Server =====================================================================
### ============================================================================

"server")

    bash "${scriptpath}" 'server/ssh' "$@"
    bash "${scriptpath}" 'server/ftp' "$@"
    bash "${scriptpath}" 'server/smb' "$@"
    bash "${scriptpath}" 'server/svn' "$@"
    bash "${scriptpath}" 'server/db' "$@"
    bash "${scriptpath}" 'server/iperf' "$@"
    bash "${scriptpath}" 'server/media' "$@"
    bash "${scriptpath}" 'server/download' "$@"
    bash "${scriptpath}" 'server/proxy' "$@"

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

;;

### Download server ============================================================

"server/download")

;;

### Proxy server ===============================================================

"server/proxy")

;;

### GitLab =====================================================================

"gitlab")

;;

### ============================================================================
### Development ================================================================
### ============================================================================

"dev")

    bash "${scriptpath}" 'dev/build' "$@"
    bash "${scriptpath}" 'dev/analysis' "$@"
    bash "${scriptpath}" 'dev/style' "$@"
    bash "${scriptpath}" 'dev/doc' "$@"
    bash "${scriptpath}" 'dev/man' "$@"
    bash "${scriptpath}" 'dev/x11' "$@"
    bash "${scriptpath}" 'dev/opengl' "$@"
    bash "${scriptpath}" 'dev/qt' "$@"
    bash "${scriptpath}" 'dev/qt4' "$@"
    bash "${scriptpath}" 'dev/gtk' "$@"
    bash "${scriptpath}" 'dev/gnome' "$@"
    bash "${scriptpath}" 'dev/db' "$@"
    bash "${scriptpath}" 'dev/json' "$@"
    bash "${scriptpath}" 'dev/net' "$@"
    bash "${scriptpath}" 'dev/ti' "$@"

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

    usermod -a -G wireshark "${user_name}"

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

    bash "${scriptpath}" 'appearance/themes' "$@"
    bash "${scriptpath}" 'appearance/fonts' "$@"
    bash "${scriptpath}" 'appearance/wallpaper' "$@"
    bash "${scriptpath}" 'appearance/avatar' "$@"

;;

### Desktop theme ==============================================================

"appearance/themes")

;;

### System fonts ===============================================================

"appearance/fonts")

;;

### Wallpaper ==================================================================

"appearance/wallpaper")

;;

### User avatar ================================================================

"appearance/avatar")

    ## Generate avatar if not exists -------------------------------------------

    if which rsvg-convert >/dev/null
    then
        USER_NAME_LETTER=${user_comment:0:1}

        AVATAR_COLORS=('D32F2F' 'B71C1C' 'AD1457' 'EC407A' 'AB47BC' '6A1B9A' 'AA00FF' '5E35B1' '3F51B5' '1565C0' '0091EA' '00838F' '00897B' '388E3C' '558B2F' 'E65100' 'BF360C' '795548' '607D8B')
        AVATAR_COLORS_COUNT=${#AVATAR_COLORS[@]}
        INDEX=$(( (RANDOM * RANDOM + RANDOM) % AVATAR_COLORS_COUNT ))

        bgcolor="#${AVATAR_COLORS[$INDEX]}"
        fgfont="Arial"

        if [[ "gpqy" == *"${USER_NAME_LETTER}"* || "аруцд" == *"${USER_NAME_LETTER}"* ]]
        then
            dy=25
        elif [[ "У"  == *"${USER_NAME_LETTER}"* ]]
        then
            dy=40
        elif [[ "${USER_NAME_LETTER}" == "${USER_NAME_LETTER^^}" && "Д" != *"${USER_NAME_LETTER}"* ]]
        then
            dy=35
        else
            dy=30
        fi

        cat << _EOF | rsvg-convert -w 512 -h 512 -f png -o "${user_home}/.face"
<svg width="1000" height="1000">
  <circle cx="500" cy="500" r="400" fill="${bgcolor}" />
  <text x="50%" y="50%" text-anchor="middle" fill="white" font-size="500px" dy="0.${dy}em" font-family="${fgfont}">${USER_NAME_LETTER}</text>
</svg>
_EOF

        chown "${user_name}:${user_name}" "${user_home}/.face"
    fi

    ## Configure account icon --------------------------------------------------

    echo mkdir -p '/var/lib/AccountsService/icons/'

    cp -f "${user_home}/.face" "/var/lib/AccountsService/icons/${user_name}"

    addconfigline Icon "/var/lib/AccountsService/icons/${user_name}" User "/var/lib/AccountsService/users/${user_name}"

    ## -------------------------------------------------------------------------

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

    bash "${scriptpath}" 'network/browser' "$@"
    bash "${scriptpath}" 'network/mail' "$@"
    bash "${scriptpath}" 'network/chat' "$@"
    bash "${scriptpath}" 'network/chat-extra' "$@"
    bash "${scriptpath}" 'network/office' "$@"
    bash "${scriptpath}" 'network/services' "$@"
    bash "${scriptpath}" 'network/remote' "$@"
    bash "${scriptpath}" 'network/remotedesktop' "$@"

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

### Remote desktop =============================================================

"network/remotedesktop")

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

    bash "${scriptpath}" 'cli/files' "$@"
    bash "${scriptpath}" 'cli/monitor' "$@"
    bash "${scriptpath}" 'cli/net' "$@"
    bash "${scriptpath}" 'cli/time' "$@"
    bash "${scriptpath}" 'cli/ttycolors' "$@"

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

    mkdir -p "/media/documents/${user_name}"
    chown -R "${user_name}:${user_name}" "/media/documents/${user_name}"

;;

### ============================================================================
### Optimizations ==============================================================
### ============================================================================

"optimize")

    bash "${scriptpath}" 'optimize/tmpfs' "$@"
    bash "${scriptpath}" 'optimize/chrome-ramdisk' "$@"
    bash "${scriptpath}" 'optimize/disable-tracker' "$@"
;;

### Mount directories with high I/O as tmpfs ===================================

"optimize/tmpfs")

    mount_name=$(systemd-escape -p --suffix=mount "${user_home}/.cache")

    safe_home=$(echo "${user_home}" | sed 's/\//\\\//g')
    safe_mount=$(echo "${mount_name}" | sed 's/\\/\\\\\\/g')

    ## make dir ----------------------------------------------------------------

    sudo -u ${user_name} mkdir -p "${user_home}/.cache"

    ## Mount point -------------------------------------------------------------

    sed "s/<USER>/${user_name}/g;s/<UID>/${user_id}/g;s/<GID>/${user_group}/g;s/<HOME>/${safe_home}/g;s/<MOUNT>/${safe_mount}/g" "${ROOT_PATH}/files/tmpfs/cache-ramdisk.mount" > "/etc/systemd/system/${mount_name}"
    systemctl enable ${mount_name}

    ## Clear and mount directory -----------------------------------------------

    find "${user_home}/.cache" -mindepth 1 -delete
    systemctl start ${mount_name}

;;

### Keep Chromium's RAM disk between power-offs ================================

"optimize/chrome-ramdisk")

    mount_name=$(systemd-escape -p --suffix=mount "${user_home}/.config/chromium")
    safe_home=$(echo "${user_home}" | sed 's/\//\\\//g')
    safe_mount=$(echo "${mount_name}" | sed 's/\\/\\\\\\/g')

    ## make dir ----------------------------------------------------------------

    sudo -u ${user_name} mkdir -p "${user_home}/.config/chromium"

    ## Mount point -------------------------------------------------------------

    sed "s/<USER>/${user_name}/g;s/<UID>/${user_id}/g;s/<GID>/${user_group}/g;s/<HOME>/${safe_home}/g;s/<MOUNT>/${safe_mount}/g" "${ROOT_PATH}/files/chrome-ramdisk/chrome-ramdisk.mount" > "/etc/systemd/system/${mount_name}"
    systemctl enable ${mount_name}

    ## User service ------------------------------------------------------------

    sed "s/<USER>/${user_name}/g;s/<UID>/${user_id}/g;s/<GID>/${user_group}/g;s/<HOME>/${safe_home}/g;s/<MOUNT>/${safe_mount}/g" "${ROOT_PATH}/files/chrome-ramdisk/chrome-ramdisk.service" > "/etc/systemd/system/chrome-ramdisk-${user_name}.service"
    systemctl enable chrome-ramdisk-${user_name}.service

    ## Clear and mount directory -----------------------------------------------

    find "${user_home}/.config/chromium" -mindepth 1 -delete
    systemctl start chrome-ramdisk-${user_name}.service

;;

### Disable Gnome tracker ======================================================

"optimize/disable-tracker")

;;

### ============================================================================
### Virtual machine tools ======================================================
### ============================================================================

"vm-guest")

    bash "${scriptpath}" 'vm-guest/vmware' "$@"
    bash "${scriptpath}" 'vm-guest/vbox' "$@"
;;

"vm-guest/vmware")

;;

"vm-guest/vbox")

;;

### ============================================================================
### Virtual machine host tools =================================================
### ============================================================================

"vm-host")

    bash "${scriptpath}" 'vm-host/vbox' "$@"

;;

"vm-host/vbox")

    usermod -a -G vboxusers ${user_name}

;;

### ============================================================================
### Work =======================================================================
### ============================================================================

"work")

;;

"work-mail")

;;

### ============================================================================
### ============================================================================
### ============================================================================

esac
