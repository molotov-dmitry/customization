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

    appinstall 'Bash completion'        'bash-completion'
    appinstall 'Sudo'                   'sudo'
    appinstall 'GRUB force menu'        'grub-force-menu'
    appinstall 'Rsync'                  'rsync'

;;

### Base GUI ===================================================================

"gui")

    appinstall 'Language pack'              'hyphen-ru mythes-ru hunspell-ru [language-pack-gnome-ru] [language-pack-gnome-ru-base] [language-pack-ru] [language-pack-ru-base]'

;;

### GTK-based GUI ==============================================================

"gtk")

    appinstall 'GTK+ modules' 'libcanberra-gtk-module libgail-common appmenu-gtk2-module appmenu-gtk3-module'

;;

### ============================================================================
### DM =========================================================================
### ============================================================================

### Gnome ======================================================================

"gnome")

    if gnomebased
    then

    if ispkginstalled ubuntu-session
    then
        appinstall 'Gnome session'          'gnome-shell gnome-session'
        appremove  'Ubuntu session'         'ubuntu-session ubuntu-settings gnome-shell-extension-ubuntu-dock yaru-theme-gnome-shell yaru-theme-gtk yaru-theme-icon'

        if ! ispkginstalled jq
        then
            apptmpinstall 'JSON processor' jq
        fi
    fi

    appinstall 'Nautilus'                   'nautilus nautilus-extension-gnome-terminal'

    appinstall 'Base applications'          'gnome-calculator gnome-system-monitor gnome-characters'
    appinstall 'Tweak tool'                 'gnome-tweaks'

    appinstall 'Gnome desktop directories'  'gnome-menus'

    appinstall 'Gnome appindicator support' 'gnome-shell-extension-appindicator'

    if ispkginstalled gnome-shell
    then
        if ispkgavailable gnome-shell-extension-ubuntu-dock && ! ispkgavailable gnome-shell-extension-dashtodock
        then
            appinstall 'Ubuntu Dock' 'gnome-shell-extension-ubuntu-dock'
        else
            gnomeshellextension 307  'Dash to Dock'                 ''        'gnome-shell-extension-dashtodock'
        fi

        gnomeshellextension 112  'Remove Accessibility'             'ge 3.34' 'gnome-shell-extension-remove-accesibility'
        gnomeshellextension 7    'Removable Drive Menu'

        gnomeshellextension 2917 'Bring Out Submenu Of Power Off/Logout Button'
    fi

    appinstall 'Gnome default config'       'custom-config-gnome'

    if ispkginstalled gedit
    then
        appinstall 'Gedit default config'   'custom-config-gedit'
    fi

    if ispkginstalled gnome-text-editor
    then
        appinstall 'Gnome Text Editor default config'   'custom-config-gnome-text-editor'
    fi

    if ispkginstalled gnome-terminal
    then
        appinstall 'Gnome Terminal default config'   'custom-config-gnome-terminal'
    fi

    fi
;;

### ============================================================================
### Qt =========================================================================
### ============================================================================

"qt")

    appinstall 'GTK2 style for Qt5'         'qt5-style-plugins custom-config-qt-gtk2-theme'
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

    appinstall 'Intel microcode'        'intel-microcode'
    appinstall 'Intel graphics'         'intel-media-va-driver-non-free i965-va-driver-shaders'

;;

### Firmwares ==================================================================

"driver/firmware")

    if [[ "$(lsb_release -si)" == "Ubuntu" ]]
    then

        appinstall 'Firmwares'          'linux-firmware'

    elif [[ "$(lsb_release -si)" == "Debian" ]]
    then

        appinstall 'Firmwares'          'firmware-linux'

    fi

;;

### Wi-Fi drivers ==============================================================

"driver/wifi")

;;

### Printer drivers and PPDs ===================================================

"driver/printer")

    appinstall 'HP PPD files'   'hpijs-ppds'

;;

### Filesystems support ========================================================

"driver/fs")

    appinstall 'exFAT support'  'exfat-fuse exfatprogs'
    appinstall 'CIFS support'   'cifs-utils'

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

    appinstall 'Open SSH'               'custom-config-openssh-server openssh-server'

;;

### SVN server =================================================================

"server/svn")

    appinstall 'Subversion'             'subversion svnserve-daemon'
    appinstall 'Repo creation tool'     'svn-repo-create'

;;

### DB server ==================================================================

"server/db")

    bash "${scriptpath}" "server/db/postgres"

;;

