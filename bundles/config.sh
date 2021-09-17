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

    if dpkg --compare-versions "$(pkgversion bash)" ge 5.1
    then
        echo -e "\nbind 'set enable-bracketed-paste off'" >> /etc/bash.bashrc
    fi

;;

### Base GUI ===================================================================

"gui")

    if ispkginstalled gdm3
    then
        silent 'Modify firstboot script'    addconfigline 'Before' 'gdm.service' 'Unit' '/etc/systemd/system/custom-startup.service.d/before-gdm.conf'
    fi

    if ispkginstalled sddm
    then
        silent 'Modify firstboot script'    addconfigline 'Before' 'sddm.service' 'Unit' '/etc/systemd/system/custom-startup.service.d/before-sddm.conf'
    fi

;;

### GTK-based GUI ==============================================================

"gtk")

;;

### ============================================================================
### DM =========================================================================
### ============================================================================

### Gnome ======================================================================

"gnome")

    ## GDM3 theme --------------------------------------------------------------

    if [[ "$(lsb_release -si)" == "Ubuntu" ]] && ispkginstalled gdm3
    then
        if update-alternatives --list gdm3-theme.gresource >/dev/null 2>/dev/null
        then
            silent 'Set GDM3 theme' update-alternatives --set gdm3-theme.gresource "/usr/share/gnome-shell/gnome-shell-theme.gresource"
        fi
    fi

    ## Disbale Wayland ---------------------------------------------------------

    if test -f '/etc/gdm3/custom.conf'
    then
        addconfigline 'WaylandEnable' 'false' 'daemon' '/etc/gdm3/custom.conf'
    fi

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

    ## Qt5 GTK2 theme ----------------------------------------------------------

    cat >> /etc/profile.d/50-qt-qpa-platformtheme-gtk2.sh << "_EOF"
case "${XDG_SESSION_DESKTOP}" in

'unity' | 'gnome' | 'gnome-xorg' | 'ubuntu' | 'ubuntu-wayland' | 'ubuntu-xorg' | 'cinnamon' | 'cinnamon2d')

    export QT_QPA_PLATFORMTHEME=gtk2

;;

esac

true

_EOF

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

    silent 'Configuring Open SSH' touch /etc/ssh/sshd_config
    silent 'Configuring Open SSH' sed -i '/^ClientAliveInterval/d;/^ClientAliveCountMax/d' /etc/ssh/sshd_config
    silent 'Configuring Open SSH' bash -c 'echo -e "\nClientAliveInterval 300\nClientAliveCountMax 2" >> /etc/ssh/sshd_config'

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

    silent 'Inotyfy max watchs fix' bash -c 'echo -e "fs.inotify.max_user_watches = 100000" > /etc/sysctl.d/90-inotify.conf'
    silent 'Inotify max watchs fix' sysctl fs.inotify.max_user_watches=100000

    silent 'Configuring MiniDLNA'   cp -f "${ROOT_PATH}/files/minidlna/minidlna.conf" '/etc/'

    ## Plex Media Server -------------------------------------------------------

    silent 'Creating Plex config dir'   mkdir -p '/var/lib/plexmediaserver/Library/Application Support/Plex Media Server'
    silent 'Configuring Plex'           cp -f "${ROOT_PATH}/files/plexmediaserver/Preferences.xml" '/var/lib/plexmediaserver/Library/Application Support/Plex Media Server/'
    silent 'Changing Plex config owner' chown -R plex:plex '/var/lib/plexmediaserver'

    silent 'Modify firstboot script'    addconfigline 'After' 'plexmediaserver.service' 'Unit' '/etc/systemd/system/custom-startup.service.d/after-plexmediaserver.conf'

;;

### Download server ============================================================

"server/download")

    ## Transmission ------------------------------------------------------------

    silent 'Creating Transmission config dir' mkdir -p '/etc/transmission-daemon'
    silent 'Configuring Transmission'   cp -f "${ROOT_PATH}/files/transmission/settings.json" '/etc/transmission-daemon/'

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
    bash "${scriptpath}" 'dev/markdown'
    bash "${scriptpath}" 'dev/net'
    bash "${scriptpath}" 'dev/ti'

