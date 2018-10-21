#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")/.." && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

bundle="$1"

scriptpath="${ROOT_PATH}/bundles/$(basename "$0")"

case "${bundle}" in

### ============================================================================
### Gnome ======================================================================
### ============================================================================

"gnome")

    ## Cursor theme ------------------------------------------------------------

    dgm3_theme='gnome-shell'

    silent 'Set GDM3 theme' update-alternatives --set gdm3.css "/usr/share/gnome-shell/theme/${dgm3_theme}.css"

;;

### ============================================================================
### Qt =========================================================================
### ============================================================================

"qt")

    ## Qt5 GTK2 theme ----------------------------------------------------------

    if ispkginstalled gnome-shell
    then
        if ispkginstalled 'libqt5libqgtk2'
        then

            echo 'export QT_QPA_PLATFORMTHEME=qt5gtk2' >> /etc/environment

        elif ispkginstalled 'qt5-style-plugins'
        then

            echo 'export QT_QPA_PLATFORMTHEME=gtk2' >> /etc/environment

        fi
    fi

;;

### ============================================================================
### Drivers ====================================================================
### ============================================================================

"driver")

    bash "${scriptpath}" 'driver/intel'
    bash "${scriptpath}" 'driver/firmware'

;;

### Intel drivers ==============================================================

"driver/intel")

;;

### Firmwares ==================================================================

"driver/firmware")

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

    silentsudo 'Configuring Open SSH' touch /etc/ssh/sshd_config
    silentsudo 'Configuring Open SSH' sed -i '/^ClientAliveInterval/d;/^ClientAliveCountMax/d' /etc/ssh/sshd_config
    silentsudo 'Configuring Open SSH' bash -c 'echo -e "\nClientAliveInterval 300\nClientAliveCountMax 2" >> /etc/ssh/sshd_config'

;;

### FTP server =================================================================

"server/ftp")

    silentsudo 'Configuring vsftpd'     cp -f "${ROOT_PATH}/files/vsftpd/vsftpd.conf" '/etc/'

;;

### SMB server =================================================================

"server/smb")

    silentsudo 'Creating Samba config dir'      mkdir -p '/etc/samba'
    silentsudo 'Configuring Samba'              cp -f "${ROOT_PATH}/files/samba/smb.conf" '/etc/samba/'

;;

### SVN server =================================================================

"server/svn")

    addservice 'Subversion server'      'svnserve' 'svnserve'

;;

### DB server ==================================================================

"server/db")

    bash "${scriptpath}" "server/db/postgres"

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

    silentsudo 'Inotyfy max watchs fix' bash -c 'echo -e "fs.inotify.max_user_watches = 100000" > /etc/sysctl.d/90-inotify.conf'
    silentsudo 'Inotify max watchs fix' sysctl fs.inotify.max_user_watches=100000

    silentsudo 'Configuring MiniDLNA'   sudo cp -f "${ROOT_PATH}/files/minidlna/minidlna.conf" '/etc/'

    ## Plex Media Server -------------------------------------------------------

    silentsudo 'Creating Plex config dir'   mkdir -p '/var/lib/plexmediaserver/Library/Application Support/Plex Media Server'
    silentsudo 'Configuring Plex'           sudo cp -f "${ROOT_PATH}/files/plexmediaserver/Preferences.xml" '/var/lib/plexmediaserver/Library/Application Support/Plex Media Server/'
    silentsudo 'Changing Plex config owner' chown -R plex:plex '/var/lib/plexmediaserver'

    silentsudo 'Modify firstboot script'    sed -i 's/^After=/After=plexmediaserver.service /' '/tools/files/custom-startup.service'

;;

### Download server ============================================================

