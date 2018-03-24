#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")/.." && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

bundle="$3"
config="$1"
rootfs_dir="$2"

scriptpath="${ROOT_PATH}/bundles/$(basename "$0")"

case "${bundle}" in

### ============================================================================
### Gnome ======================================================================
### ============================================================================

"gnome")

    silentsudo "Copy templates" cp -rf "${ROOT_PATH}/files/template" "${rootfs_dir}/tools/files/"
    silentsudo "Copy redshift config" cp -rf "${ROOT_PATH}/files/redshift" "${rootfs_dir}/tools/files/"

;;

### ============================================================================
### Server =====================================================================
### ============================================================================

"server")

    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'server/ftp'
    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'server/smb'
    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'server/svn'
    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'server/media'
    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'server/download'
    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'server/proxy'

;;

### FTP server =================================================================

"server/ftp")

    silentsudo "Copy vsftpd config" cp -rf "${ROOT_PATH}/files/vsftpd" "${rootfs_dir}/tools/files/"

;;

### SMB server =================================================================

"server/smb")

    silentsudo 'Copy Samba config'  cp -rf "${ROOT_PATH}/files/samba"           "${rootfs_dir}/tools/files/"

;;

### SVN server =================================================================

"server/svn")

    silentsudo "Copy svnserve unit" cp -rf "${ROOT_PATH}/files/svnserve" "${rootfs_dir}/tools/files/"
    
;;

### Media server ===============================================================

"server/media")

     ## MiniDLNA ----------------------------------------------------------------

    silentsudo 'Copy MiniDLNA config' cp -rf "${ROOT_PATH}/files/minidlna"          "${rootfs_dir}/tools/files/"

    ## Plex Media Server -------------------------------------------------------

    debprepare 'Plex Media Server' 'plexmediaserver' '1.3.4.3285-b46e0ea' 'amd64'
    
    silentsudo 'Copy Plex config' cp -rf "${ROOT_PATH}/files/plexmediaserver"   "${rootfs_dir}/tools/files/"

;;

### Download server ============================================================

"server/download")

    silentsudo 'Copy Transmission config'   cp -rf "${ROOT_PATH}/files/transmission" "${rootfs_dir}/tools/files/"
    silentsudo 'Copy EiskaltDC++ config'    cp -rf "${ROOT_PATH}/files/eiskaltdcpp"  "${rootfs_dir}/tools/files/"

;;

### Proxy server ===============================================================

"server/proxy")

    ## Squid3 ------------------------------------------------------------------

    silentsudo 'Copy Transmission config'   cp -rf "${ROOT_PATH}/files/squid3" "${rootfs_dir}/tools/files/"

;;

### ============================================================================
### Development ================================================================
### ============================================================================

"dev")

    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'dev/qt'

;;

### Build tools ================================================================

"dev/qt")

    ## Qt Creator --------------------------------------------------------------

    silentsudo 'Copy QtCreator config' cp -rf "${ROOT_PATH}/files/qtcreator" "${rootfs_dir}/tools/files/"

;;


### ============================================================================
### Office =====================================================================
### ============================================================================

"office")

    ## Libreoffice  ------------------------------------------------------------

    silentsudo 'Copy Libreoffice config' cp -rf "${ROOT_PATH}/files/libreoffice" "${rootfs_dir}/tools/files/"

;;

### ============================================================================
### Multimedia applications ====================================================
### ============================================================================

"media")

    ## Rhythmbox ---------------------------------------------------------------

    silentsudo 'Copy Rhythmbox radio database' cp -rf "${ROOT_PATH}/files/rhythmbox" "${rootfs_dir}/tools/files/"

    ## MPV ---------------------------------------------------------------------

    silentsudo 'Copy MPV config' cp -rf "${ROOT_PATH}/files/mpv" "${rootfs_dir}/tools/files/"

;;

### ============================================================================
### Network and communication ==================================================
### ============================================================================

"network")

    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'network/browser'
    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'network/mail'
    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'network/chat'
    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'network/services'
    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'network/remote'
    
;;

### Browser ====================================================================

"network/browser")

;;

### Mail =======================================================================

"network/mail")

;;

### Chat =======================================================================

"network/chat")

    silentsudo 'Copy Empathy theme and config' cp -rf "${ROOT_PATH}/files/empathy" "${rootfs_dir}/tools/files/"

;;

### Online services ============================================================

"network/services")

;;

### Remote clients =============================================================

"network/remote")

    silentsudo 'Copy Transmission remote config' cp -rf "${ROOT_PATH}/files/transmission-remote-gtk" "${rootfs_dir}/tools/files/"

    debprepare 'EiskaltDC++ Remote Qt' 'eiskaltdcpp-remote-qt' '27' 'amd64'
;;

### ============================================================================
### Command line ===============================================================
### ============================================================================

"cli")

    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'cli/ttycolors'

;;

### Command line file manager applications =====================================

"cli/ttycolors")

    silentsudo 'Copy TTY colors config' cp -rf "${ROOT_PATH}/files/tty" "${rootfs_dir}/tools/files/"

;;

### ============================================================================
### Optimizations ==============================================================
### ============================================================================

"optimize")

    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'optimize/tmpfs'
    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'optimize/chrome-ramdisk'
;;

### Mount directories with high I/O as tmpfs ===================================

"optimize/tmpfs")

    silentsudo 'Copy tmpfs config' cp -rf "${ROOT_PATH}/files/tmpfs" "${rootfs_dir}/tools/files/"

;;

### Keep Chromium's RAM disk between power-offs ================================

"optimize/chrome-ramdisk")

    silentsudo 'Copy chrome-ramdisk config' cp -rf "${ROOT_PATH}/files/chrome-ramdisk" "${rootfs_dir}/tools/files/"

;;

### ============================================================================
### ============================================================================
### ============================================================================

*)
    msgfail "[bundle '${bundle}' not found]"
;;

esac

