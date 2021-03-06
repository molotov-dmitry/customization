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
    fi

    appinstall 'Nautilus'                   'nautilus nautilus-extension-gnome-terminal nautilus-sendto nautilus-share'

    appinstall 'Base applications'          'gnome-calculator gnome-system-monitor gnome-characters'
    appinstall 'Tweak tool'                 'gnome-tweak-tool'

    appinstall 'Gnome appindicator support' 'gnome-shell-extension-appindicator'

    if ispkginstalled gnome-shell
    then
        gnomeshellextension 112             # Remove Accessibility
        gnomeshellextension 800             # Remove Dropdown Arrows
        gnomeshellextension 2072            # Skip Window Ready Notification

        if dpkg --compare-versions "$(pkgversion gnome-shell)" ge 3.36
        then
            gnomeshellextension 2917        # Bring Out Submenu Of Power Off/Logout Button
        fi
    fi

    fi

;;

### Cinnamon ===================================================================

"cinnamon")

    if gnomebased
    then

    appinstall 'Nautilus'               'nautilus nautilus-extension-gnome-terminal nautilus-sendto nautilus-share'
    appinstall 'Cinnamon'               'cinnamon cinnamon-session cinnamon-screensaver cinnamon-l10n'
    appinstall 'JSON editor'            'jq'
    appinstall 'Redshift'               'redshift-gtk'

    fi
;;

### KDE ========================================================================

"kde")

;;

### ============================================================================
### Qt =========================================================================
### ============================================================================

"qt")

    appinstall 'GTK2 style for Qt5'         'qt5-style-plugins'
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

    appinstall 'exFAT support'  'exfat-fuse exfat-utils'
    appinstall 'CIFS support'   'cifs-utils'

;;

### ============================================================================
### Server =====================================================================
### ============================================================================

"server")

    bash "${scriptpath}" 'server/ssh'
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

    appinstall 'Open SSH'               'openssh-server'

;;

### SMB server =================================================================

"server/smb")

    appinstall 'Samba'                  'cifs-utils samba winbind'

;;

### SVN server =================================================================

"server/svn")

    appinstall 'Subversion'             'subversion'
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

    appinstall 'MiniDLNA'               'minidlna'
    appinstall 'Plex Media Server'      'plexmediaserver'

;;

### Download server ============================================================

"server/download")

    appinstall 'Youtube downloader'     'youtube-dl ffmpeg phantomjs'
    silent 'Download youtube-dl'        wget https://yt-dl.org/downloads/latest/youtube-dl -O /usr/local/bin/youtube-dl
    silent 'Setup youtube-dl'           chmod a+rx /usr/local/bin/youtube-dl
    appinstall 'Transmission'           'transmission-daemon'

;;

### Proxy server ===============================================================

"server/proxy")

    ## Squid3 ------------------------------------------------------------------

    appinstall 'Squid3'                 'squid3'

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
    bash "${scriptpath}" 'dev/kmx32'

;;

### Build tools ================================================================

"dev/build")

    appinstall 'Build tools'            'build-essential unifdef'
    appinstall 'GCC'                    'gcc g++ gdb [gcc-8] [g++-8]'
    appinstall 'Multilib tools'         'gcc-multilib g++-multilib'
    appinstall 'Clang'                  'llvm clang'

    appinstall 'CMake'                  'cmake'
    appinstall 'Checkinstall'           'checkinstall'
    appinstall 'CRLF to LF'             'dos2unix'

;;

### Code analysis tools ========================================================

"dev/analysis")

    appinstall 'Static analysis tools'  'cppcheck'
    appinstall 'Dynamic analysis tools' 'valgrind'
    appinstall 'Function complexity'    'pmccabe'

;;

### Code formatting ============================================================

"dev/style")

    appinstall 'Code beautifier'        'astyle clang-format'

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

### X11 SDK ====================================================================

"dev/x11")

    appinstall 'X11 sdk'                'libx11-dev'

;;

### OpenGL SDK =================================================================

"dev/opengl")

    appinstall 'OpenGL sdk'             'freeglut3 freeglut3-dev libglew-dev libglu1-mesa libglu1-mesa-dev libgl1-mesa-glx libgl1-mesa-dev'

;;

### Qt SDK =====================================================================

