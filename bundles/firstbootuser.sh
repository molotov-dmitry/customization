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
    bash "${scriptpath}" 'server/svn' "$@"
    bash "${scriptpath}" 'server/db' "$@"
    bash "${scriptpath}" 'server/iperf' "$@"
    bash "${scriptpath}" 'server/media' "$@"
    bash "${scriptpath}" 'server/download' "$@"

;;

### OpenSSH server =============================================================

"server/ssh")

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

### ============================================================================
### Development ================================================================
### ============================================================================

"dev")

    bash "${scriptpath}" 'dev/build' "$@"
    bash "${scriptpath}" 'dev/analysis' "$@"
    bash "${scriptpath}" 'dev/style' "$@"
    bash "${scriptpath}" 'dev/doc' "$@"
    bash "${scriptpath}" 'dev/man' "$@"
    bash "${scriptpath}" 'dev/qt' "$@"
    bash "${scriptpath}" 'dev/gtk' "$@"
    bash "${scriptpath}" 'dev/gnome' "$@"
    bash "${scriptpath}" 'dev/db' "$@"
    bash "${scriptpath}" 'dev/json' "$@"
    bash "${scriptpath}" 'dev/markdown' "$@"
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

### Qt SDK =====================================================================

"dev/qt")

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

### Markdown editor ============================================================

"dev/markdown")

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

    bash "${scriptpath}" 'network/browser' "$@"
    bash "${scriptpath}" 'network/mail' "$@"
    bash "${scriptpath}" 'network/chat' "$@"
    bash "${scriptpath}" 'network/remote' "$@"

;;

### Browser ====================================================================

"network/browser")

;;

### Mail =======================================================================

"network/mail")

;;

### Chat extra protocols =======================================================

"network/chat")

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

    bash "${scriptpath}" 'cli/files' "$@"
    bash "${scriptpath}" 'cli/monitor' "$@"
    bash "${scriptpath}" 'cli/net' "$@"

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

### ============================================================================
### Folders setup ==============================================================
### ============================================================================

"folders")

    mkdir -p "/media/documents/${user_name}"

    fixpermissions "/media/documents/${user_name}" "${user_id}" "${user_group}"

;;

### ============================================================================
### Virtual machine host tools =================================================
### ============================================================================

"vm-host")

;;

"vm-host-vbox")

    usermod -a -G vboxusers ${user_name}

;;

### ============================================================================
### Work =======================================================================
### ============================================================================

"work")

    usermod -a -G dialout ${user_name}

;;

### Mail =======================================================================

"work-mail")

;;

### Chat =======================================================================

"work-chat")

;;

### ============================================================================
### ============================================================================
### ============================================================================

esac
