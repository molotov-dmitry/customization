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
### DM =========================================================================
### ============================================================================

### Gnome ======================================================================

"gnome")

    silent "Copy templates"         cp -rf "${ROOT_PATH}/files/template" "${rootfs_dir}/tools/files/"

;;

### Cinnamon ===================================================================

"cinnamon")

    silent "Copy redshift config"   cp -rf "${ROOT_PATH}/files/redshift" "${rootfs_dir}/tools/files/"

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

    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'driver/intel'
    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'driver/firmware'
    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'driver/wifi'
    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'driver/printer'
    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'driver/fs'

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

    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'server/ssh'
    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'server/ftp'
    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'server/smb'
    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'server/svn'
    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'server/db'
    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'server/iperf'
    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'server/media'
    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'server/download'
    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'server/proxy'

;;

### OpenSSH server =============================================================

"server/ssh")

;;

### FTP server =================================================================

"server/ftp")

    silent "Copy vsftpd config" cp -rf "${ROOT_PATH}/files/vsftpd" "${rootfs_dir}/tools/files/"

;;

### SMB server =================================================================

"server/smb")

    silent 'Copy Samba config'  cp -rf "${ROOT_PATH}/files/samba"           "${rootfs_dir}/tools/files/"

;;

### SVN server =================================================================

"server/svn")

    silent "Copy svnserve unit" cp -rf "${ROOT_PATH}/files/svnserve" "${rootfs_dir}/tools/files/"

;;

### DB server ==================================================================

"server/db")

    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'server/db/postgres'

;;

### Postgres -------------------------------------------------------------------

"server/db/postgres")

;;

### Iperf server ===============================================================

"server/iperf")

;;

### Media server ===============================================================

"server/media")

     ## MiniDLNA ----------------------------------------------------------------

    silent 'Copy MiniDLNA config' cp -rf "${ROOT_PATH}/files/minidlna"          "${rootfs_dir}/tools/files/"

    ## Plex Media Server -------------------------------------------------------

    silent 'Copy Plex config' cp -rf "${ROOT_PATH}/files/plexmediaserver"   "${rootfs_dir}/tools/files/"

;;

### Download server ============================================================

"server/download")

    silent 'Copy Transmission config'   cp -rf "${ROOT_PATH}/files/transmission" "${rootfs_dir}/tools/files/"
    #silent 'Copy EiskaltDC++ config'    cp -rf "${ROOT_PATH}/files/eiskaltdcpp"  "${rootfs_dir}/tools/files/"

;;

### Proxy server ===============================================================

"server/proxy")

    ## Squid3 ------------------------------------------------------------------

    silent 'Copy Squid config'          cp -rf "${ROOT_PATH}/files/squid3" "${rootfs_dir}/tools/files/"

;;

### GitLab =====================================================================

"gitlab")

;;

### ============================================================================
### Development ================================================================
### ============================================================================

"dev")

    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'dev/build'
    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'dev/analysis'
    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'dev/style'
    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'dev/doc'
    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'dev/man'
    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'dev/x11'
    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'dev/opengl'
    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'dev/qt'
    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'dev/qt4'
    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'dev/gtk'
    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'dev/gnome'
    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'dev/db'
    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'dev/json'
    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'dev/net'
    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'dev/ti'

;;

### Build tools ================================================================

"dev/build")

;;

### Code analysis tools ========================================================

"dev/analysis")

;;

### Code formatting ============================================================

"dev/style")

    mkdir "${rootfs_dir}/etc/skel"

    silent 'Copy astyle config'       cp -rf "${ROOT_PATH}/files/codestyle/.astylerc" "${rootfs_dir}/etc/skel/"
    silent 'Copy clang-format config' cp -rf "${ROOT_PATH}/files/codestyle/.clang-format" "${rootfs_dir}/etc/skel/"

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

    ## Qt Creator --------------------------------------------------------------

    silent 'Copy QtCreator config' cp -rf "${ROOT_PATH}/files/qtcreator" "${rootfs_dir}/tools/files/"

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

;;

### TI TMS320C64XX =============================================================

"dev/ti")

    ## Code Generation Tools ---------------------------------------------------

    silent 'Create TI toolchain folder' mkdir -p "${rootfs_dir}/opt/TI"
    silent 'Extract TI toolchain'       tar xf "${ROOT_PATH}/files/ti/C6000CGT6.0.11.tar.xz" -C "${rootfs_dir}/opt/TI/"

    ## CCS Project editor ------------------------------------------------------

    mkdir -p "${rootfs_dir}/usr/local/share/mime/packages"
    silent 'Install CCS project MIME info' cp "${ROOT_PATH}/files/ti/text-x-ccs-pjt.xml" "${rootfs_dir}/usr/local/share/mime/packages/"

;;

### ============================================================================
### Version control system =====================================================
### ============================================================================

"vcs")

    silent "Copy RabbitVCS folder"      cp -rf "${ROOT_PATH}/files/rabbitvcs" "${rootfs_dir}/tools/files/"

;;

### ============================================================================
### Appearance =================================================================
### ============================================================================

"appearance")

    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'appearance/themes'
    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'appearance/fonts'
    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'appearance/wallpaper'

