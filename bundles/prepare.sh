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
### Server =====================================================================
### ============================================================================

"server")

    bash "${scriptpath}" 'server/ftp'
    bash "${scriptpath}" 'server/svn'

;;

### FTP server =================================================================

"server/ftp")

    silentsudo "Copy vsftpd config" cp -rf "${ROOT_PATH}/files/vsftpd" "${rootfs_dir}/tools/files/"

;;

### SMB server =================================================================

"server/smb")

    #TODO

;;

### SVN server =================================================================

"server/svn")

    silentsudo "Copy svnserve unit" cp -rf "${ROOT_PATH}/svnserve" "${rootfs_dir}/tools/files/"
    
;;

### Media server ===============================================================

"server/media")

    #TODO

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

    silentsudo 'Copy Rhythmbox radio database' cp -rf "${ROOT_PATH}/files/rhythmbox" "${rootfs_dir}/tools/files/"

;;

### ============================================================================
### Network ====================================================================
### ============================================================================

### Network and communication ==================================================

"network")

    silentsudo 'Copy Empathy theme' cp -rf "${ROOT_PATH}/files/empathy" "${rootfs_dir}/tools/files/"

;;

### Network remote =============================================================

"network-remote")

    silentsudo 'Copy Transmission remote config' cp -rf "${ROOT_PATH}/files/transmission-remote-gtk" "${rootfs_dir}/tools/files/"
    #TODO eiskaltdcpp-qt5 config

;;

### ============================================================================
### ============================================================================
### ============================================================================

*)
    msgfail "[bundle '${bundle}' not found]"
;;

esac

