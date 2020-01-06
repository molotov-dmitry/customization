#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")/.." && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

bundle="$1"

scriptpath="${ROOT_PATH}/bundles/$(basename "$0")"

case "${bundle}" in

### ============================================================================
### Base system ================================================================
### ============================================================================

### Base system ================================================================

"base")

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

    bash "${scriptpath}" 'driver/intel'
    bash "${scriptpath}" 'driver/firmware'
    bash "${scriptpath}" 'driver/wifi'
    bash "${scriptpath}" 'driver/printer'
    bash "${scriptpath}" 'driver/fs'

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
    bash "${scriptpath}" 'appearance/wallpaper'
    bash "${scriptpath}" 'appearance/avatar'

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
    bash "${scriptpath}" 'network/remotedesktop'
    
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

;;

### Keep Chromium's RAM disk between power-offs ================================

"optimize/chrome-ramdisk")

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

;;

### ============================================================================
### Work =======================================================================
### ============================================================================

"work")

    ### Setup DNS names ========================================================

    cat << _EOF >> /etc/hosts
172.16.56.14    rczifort.local
172.16.56.15    redmine.rczifort.local
172.16.56.16    chat.rczifort.local
172.16.56.17    ex01.rczifort.local
172.16.56.22    git.rczifort.local
172.16.56.23    data.rczifort.local

_EOF

;;

"work-mail")

;;

### ============================================================================
### ============================================================================
### ============================================================================

esac