"dev/qt")

    appinstall 'Qt SDK'                 'qtbase5-dev-tools qml qtbase5-dev qtdeclarative5-dev qt5-doc'
    appinstall 'Qt Libs'                'libqt5svg5 libqt5svg5-dev libqt5webkit5-dev libqt5charts5-dev libqt5xmlpatterns5-dev libqt5x11extras5-dev libqt5serialport5-dev libqt5sql5-sqlite'

    if havegraphics
    then
        appinstall 'Qt IDE'             'qtcreator'

        #TODO: Remove after qtcreator update
        if [[ "$(pkgversion qtcreator | cut -d '-' -f 1)" == '4.11.0' ]]
        then
            appinstall 'Clang headers' 'libclang-common-8-dev'
        fi

        appinstall 'Qt Creator MIME'    'qtcreator-mime'
    fi

;;

### Qt4 SDK ====================================================================

"dev/qt4")

    if ispkgavailable qt4-dev-tools
    then
        appinstall 'Qt4 SDK'            'qt4-dev-tools qt4-qmake'
        appinstall 'Qt4 Libs'           'libqt4-dev libqt4-dev-bin libqt4-network libqt4-sql libqtcore4 libqt4-qt3support'
    fi

;;

### KDE SDK ====================================================================

"dev/kde")

;;

### GTK SDK ====================================================================

"dev/gtk")

    appinstall 'GTK+ SDK'               'libgtk-3-dev libgtkmm-3.0-dev libtool libtool-bin'
    appinstall 'GTK+ Libs'              'libgtksourceview-3.0-dev libgtksourceview-3.0-1 libgtksourceviewmm-3.0-0v5 libgtksourceview-3.0-dev libpeas-1.0-0 libpeas-dev libgit2-glib-1.0-dev libgit2-glib-1.0-0'

    if havegraphics
    then
        appinstall 'GTK+ IDE'           'anjuta glade'
    fi

;;

### Gnome SDK ==================================================================

"dev/gnome")

    if havegraphics
    then
        appinstall 'GNOME IDE'          'gnome-builder'
    fi

;;

### Database ===================================================================

"dev/db")

    appinstall 'Postgres'               'postgresql-client libpq5 libpq-dev'
    appinstall 'SQLite'                 'sqlite3 libsqlite3-0 libsqlite3-dev'

    if havegraphics
    then
        appinstall 'SQLite gui'         'sqlitebrowser'
    fi
;;

### JSON libraries =============================================================

"dev/json")

    appinstall 'JSON libraries'         'libjsoncpp-dev'

;;

### Markdown editor ============================================================

"dev/markdown")

    if kdebased
    then
        appinstall 'Ghostwriter'        'ghostwriter'
    elif gnomebased
    then
        appinstall 'Marker'             'marker'
    fi

;;

### Network ====================================================================

"dev/net")

    appinstall 'ARPing'                 'iputils-arping'
    silent     'Wireshark fix'          sh -c 'echo "wireshark-common wireshark-common/install-setuid boolean true" | debconf-set-selections'

    if gnomebased
    then
        appinstall 'Wireshark'          'wireshark-gtk'
    elif kdebased
    then
        appinstall 'Wireshark'          'wireshark-qt'
    fi

;;

### TI TMS320C64XX =============================================================

"dev/ti")

    appinstall 'TI Code Generation Tools'   'ti-cgt'

    if havegraphics
    then
        appinstall 'CCS project editor' 'ccs-pjt-editor-qt'
    fi

;;

### KMX32 GCC ==================================================================

"dev/kmx32")

    appinstall 'KMX32 GCC'   'kmx32-gcc'

;;

### ============================================================================
### Version control system =====================================================
### ============================================================================

"vcs")

    appinstall 'VCS'                    'git subversion colordiff'
    appinstall 'Git flow'               'git-flow'

    if ispkginstalled nautilus
    then
        if ispkgavailable python3-nautilus
        then
            appinstall 'RabbitVCS'      'rabbitvcs-nautilus-python3'
        else
            appinstall 'RabbitVCS'      'rabbitvcs-nautilus'
        fi
    fi

    if havegraphics
    then
        appinstall 'Meld diff tool'     'meld'

        appinstall 'Git repo viewer'    'gitg'
    fi

    if kdebased
    then
        appinstall 'Kompare diff tool'  'kompare'
        appinstall 'KDE SVN'            'kdesvn'

        if ispkginstalled dolphin
        then
            appinstall 'Dolphin plugins'    'dolphin-plugins'
        fi
    fi

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

    appinstall 'Adwaita theme'          'gnome-themes-standard'
    appinstall 'Numix theme'            'numix-icon-theme-circle [numix-gtk-theme] [numix-blue-gtk-theme]'
    appinstall 'Breeze theme'           'breeze-cursor-theme breeze-icon-theme'
    appinstall 'Papirus theme'          'papirus-icon-theme papirus-material-icon-theme'

    if ispkginstalled cinnamon
    then
        appinstall 'Mint themes'            'mint-themes'
    fi

    if ispkgavailable pop-gtk-theme
    then
        appinstall 'Pop GTK Theme'      'pop-gtk-theme'
    fi

    if ispkgavailable yaru-theme-icon
    then
        appinstall 'Yaru theme'         'yaru-theme-icon [yaru-theme-gtk]'
    fi

    if ispkgavailable plymouth-theme-spinner
    then
        appinstall 'Spinner plymouth theme' 'plymouth-theme-spinner'
    fi