"server/download")

    ## Transmission ------------------------------------------------------------

    silentsudo 'Creating Transmission config dir' mkdir -p '/etc/transmission-daemon'
    silentsudo 'Configuring Transmission'   cp -f "${ROOT_PATH}/files/transmission/settings.json" '/etc/transmission-daemon/'

    ## EiskaltDC++ -------------------------------------------------------------

    silentsudo 'Creating EiskaltDC++ config dir' mkdir -p '/etc/eiskaltdcpp'
    silentsudo 'Configuring EiskaltDC++'        cp -f "${ROOT_PATH}/files/eiskaltdcpp/DCPlusPlus.xml" '/etc/eiskaltdcpp/'
    silentsudo 'Configuring EiskaltDC++ Hubs'   cp -f "${ROOT_PATH}/files/eiskaltdcpp/Favorites.xml" '/etc/eiskaltdcpp/'

    addservice 'EiskaltDC++' 'eiskaltdcpp' 'eiskaltdcpp'

;;

### Proxy server ===============================================================

"server/proxy")

    ## Squid3 ------------------------------------------------------------------

    silentsudo 'Creating Squid3 config dir' mkdir -p '/etc/squid3'
    silentsudo 'Configuring Squid3'         cp -f "${ROOT_PATH}/files/squid3/squid.conf" '/etc/squid3/'
    silentsudo 'Creating Squid3 users list' touch '/etc/squid3/internet_users'

;;

### GitLab =====================================================================

"gitlab")

    if [[ -d /etc/nginx/sites-enabled/default ]]
    then
        silentsudo 'Removing default nginx site' rm /etc/nginx/sites-enabled/default
    fi

    silentsudo 'Modify firstboot script'    sed -i 's/^After=/After=postgresql.service /' '/tools/files/custom-startup.service'

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

    if [[ -f /etc/sysctl.d/10-ptrace.conf ]]
    then
        silentsudo 'Ptrace fix'             sed -i 's/[ \t]*kernel.yama.ptrace_scope[ \t]*=[ \t]*1/kernel.yama.ptrace_scope = 0/' /etc/sysctl.d/10-ptrace.conf
    fi

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

### Qt SDK =====================================================================

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

    sed -i 's/PATH="\([^"]*\)"/PATH="\1:\/opt\/TI\/C6000CGT6.0.11\/bin"/' /etc/environment
    echo 'export C6X_C_DIR="/opt/TI/C6000CGT6.0.11/include"' >> /etc/environment

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

    ## Grub theme --------------------------------------------------------------

    silent 'Set Grub theme' sed -i 's/44,0,30,0/55,71,79,0/' /usr/share/plymouth/themes/default.grub

    ## Cursor theme ------------------------------------------------------------

    cursor_theme='breeze_cursors'

    silent 'Set cursor theme' update-alternatives --set x-cursor-theme "/etc/X11/cursors/${cursor_theme}.theme"

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
    bash "${scriptpath}" 'network/chat-extra'
    bash "${scriptpath}" 'network/office'
    bash "${scriptpath}" 'network/services'
    bash "${scriptpath}" 'network/remote'
    
;;

### Browser ====================================================================

"network/browser")

;;

### Mail =======================================================================

"network/mail")

;;

### Chat =======================================================================

"network/chat")

    ## Empathy -----------------------------------------------------------------

    #mkdir -p '/usr/share/adium/message-styles'
    #cp -rf "${ROOT_PATH}/files/empathy/material.AdiumMessageStyle" '/usr/share/adium/message-styles/'

    #while read color
    #do
    #    colorvalue=$(echo "${color}" | cut -d ' ' -f 1)
    #    colorname=$(echo "${color}" | cut -d ' ' -f 2-)

    #    bash '/usr/share/adium/message-styles/material.AdiumMessageStyle/Contents/Resources/create.sh' "${colorname}" "${colorvalue}"

    #done < '/usr/share/adium/message-styles/material.AdiumMessageStyle/Contents/Resources/colorlist'

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

    silentsudo '' mkdir -p /etc/profile.d
    silentsudo 'Copy TTY colors config' cp -f "${ROOT_PATH}/files/tty/colors.sh" '/etc/profile.d/'

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
### ============================================================================
### ============================================================================

*)
    msgfail "[bundle '${bundle}' not found]"
;;

esac

