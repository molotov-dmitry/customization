#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")/.." && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

bundle="$3"
config="$1"
rootfs_dir="$2"

case "${bundle}" in

### Office =====================================================================

"office")

    ## Libreoffice  ------------------------------------------------------------

    silentsudo 'Copy Libreoffice config' cp -rf "${ROOT_PATH}/files/libreoffice" "${rootfs_dir}/tools/files/"

;;

### Multimedia applications ====================================================

"media")
    silentsudo 'Copy Rhythmbox radio database' cp -rf "${ROOT_PATH}/files/rhythmbox" "${rootfs_dir}/tools/files/"
;;

### Network remote =============================================================

"network-remote")

    silentsudo 'Copy Transmission remote config' cp -rf "${ROOT_PATH}/files/transmission-remote-gtk" "${rootfs_dir}/tools/files/"
    #TODO eiskaltdcpp-qt5 config

;;

### ============================================================================

*)
    msgfail "[bundle '${bundle}' not found]"
;;

esac