;;

### System fonts ===============================================================

"appearance/fonts")

    silent     'Accepting EULA license' sh -c 'echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections'
    appinstall 'MS TTF core fonts'      'ttf-mscorefonts-installer fonts-microsoft'

    if [[ "$(lsb_release -si)" == "Ubuntu" ]]
    then
        silent 'Change fonts repo'      sed -i 's#http://downloads.sourceforge.net/corefonts#https://github.com/pushcx/corefonts/raw/master#g' /usr/share/package-data-downloads/ttf-mscorefonts-installer
        silent 'Re-download fonts'      /usr/lib/update-notifier/package-data-downloader
    fi

    appinstall 'Noto fonts'             'fonts-noto-micro'

    if [[ "$(lsb_release -si)" == "Debian" ]]
    then
        appinstall 'Ubuntu fonts'       'ttf-ubuntu-font-family'
    fi

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

### User avatar ================================================================

"appearance/avatar")

    appinstall 'Imagemagick'            'imagemagick librsvg2-bin'

;;

### ============================================================================
### Office applications ========================================================
### ============================================================================

"office")

    if gnomebased
    then
        appinstall 'LibreOffice'        'libreoffice-calc libreoffice-writer libreoffice-draw libreoffice-gtk3 libreoffice-gnome libreoffice-style-breeze libreoffice-l10n-ru libreoffice-help-ru'
        appinstall 'Document viewer'    'evince'

    elif kdebased
    then
        appinstall 'LibreOffice'        'libreoffice-calc libreoffice-writer libreoffice-draw libreoffice-qt5 libreoffice-kde5 libreoffice-style-breeze libreoffice-l10n-ru libreoffice-help-ru'
        appinstall 'Document viewer'    'okular'
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

    appinstall 'MPV Player'             'mpv'

    if gnomebased
    then
        appinstall 'Rhythmbox'              'rhythmbox rhythmbox-plugins'
        appinstall 'Totem video player'     'totem'
        appinstall 'MPV Gnome GUI'          'gnome-mpv'

        appinstall 'DLNA support'           'dleyna-server [dleyna-renderer]'

        appinstall 'EasyTag'                'easytag'

        appinstall 'Gnome Photos'           'gnome-photos'
        appinstall 'Shotwell'               'shotwell'
    fi

    if kdebased
    then
        appinstall 'Clementine'             'clementine'
        appinstall 'Kaffeine media player'  'kaffeine'

        appinstall 'Kid3'                   'kid3'
    fi

    if ispkginstalled gnome-shell
    then
        gnomeshellextension 1379        # A simple MPRIS indicator button
        gnomeshellextension 906         # Sound Input & Output Device Chooser
        gnomeshellextension 517         # Caffeine
    fi

;;

### Online video ===============================================================

"media-online")

    appinstall 'Youtube downloader'     'youtube-dl ffmpeg phantomjs'
    silent     'Download youtube-dl'    wget https://yt-dl.org/downloads/latest/youtube-dl -O /usr/local/bin/youtube-dl
    silent     'Setup youtube-dl'       chmod a+rx /usr/local/bin/youtube-dl

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
    bash "${scriptpath}" 'network/remotedesktop'

;;

### Browser ====================================================================

"network/browser")

    appinstall 'Google Chrome'          'google-chrome-stable'

    if ispkginstalled gnome-shell
    then
        appinstall 'Chrome Gnome Shell' 'chrome-gnome-shell'
    fi

    if ispkginstalled plasma-desktop
    then
        appinstall 'Chrome Plasma'      'plasma-browser-integration'
    fi
;;

### Mail =======================================================================

"network/mail")

    if gnomebased
    then
        appinstall 'Geary mail client'      'geary'
    fi

    if kdebased
    then
        appinstall 'KDE PIM'                'kmail kontact korganizer ktnef kaddressbook kmailtransport-akonadi accountwizard'
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

    if kdebased
    then
        appinstall 'Transmission Qt'        'transmission-qt'
    fi