### Postgres -------------------------------------------------------------------

"server/db/postgres")

    appinstall 'Postgres DB server'     'postgresql'

;;

### Iperf server ===============================================================

"server/iperf")

    appinstall 'Iperf'                  'iperf iperf3'
;;

### Media server ===============================================================

"server/media")

    appinstall 'MiniDLNA'               'minidlna custom-config-minidlna'
    appinstall 'Plex Media Server'      'plexmediaserver'

    appinstall 'Inotify max watch'      'custom-config-sysctl-inotify-max-watch'

;;

### Download server ============================================================

"server/download")

    appinstall 'Youtube downloader'     'yt-dlp yt-dlp-scripts phantomjs'
    appinstall 'Transmission'           'transmission-daemon'
    appinstall 'NGINX Web server'       'nginx'

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

    appinstall 'Build tools'            'build-essential unifdef'
    appinstall 'GCC'                    'gcc g++ gdb'
    appinstall 'Multilib tools'         'gcc-multilib g++-multilib'
    appinstall 'Clang'                  'llvm clang lldb'

    appinstall 'CRLF to LF'             'dos2unix'

    appinstall 'Allow user debug'       'custom-config-sysctl-ptrace-scope custom-config-sysctl-allow-user-dmesg'

    if havegraphics
    then
        appinstall 'Develop templates'  'file-templates-develop'
    fi

;;

### Code analysis tools ========================================================

"dev/analysis")

    appinstall 'Static analysis tools'  'cppcheck'
    appinstall 'Dynamic analysis tools' 'valgrind'
    appinstall 'Function complexity'    'pmccabe'

;;

### Code formatting ============================================================

"dev/style")

    appinstall 'Code beautifier'        'astyle clang-format custom-config-codestyle'
    appinstall 'UTF-8 BOM'              'utf8bom'

;;

### Documentation tools ========================================================

"dev/doc")

    appinstall 'Doxygen'                'doxygen graphviz'

;;

### Documentation and references ===============================================

"dev/man")

    appinstall 'References'             'manpages-posix-dev manpages-dev'

    if gnomebased
    then
        appinstall 'Devhelp'            'devhelp'
        appinstall 'References HTML'    'cppreference-doc-en-html'
    fi

;;

### Qt SDK =====================================================================

"dev/qt")

    appinstall 'Qt SDK'                 'qtbase5-dev-tools qml qtbase5-dev qtdeclarative5-dev qt5-doc'
    appinstall 'Qt Libs'                'libqt5svg5 libqt5svg5-dev libqt5webkit5-dev libqt5charts5-dev libqt5xmlpatterns5-dev libqt5x11extras5-dev libqt5serialport5-dev libqt5sql5-sqlite'

    if havegraphics
    then
        appinstall 'Qt IDE'             'qtcreator qtcreator-mime'
    fi

;;

### GTK SDK ====================================================================

"dev/gtk")

    appinstall 'GTK+ SDK'               'libgtk-3-dev libgtkmm-3.0-dev libtool libtool-bin'
    appinstall 'GTK+ Libs'              'libgtksourceview-3.0-dev libgtksourceview-3.0-1 libgtksourceviewmm-3.0-0v5 libgtksourceview-3.0-dev libpeas-1.0-0 libpeas-dev libgit2-glib-1.0-dev libgit2-glib-1.0-0'

;;

### Gnome SDK ==================================================================

"dev/gnome")

    if gnomebased
    then
        appinstall 'GNOME Builder'      'gnome-builder custom-config-gnome-builder'
    fi

;;

### Database ===================================================================

"dev/db")

    appinstall 'Postgres'               'postgresql-client libpq5 libpq-dev'
    appinstall 'SQLite'                 'sqlite3 libsqlite3-0 libsqlite3-dev'

;;

### JSON libraries =============================================================

"dev/json")

    appinstall 'JSON libraries'         'libjsoncpp-dev'

;;

### Markdown editor ============================================================

"dev/markdown")

    if gnomebased
    then
        appinstall 'Marker'             'marker custom-config-marker'
    fi

;;

### Network ====================================================================

"dev/net")

    appinstall 'ARPing'                 'iputils-arping'

    silent     'Wireshark fix'          sh -c 'echo "wireshark-common wireshark-common/install-setuid boolean true" | debconf-set-selections'

    if havegraphics
    then
        appinstall 'Wireshark'             'wireshark'
    else
        appinstall 'tshark'                'tshark'
    fi

    appinstall 'Iperf'                  'iperf iperf3'

