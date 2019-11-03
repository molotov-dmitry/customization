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
### Base system ================================================================
### ============================================================================

### Base system ================================================================

"base")

    preparefiles 'AHome' 'ahome'

;;

### Base GUI ===================================================================

"gui")

    preparefiles 'templates' 'template'

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

    preparefiles 'Redshift' 'redshift'

;;

### KDE ========================================================================

"kde")

    preparefiles 'KDE'      'kde'
    preparefiles 'Konsole'  'konsole'
    preparefiles 'Kate'     'kate'

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

    preparefiles 'Vsftpd' 'vsftpd'

;;

### SMB server =================================================================

"server/smb")

    preparefiles 'Samba' 'samba'

;;

### SVN server =================================================================

"server/svn")

    preparefiles 'Svnserve' 'svnserve'

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

    preparefiles 'MiniDLNA' 'minidlna'

    ## Plex Media Server -------------------------------------------------------

    preparefiles 'Plex media server' 'plexmediaserver'

;;

### Download server ============================================================

"server/download")

    ## Transmission ------------------------------------------------------------

    preparefiles 'Transmission' 'transmission'

    ## EsikaltDC++ -------------------------------------------------------------

    preparefiles 'EiskaltDC++' 'eiskaltdcpp'

;;

### Proxy server ===============================================================

"server/proxy")

    ## Squid3 ------------------------------------------------------------------

    preparefiles 'Squid3' 'squid3'

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

    mkdir -p "${rootfs_dir}/etc/skel"

    silent 'Copy astyle config'       cp -rf "${ROOT_PATH}/files/codestyle/.astylerc"     "${rootfs_dir}/etc/skel/"
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

    preparefiles 'QtCreator' 'qtcreator'

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

    preparefiles 'RabbitVCS' 'rabbitvcs'

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

    preparefiles 'Backgrounds' 'backgrounds'

;;

### ============================================================================
### Office applications ========================================================
### ============================================================================

"office")

    ## LibreOffice -------------------------------------------------------------

    preparefiles 'LibreOffice' 'libreoffice'

    ## OnlyOffice --------------------------------------------------------------

    #silent 'Copy OnlyOffice config' cp -rf "${ROOT_PATH}/files/onlyoffice" "${rootfs_dir}/tools/files/"

;;

### ============================================================================
### Multimedia applications ====================================================
### ============================================================================

### Local music/video  =========================================================

"media")

    ## Rhythmbox ---------------------------------------------------------------

    preparefiles 'Rhythmbox' 'rhythmbox'

    ## MPV ---------------------------------------------------------------------

    preparefiles 'MPV' 'mpv'

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
    bash "${scriptpath}" "${config}" "${rootfs_dir}" 'network/remotedesktop'
    
;;

### Browser ====================================================================

"network/browser")

    preparefiles 'Chrome' 'chrome'

    mkdir -p "${rootfs_dir}/etc/default"

    echo 'repo_add_once="false"'                >  "${rootfs_dir}/etc/default/google-chrome"
    echo 'repo_reenable_on_distupgrade="false"' >> "${rootfs_dir}/etc/default/google-chrome"

;;

### Mail =======================================================================

"network/mail")

;;

### Chat =======================================================================

"network/chat")

    ## Empathy -----------------------------------------------------------------

    preparefiles 'Empathy' 'empathy'

    ## Pidgin ------------------------------------------------------------------

    preparefiles 'Pidgin' 'pidgin'

;;

### Chat extra protocols =======================================================

"network/chat-extra")

    ## Telegram ----------------------------------------------------------------

    preparefiles 'Telegram' 'telegram'

    ## VK ----------------------------------------------------------------------

    preparefiles 'VK' 'vk'

;;

### Office =====================================================================

"network/office")

;;

### Online services ============================================================

"network/services")

;;

### Remote clients =============================================================

"network/remote")

    preparefiles 'Transmission remote' 'transmission-remote-gtk'

    #debprepare 'EiskaltDC++ Remote Qt' 'eiskaltdcpp-remote-qt' '27' 'amd64'
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

    preparefiles 'TTY colors' 'tty'

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

    preparefiles 'tmpfs' 'tmpfs'

;;

### Keep Chromium's RAM disk between power-offs ================================

"optimize/chrome-ramdisk")

    preparefiles 'chrome-ramdisk' 'chrome-ramdisk'

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
### Work =======================================================================
### ============================================================================

"work")

;;

### ============================================================================
### ============================================================================
### ============================================================================

*)
    msgfail "[bundle '${bundle}' not found]"
;;

esac