;;

### Remote desktop =============================================================

"network/remotedesktop")

    if gnomebased
    then
        appinstall 'RDP server' 'vino'
        appinstall 'RDP client' 'remmina remmina-plugin-vnc remmina-plugin-rdp remmina-plugin-xdmcp'
    fi

    if kdebased
    then
        appinstall 'RDP server' 'krfb'
        appinstall 'RDP client' 'krdc freerdp2-x11'
    fi

;;

### ============================================================================
### Graphic applications =======================================================
### ============================================================================

"graphics")

    appinstall 'GIMP'                   'gimp gimp-help-ru'
    appinstall 'Imagemagick'            'imagemagick librsvg2-bin'

    if gnomebased
    then
        appinstall 'Shotwell'           'shotwell'
    fi

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
    bash "${scriptpath}" 'cli/time'
    bash "${scriptpath}" 'cli/ttycolors'

;;

### Command line file manager applications =====================================

"cli/files")

    appinstall 'Midnight Commander'     'mc'
    appinstall 'Directory tree'         'tree'

;;

### Command line monitor applications ==========================================

"cli/monitor")

    appinstall 'htop'                   'htop'
    appinstall 'iotop'                  'iotop'
    appinstall 'Net bandwidth monitor'  'speedometer'
    appinstall 'tmux'                   'tmux'

;;

### Command line network applications ==========================================

"cli/net")

    silent 'Wireshark fix'              sh -c 'echo wireshark-common wireshark-common/install-setuid boolean true | debconf-set-selections'
    appinstall 'tshark'                 'tshark'
    appinstall 'curl'                   'curl'
    appinstall 'CLI web browsers'       'elinks w3m'
    appinstall 'UPnP client'            'miniupnpc'
    appinstall 'Network tools'          'net-tools'
    appinstall 'Iperf'                  'iperf iperf3'

;;

### Command line tools for time sync ===========================================

"cli/time")

    #appinstall 'NTP client'             'ntp'

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

    silent     'Accepting Oracle EULA' sh -c 'echo virtualbox-ext-pack virtualbox-ext-pack/license boolean true | debconf-set-selections'

    appinstall 'VirtualBox' 'virtualbox virtualbox-qt virtualbox-ext-pack virtualbox-guest-additions-iso'

;;

### ============================================================================
### Work =======================================================================
### ============================================================================

"work")

    ### Root CA Certificate ====================================================

    appinstall 'RCZI Root CA cert'      'ca-rczifort'

    ### Plymouth theme =========================================================

    appinstall 'RCZI plymouth theme'    plymouth-theme-rczi

    ### Network switcher =======================================================

    appinstall 'Network Switcher'       'network-switch'

    ### LDAP user configuration script =========================================

    appinstall 'LDAP user config'       'user-ldap-config'

    ### GOST hash ==============================================================

    appinstall 'GOST hashes'            'gostsum'

    ### Gnome shell extensions =================================================

    if ispkginstalled gnome-shell
    then
        gnomeshellextension 7           # Removable Drive Menu

        if dpkg --compare-versions "$(pkgversion gnome-shell)" ge 3.34
        then
            appinstall 'Redmine issues' 'gnome-shell-extension-redmine-issues'
        else
            gnomeshellextension 790     # Redmine Issues
        fi

    fi

    ### Browser ================================================================

    if gnomebased
    then
        appinstall 'Epiphany web browser'   'epiphany-browser'
    fi

    ## Web services ============================================================

    appinstall 'RCZI web services'      'rczi-web-services'

    ## MOXA UPort driver =======================================================

    appinstall 'MOXA UPort driver'      'mxu11x0-config mxu11x0-dkms'
;;

"work-mail")

    if gnomebased
    then
        appinstall 'Evolution mail client'  'evolution evolution-data-server evolution-ews evolution-plugins'
    fi

    if kdebased
    then
        appinstall 'KDE PIM'                'kmail kontact korganizer ktnef kaddressbook kmailtransport-akonadi accountwizard'
    fi


;;

### Chat =======================================================================

"work-chat")

    #if gnomebased
    #then
        #appinstall 'Empathy'            'empathy telepathy-haze telepathy-accounts-signon telepathy-gabble'
    #fi

    #if kdebased
    #then
        #appinstall 'Kopete'             'kopete'
    #fi

    appinstall 'Pidgin'             'pidgin [pidgin-libnotify] [pidgin-indicator]'
;;

### ============================================================================
### ============================================================================
### ============================================================================

*)
    msgfail "[bundle '${bundle}' not found]"
;;

esac