;;

### TI TMS320C64XX =============================================================

"dev/ti")

    appinstall 'TI Code Generation Tools'   'ti-cgt'

    if havegraphics
    then
        appinstall 'CCS project editor' 'ccs-pjt-editor-qt'
    fi

;;

### ============================================================================
### Version control system =====================================================
### ============================================================================

"vcs")

    appinstall 'VCS'                    'git subversion colordiff'

    if ispkginstalled nautilus
    then
        appinstall 'RabbitVCS'          'rabbitvcs-nautilus'
    fi

    if gnomebased
    then
        appinstall 'Meld diff tool'     'meld custom-config-meld'

        appinstall 'Git repo viewer'    'gitg'
    fi

;;

### ============================================================================
### Appearance =================================================================
### ============================================================================

"appearance")

    bash "${scriptpath}" 'appearance/themes'
    bash "${scriptpath}" 'appearance/fonts'
    bash "${scriptpath}" 'appearance/wallpaper'

;;

### Desktop theme ==============================================================

"appearance/themes")

    appinstall 'Adwaita theme'          'gnome-themes-extra'
    appinstall 'Numix theme'            'numix-icon-theme-circle'
    appinstall 'Breeze theme'           'breeze-cursor-theme breeze-icon-theme'
    appinstall 'Papirus theme'          'papirus-icon-theme papirus-material-icon-theme'

    appinstall 'Default cursor theme'   'custom-config-cursor-theme'

    if ispkgavailable plymouth-theme-spinner
    then
        appinstall 'Spinner plymouth theme' 'plymouth-theme-spinner'
    fi

    appinstall 'Gnome TTY colors' 'custom-config-vtrgb-gnome-theme'

;;

### System fonts ===============================================================

"appearance/fonts")

    appinstall 'MS TTF core fonts'      'fonts-microsoft-core fonts-microsoft fonts-cascadia-code'
    appinstall 'Noto fonts'             'fonts-noto-micro'
    appinstall 'Ubuntu fonts'           'fonts-ubuntu'
    appinstall 'Fira Code fonts'        'fonts-firacode'
    appinstall 'Hack fonts'             'fonts-hack'
    appinstall 'Google Sans fonts'      'fonts-google-sans'
    appinstall 'JetBrains Mono fonts'   'fonts-jetbrains-mono'

    appinstall 'Font configuration'     'font-config'

;;

### Wallpaper ==================================================================

"appearance/wallpaper")

    appinstall  'Backgrounds'           'backgrounds-custom backgrounds-night backgrounds-abstract backgrounds-blueprint backgrounds-windows'

;;

### ============================================================================
### Office applications ========================================================
### ============================================================================

"office")

    if gnomebased
    then
        appinstall 'LibreOffice'        'libreoffice-calc libreoffice-writer libreoffice-gtk3 libreoffice-gnome libreoffice-style-breeze libreoffice-l10n-ru'
        appinstall 'Document viewer'    'evince'
    fi

;;

### ============================================================================
### Multimedia applications ====================================================
### ============================================================================

### Local music/video  =========================================================

"media")

    if ispkgavailable 'ubuntu-restricted-extras'
    then
        appinstall 'Restricted extras'      'ubuntu-restricted-extras'
    fi

    appinstall 'VA API drivers'         'va-driver-all gstreamer1.0-vaapi'
    appinstall 'Multimedia codecs'      'gstreamer1.0-plugins-ugly gstreamer1.0-plugins-bad gstreamer1.0-libav libavcodec-extra'

    appinstall 'MPV Player'             'mpv custom-config-mpv'

    if gnomebased
    then
        appinstall 'Amberol'            'amberol'
        appinstall 'MPV Gnome GUI'      'celluloid'

        appinstall 'Eye of Gnome'       'eog'
    fi

    if ispkginstalled gnome-shell
    then
        gnomeshellextension 1379            # A simple MPRIS indicator button
        gnomeshellextension 906     'lt 43' # Sound Input & Output Device Chooser
        gnomeshellextension 517             # Caffeine
    fi

;;

### Online video ===============================================================

"media-online")

    appinstall 'Youtube downloader'     'yt-dlp yt-dlp-scripts phantomjs'
    appinstall 'MPV for youtube'        'yt-mpv'

    if gnomebased
    then
        appinstall 'MPV Gnome GUI for youtube'  'yt-celluloid'
    fi

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

    appinstall 'Google Chrome'          'google-chrome-stable'

    if ispkginstalled gnome-shell
    then
        appinstall 'Chrome Gnome Shell' 'chrome-gnome-shell'
    fi