;;

### Desktop theme ==============================================================

"appearance/themes")

;;

### System fonts ===============================================================

"appearance/fonts")

;;

### Wallpaper ==================================================================

"appearance/wallpaper")

    silent "Copy backgrounds"   cp -rf "${ROOT_PATH}/files/backgrounds" "${rootfs_dir}/tools/files/"

;;

### ============================================================================
### Office applications ========================================================
### ============================================================================

"office")

    ## LibreOffice -------------------------------------------------------------

    silent 'Copy Libreoffice config' cp -rf "${ROOT_PATH}/files/libreoffice" "${rootfs_dir}/tools/files/"

    ## OnlyOffice --------------------------------------------------------------

    #silent 'Copy OnlyOffice config' cp -rf "${ROOT_PATH}/files/onlyoffice" "${rootfs_dir}/tools/files/"

;;

### ============================================================================
### Multimedia applications ====================================================
### ============================================================================

### Local music/video  =========================================================

"media")

    ## Rhythmbox ---------------------------------------------------------------

    silent 'Copy Rhythmbox radio database' cp -rf "${ROOT_PATH}/files/rhythmbox" "${rootfs_dir}/tools/files/"

    ## MPV ---------------------------------------------------------------------

    silent 'Copy MPV config' cp -rf "${ROOT_PATH}/files/mpv" "${rootfs_dir}/tools/files/"

;;

### Online video ===============================================================

"media-online")

;;

### ============================================================================
### Network and communication ==================================================
### ============================================================================

"network")

    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'network/browser'
    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'network/mail'
    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'network/chat'
    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'network/chat-extra'
    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'network/office'
    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'network/services'
    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'network/remote'
    
;;

### Browser ====================================================================

"network/browser")

    silent 'Copy Chrome files' cp -rf "${ROOT_PATH}/files/chrome" "${rootfs_dir}/tools/files/"

    mkdir -p "${rootfs_dir}/etc/default"

    echo 'repo_add_once="false"'                >  "${rootfs_dir}/etc/default/google-chrome"
    echo 'repo_reenable_on_distupgrade="false"' >> "${rootfs_dir}/etc/default/google-chrome"

;;

### Mail =======================================================================

"network/mail")

;;

### Chat =======================================================================

"network/chat")

    #silent 'Copy Empathy theme and config' cp -rf "${ROOT_PATH}/files/empathy" "${rootfs_dir}/tools/files/"

    silent 'Copy Pidgin theme and config' cp -rf "${ROOT_PATH}/files/pidgin" "${rootfs_dir}/tools/files/"

;;

### Chat extra protocols =======================================================

"network/chat-extra")

    silent 'Copy Telegram files' cp -rf "${ROOT_PATH}/files/telegram" "${rootfs_dir}/tools/files/"
    silent 'Copy VK files'       cp -rf "${ROOT_PATH}/files/vk"       "${rootfs_dir}/tools/files/"

;;

### Office =====================================================================

"network/office")

;;

### Online services ============================================================

"network/services")

;;

### Remote clients =============================================================

"network/remote")

    silent 'Copy Transmission remote config' cp -rf "${ROOT_PATH}/files/transmission-remote-gtk" "${rootfs_dir}/tools/files/"

    #debprepare 'EiskaltDC++ Remote Qt' 'eiskaltdcpp-remote-qt' '27' 'amd64'
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

    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'cli/files'
    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'cli/monitor'
    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'cli/net'
    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'cli/time'
    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'cli/ttycolors'

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

    silent 'Copy TTY colors config' cp -rf "${ROOT_PATH}/files/tty" "${rootfs_dir}/tools/files/"

;;

### ============================================================================
### Folders setup ==============================================================
### ============================================================================

"folders")

;;

### ============================================================================
### Optimizations ==============================================================
### ============================================================================

"optimize")

    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'optimize/tmpfs'
    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'optimize/chrome-ramdisk'
    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'optimize/disable-tracker'
;;

### Mount directories with high I/O as tmpfs ===================================

"optimize/tmpfs")

    silent 'Copy tmpfs config' cp -rf "${ROOT_PATH}/files/tmpfs" "${rootfs_dir}/tools/files/"

;;

### Keep Chromium's RAM disk between power-offs ================================

"optimize/chrome-ramdisk")

    silent 'Copy chrome-ramdisk config' cp -rf "${ROOT_PATH}/files/chrome-ramdisk" "${rootfs_dir}/tools/files/"

;;

### Disable Gnome tracker ======================================================

"optimize/disable-tracker")

;;

### ============================================================================
### Virtual machine tools ======================================================
### ============================================================================

"vm-guest")

    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'vm-guest/vmware'
    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'vm-guest/vbox'
;;

"vm-guest/vmware")

;;

"vm-guest/vbox")

;;

### ============================================================================
### Virtual machine host tools =================================================
### ============================================================================

"vm-host")

    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'vm-host/vbox'

;;

"vm-host/vbox")

;;

### ============================================================================
### ============================================================================
### ============================================================================

*)
    msgfail "[bundle '${bundle}' not found]"
;;

esac