;;

### Build tools ================================================================

"dev/build")

    ## Fix ptrace --------------------------------------------------------------

    if [[ -f /etc/sysctl.d/10-ptrace.conf ]]
    then
        silent 'Ptrace fix'             sed -i 's/[ \t]*kernel.yama.ptrace_scope[ \t]*=[ \t]*1/kernel.yama.ptrace_scope = 0/' /etc/sysctl.d/10-ptrace.conf
    fi

    ## Enable dmesg for all users ----------------------------------------------

    silent 'Fix dmesg restriction' bash -c 'echo -e "kernel.dmesg_restrict = 0" > /etc/sysctl.d/90-dmesg.conf'
    silent 'Fix dmesg restriction' sysctl kernel.dmesg_restrict=0

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
    bash "${scriptpath}" 'appearance/wallpaper'
    bash "${scriptpath}" 'appearance/avatar'

;;

### Desktop theme ==============================================================

"appearance/themes")

    ## Cursor theme ------------------------------------------------------------

    cursor_theme='breeze_cursors'

    silent 'Set cursor theme' update-alternatives --set x-cursor-theme "/etc/X11/cursors/${cursor_theme}.theme"

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

    silent 'Fix ping restriction' bash -c 'echo -e "net.ipv4.ping_group_range = 0 2147483647" > /etc/sysctl.d/99-allow-ping.conf'
    silent 'Fix ping restriction' sysctl net.ipv4.ping_group_range='0 2147483647'

;;

### Command line tools for time sync ===========================================

"cli/time")

;;

### TTY colors =================================================================

"cli/ttycolors")

    silent '' mkdir -p /etc/profile.d
    silent 'Copy TTY colors config' cp -f "${ROOT_PATH}/files/tty/colors.sh" '/etc/profile.d/'

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
    bash "${scriptpath}" 'optimize/disable-tracker'
;;

### Mount directories with high I/O as tmpfs ===================================

"optimize/tmpfs")

;;

### Disable Gnome tracker ======================================================

"optimize/disable-tracker")

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

    disableservice 'Cups Browser' cups-browsed

;;


### Mail =======================================================================

"work-mail")

;;

### Chat =======================================================================

"work-chat")

    ## Empathy -----------------------------------------------------------------

    if ispkginstalled empathy
    then
        mkdir -p '/usr/share/adium/message-styles'
        cp -rf "${ROOT_PATH}/files/empathy/material.AdiumMessageStyle" '/usr/share/adium/message-styles/'

        while read color
        do
            colorvalue=$(echo "${color}" | cut -d ' ' -f 1)
            colorname=$(echo "${color}" | cut -d ' ' -f 2-)

            bash '/usr/share/adium/message-styles/material.AdiumMessageStyle/Contents/Resources/create.sh' "${colorname}" "${colorvalue}"

        done < '/usr/share/adium/message-styles/material.AdiumMessageStyle/Contents/Resources/colorlist'
    fi

    ## Kopete ------------------------------------------------------------------

    if ispkginstalled kopete
    then
        mkdir -p '/usr/share/kopete/styles'
        cp -rf "${ROOT_PATH}/files/empathy/material.AdiumMessageStyle" '/usr/share/kopete/styles/material'

        while read color
        do
            colorvalue=$(echo "${color}" | cut -d ' ' -f 1)
            colorname=$(echo "${color}" | cut -d ' ' -f 2-)

            bash '/usr/share/kopete/styles/material/Contents/Resources/create.sh' "${colorname}" "${colorvalue}"

        done < '/usr/share/kopete/styles/material/Contents/Resources/colorlist'
    fi

    ## -------------------------------------------------------------------------
;;

### Remote desktop =============================================================

"work-remote")

;;

### ============================================================================
### ============================================================================
### ============================================================================

*)
    msgfail "[bundle '${bundle}' not found]"
;;

esac