;;

### Mail =======================================================================

"network/mail")

    if gnomebased
    then
        appinstall 'Geary mail client'      'geary'
    fi

;;

### Chat extra protocols =======================================================

"network/chat-extra")

    appinstall 'Telegram client'        'telegram-desktop'

;;

### Office =====================================================================

"network/office")

    #if gnomebased
    #then
    #    appinstall 'Gnome documents'    'gnome-documents'
    #fi

;;

### Online services ============================================================

"network/services")

    #if gnomebased
    #then
    #    appinstall 'Gnome Maps'             'gnome-maps'
    #    appinstall 'Gnome Weather'          'gnome-weather'
    #fi

;;

### Remote clients =============================================================

"network/remote")

    if gnomebased
    then
        appinstall 'Transmission remote'    'transmission-remote-gtk'
    fi

;;

### ============================================================================
### Graphic applications =======================================================
### ============================================================================

"graphics")

    appinstall 'GIMP'                   'gimp'
    appinstall 'Graphicsmagick'         'graphicsmagick-imagemagick-compat librsvg2-bin'
    appinstall 'Eye of Gnome'           'eog'

;;

### ============================================================================
### Compressing applications ===================================================
### ============================================================================

"archive")

    appinstall '7-zip'                  'p7zip-rar p7zip-full'

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

    appinstall 'Midnight Commander'     'mc'
    appinstall 'Directory tree'         'tree'

;;

### Command line monitor applications ==========================================

"cli/monitor")

    appinstall 'htop'                   'htop'
    appinstall 'btop'                   'btop'
    appinstall 'iotop'                  'iotop'
    appinstall 'tmux'                   'tmux'

;;

### Command line network applications ==========================================

"cli/net")

    appinstall 'curl'                   'curl'
    appinstall 'CLI web browsers'       'elinks w3m'
    appinstall 'Network tools'          'net-tools'

    appinstall 'Allow user ping'        'custom-config-sysctl-allow-user-ping'

;;

### ============================================================================
### Folders setup ==============================================================
### ============================================================================

"folders")

    appinstall 'User folders' 'user-folders'

    if havegraphics
    then
        appinstall 'Base templates' 'file-templates-base'
    fi

;;

### ============================================================================
### Virtual machine host tools =================================================
### ============================================================================

"vm-host")

    bash "${scriptpath}" 'vm-host/vbox'

;;

"vm-host/vbox")

    silent     'Accepting Oracle EULA' sh -c 'echo virtualbox-ext-pack virtualbox-ext-pack/license boolean true | debconf-set-selections'

    appinstall 'VirtualBox' 'virtualbox virtualbox-qt virtualbox-ext-pack virtualbox-guest-additions-iso'

;;

### ============================================================================
### Work =======================================================================
### ============================================================================

"work")

    ### Root CA Certificate ====================================================

    appinstall 'RCZI Root CA cert'      'ca-rczifort'

    ### Network switcher =======================================================

    appinstall 'Network Switcher'       'network-switch'

    ### LDAP user configuration script =========================================

    appinstall 'LDAP user config'       'user-ldap-config'

    ### Printers configuration script ==========================================

    appinstall 'Printers configuration' 'rczi-printer-configuration'

    ### Network configuration script ===========================================

    appinstall 'Network configuration'  'rczi-network-configuration'

    ### GOST hash ==============================================================

    appinstall 'GOST hashes'            'gostsum'

    ### Browser ================================================================

    if gnomebased
    then
        appinstall 'Epiphany web browser'   'epiphany-browser'
    fi

    ## Web services ============================================================

    appinstall 'RCZI web services'      'rczi-web-services'

;;

### Mail =======================================================================

"work-mail")

    if gnomebased
    then
        appinstall 'Evolution mail client'  'evolution evolution-data-server evolution-ews evolution-plugins'
    fi

;;

### Chat =======================================================================

"work-chat")

    appinstall 'Pidgin'             'pidgin [pidgin-indicator]'
;;

### Remote desktop =============================================================

"work-remote")

    if gnomebased
    then
        appinstall 'RDP server' 'vino'
        appinstall 'RDP client' 'gnome-connections'
    fi

;;

### ============================================================================
### ============================================================================
### ============================================================================

*)
    msgfail "[bundle '${bundle}' not found]"
;;

esac

