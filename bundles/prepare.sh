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

    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'server/ftp'
    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'server/smb'
    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'server/svn'
    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'server/media'
    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'server/download'

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

    debprepare 'Plex Media Server' 'plexmediaserver' '1.3.3.3148-b38628e' 'amd64'
    
    silentsudo 'Copy Plex config' cp -rf "${ROOT_PATH}/files/plexmediaserver"   "${rootfs_dir}/tools/files/"

;;

### Download server ============================================================

"server/download")

    silentsudo 'Copy Transmission config'   cp -rf "${ROOT_PATH}/files/transmission" "${rootfs_dir}/tools/files/"
    silentsudo 'Copy EiskaltDC++ config'    cp -rf "${ROOT_PATH}/files/eiskaltdcpp"  "${rootfs_dir}/tools/files/"

;;

### GitLab =====================================================================

"gitlab")

    mkdir -p "${rootfs_dir}/tools/packages"

    pushd "${rootfs_dir}/tools/packages" > /dev/null

    silentsudo 'Download Gitlab package' apt download gitlab

    pkgname=$(ls gitlab_*.deb | sed 's/^gitlab/gitlab-stub/' | sed 's/_.*_/_current_/')

    silentsudo '' mkdir -p gitlab-stub/DEBIAN
    silentsudo 'Extracting package info' dpkg -e gitlab*.deb gitlab-stub/DEBIAN

    pushd gitlab-stub/DEBIAN > /dev/null

    silentsudo 'Remove all info but control' find . -mindepth 1 ! -name 'control' -exec rm -rf {} +
    silentsudo 'Replacing package name' sed -i 's/^Package: gitlab/Package: gitlab-stub/' control

    popd > /dev/null

    silentsudo '' chmod -R 0755 gitlab-stub
    silentsudo 'Creating Gitlab stub package' fakeroot dpkg-deb --build gitlab-stub
    silentsudo 'Changing stub package name' mv gitlab-stub.deb "${pkgname}"

    silentsudo 'Removing temp files' rm -rf gitlab-stub

    popd > /dev/null

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

    silentsudo 'Copy Empathy theme and config' cp -rf "${ROOT_PATH}/files/empathy" "${rootfs_dir}/tools/files/"

;;

### Network remote =============================================================

"network-remote")

    silentsudo 'Copy Transmission remote config' cp -rf "${ROOT_PATH}/files/transmission-remote-gtk" "${rootfs_dir}/tools/files/"

    debprepare 'EiskaltDC++ Remote Qt' 'eiskaltdcpp-remote-qt' '26' 'amd64'
;;

### ============================================================================
### ============================================================================
### ============================================================================

*)
    msgfail "[bundle '${bundle}' not found]"
;;

esac

