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

    repoaddnonfree
    changemirror 'mirror.yandex.ru'

    sed -i '/^[ \t]*deb-src /d' /etc/apt/sources.list

    if [[ "$(timedatectl show -p LocalRTC --value)" != 'no' ]]
    then
        timedatectl set-local-rtc 0
    fi

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
    bash "${scriptpath}" 'server/svn'
    bash "${scriptpath}" 'server/db'
    bash "${scriptpath}" 'server/iperf'
    bash "${scriptpath}" 'server/media'
    bash "${scriptpath}" 'server/download'

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

    sleep 30

    su -c 'export LD_LIBRARY_PATH=/usr/lib/plexmediaserver; /usr/lib/plexmediaserver/Plex\ Media\ Scanner -n "Музыка" --type 8 --location "/media/documents/Music"' - plex
    su -c 'export LD_LIBRARY_PATH=/usr/lib/plexmediaserver; /usr/lib/plexmediaserver/Plex\ Media\ Scanner -n "Видео" --type 1 --location "/media/documents/Video"' - plex

;;

### Download server ============================================================

"server/download")

    # Stub self-signed certificate for Transmission ----------------------------

    mkdir -p '/media/documents/cert'

    if [[ ! -f '/media/documents/cert/transmission.pem' ]]
    then
        ssh-keygen  \
            -t rsa  \
            -b 4096 \
            -P ''   \
            -m PEM  \
            -f '/media/documents/cert/transmission.pem'
    fi

    if [[ ! -f '/media/documents/cert/transmission.crt' ]]
    then
        openssl req -new -x509                            \
            -key '/media/documents/cert/transmission.pem' \
            -days 1095                                    \
            -subj '/C=/ST=/L=/O=/CN=127.0.0.1'            \
            -addext 'subjectAltName=IP:127.0.0.1'         \
            -out '/media/documents/cert/transmission.crt'
    fi

    if [[ ! -L '/etc/nginx/sites-enabled/transmission.conf' ]]
    then
        mkdir -p '/etc/nginx/sites-enabled'
        ln -s '/etc/nginx/sites-available/transmission.conf' '/etc/nginx/sites-enabled/transmission.conf'
    fi

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
    bash "${scriptpath}" 'dev/qt'
    bash "${scriptpath}" 'dev/gtk'
    bash "${scriptpath}" 'dev/gnome'
    bash "${scriptpath}" 'dev/db'
    bash "${scriptpath}" 'dev/json'
    bash "${scriptpath}" 'dev/markdown'
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
    bash "${scriptpath}" 'network/remote'
    
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

    bash "${scriptpath}" 'cli/files'
    bash "${scriptpath}" 'cli/monitor'
    bash "${scriptpath}" 'cli/net'

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

    if [[ -z "$(grep -v "^#" /etc/fstab | grep /media/documents | grep x-gvfs-hide)" ]]
    then
        sed -i 's/\(\/media\/documents[[:space:]]\+[^[:space:]]\+[[:space:]]\+\)defaults\([[:space:]]\+\)/\1defaults,x-gvfs-hide\2/' /etc/fstab
    fi

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

    network-init

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
