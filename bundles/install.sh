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

    appinstall 'Gnome session'              'gnome-shell gnome-session'
    appinstall 'Language pack'	            'hyphen-ru mythes-ru hunspell-ru [language-pack-gnome-ru] [language-pack-gnome-ru-base] [language-pack-ru] [language-pack-ru-base]'
    appinstall 'Base applications'          'gnome-calculator gnome-system-monitor gnome-characters'
    appinstall 'Tweak tool'                 'gnome-tweak-tool'

    if ! ispkginstalled 'gnome-shell' || [[ $(gnome-shell --version | cut -d '.' -f 2) -lt 24 ]]
    then
        appinstall 'Redshift'               'redshift-gtk'
    fi

    gnomeshellextension 112                 # Remove Accessibility

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

;;

### Intel drivers ==============================================================

"driver/intel")

    appinstall 'Intel microcode'        'intel-microcode'

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

    appinstall 'Open SSH'               'openssh-server'

;;

### FTP server =================================================================

"server/ftp")

    appinstall 'FTP server'             'vsftpd'
    status=$?

    for i in $(seq 1 5)
    do

        if [[ ${status} -ne 0 ]]
        then
            silent '' killall vsftpd
            silent 'Trying to fix Vsftpd' apt install -f

            [[ $? -eq 0 ]] && break

        fi

    done

;;

### SMB server =================================================================

"server/smb")

    appinstall 'Samba'                  'cifs-utils samba winbind'

;;

### SVN server =================================================================

"server/svn")

    appinstall 'Subversion'             'subversion'

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

    appinstall 'Youtube downloader'     'youtube-dl'
    silentsudo 'Download youtube-dl'    wget https://yt-dl.org/downloads/latest/youtube-dl -O /usr/local/bin/youtube-dl
    silentsudo 'Setup youtube-dl'       chmod a+rx /usr/local/bin/youtube-dl
    appinstall 'Transmission'           'transmission-daemon'
    appinstall 'EiskaltDC++'            'eiskaltdcpp-daemon'

;;

### Proxy server ===============================================================

"server/proxy")

    ## Squid3 ------------------------------------------------------------------

    appinstall 'Squid3'                 'squid3'

;;

### GitLab =====================================================================

"gitlab")

    mkdir -p "${rootfs_dir}/tools/packages"

    pushd "${rootfs_dir}/tools/packages" > /dev/null

    silentsudo 'Download Gitlab package' apt-get download gitlab

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

    debinstall 'Gitlab stub'      'gitlab-stub' '' 'all'

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

    appinstall 'Build tools'            'build-essential unifdef'
    appinstall 'Multilib tools'         'gcc-multilib g++-multilib'
    appinstall 'LLVM clang'             'llvm lldb clang'
    appinstall 'CMake'                  'cmake'
    appinstall 'Checkinstall'           'checkinstall'

;;

### Code analysis tools ========================================================

"dev/analysis")

    appinstall 'Static analysis tools'  'cppcheck cppcheck-gui'
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

;;

### X11 SDK ====================================================================

"dev/x11")

    appinstall 'X11 sdk'                'libx11-dev'

;;

### OpenGL SDK =================================================================

"dev/opengl")

    appinstall 'OpenGL sdk'             'freeglut3 freeglut3-dev libglew1.10 libglew-dbg libglu1-mesa libglu1-mesa-dev libgl1-mesa-glx libgl1-mesa-dev'

;;

### Qt SDK =====================================================================

"dev/qt")

    appinstall 'Qt SDK'                 'qml qtbase5-dev qtdeclarative5-dev qt5-doc'
    appinstall 'Qt Libs'                'libqt5svg5 libqt5svg5-dev libqt5webkit5-dev'
    appinstall 'Qt IDE'                 'qtcreator'

;;

### Qt4 SDK ====================================================================

"dev/qt4")

    appinstall 'Qt4 SDK'                'qt4-dev-tools qt4-qmake'
    appinstall 'Qt4 Libs'               'libqt4-dev libqt4-dev-bin libqt4-network libqt4-sql libqtcore4 libqt4-qt3support'

;;

### KDE SDK ====================================================================

"dev/kde")

;;

### GTK SDK ====================================================================

"dev/gtk")

    appinstall 'GTK+ SDK'               'libgtk-3-dev libgtkmm-3.0-dev libtool libtool-bin'
    appinstall 'GTK+ Libs'              'libgtksourceview-3.0-dev libgtksourceview-3.0-1 libgtksourceviewmm-3.0-0v5 libgtksourceview-3.0-dev libpeas-1.0-0 libpeas-dev libgit2-glib-1.0-dev libgit2-glib-1.0-0'
    appinstall 'GTK+ IDE'               'anjuta glade'

;;

### Gnome SDK ==================================================================

"dev/gnome")

    appinstall 'GNOME IDE'              'gnome-builder'

;;

### Database ===================================================================

"dev/db")

    appinstall 'Postgres'               'postgresql-client libpq5 libpq-dev'
    appinstall 'SQLite'                 'sqlite libsqlite3-0 libsqlite3-dev'

    if [[ "$(lsb_release -si)" == "Ubuntu" ]] && ispkginstalled 'xorg'
    then
        appinstall 'Sqlite gui'         'sqlitebrowser'
    fi
;;

### JSON libraries =============================================================

"dev/json")

    appinstall 'JSON libraries'         'libjsoncpp-dev'

;;

### Network ====================================================================

"dev/net")

    silentsudo 'Wireshark fix'          sh -c 'echo "wireshark-common wireshark-common/install-setuid boolean true" | debconf-set-selections'
    appinstall 'Wireshark'              'wireshark-gtk'

;;

### TI TMS320C64XX =============================================================

"dev/ti")

;;

### ============================================================================
### Version control system =====================================================
### ============================================================================

"vcs")

    appinstall 'VCS'                    'git subversion colordiff'

    if ispkginstalled nautilus
    then
        appinstall 'RabbitVCS'          'rabbitvcs-core rabbitvcs-nautilus'
    fi

    if ispkginstalled 'xorg'
    then
        appinstall 'Meld diff tool'     'meld'
    fi

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

    appinstall 'Adwaita theme'          'gnome-themes-standard'
    appinstall 'Numix theme'            'numix-icon-theme-circle numix-gtk-theme numix-blue-gtk-theme'
    appinstall 'Paper theme'            'paper-icon-theme'
    appinstall 'Suru theme'             'suru-icon-set'
    appinstall 'Breeze theme'           'breeze-cursor-theme breeze-icon-theme'
    appinstall 'Canta theme'            'canta-themes canta-icons'

;;

### System fonts ===============================================================

"appearance/fonts")

    silentsudo 'Accepting EULA license' sh -c 'echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections'
    appinstall 'MS TTF core fonts'      'ttf-mscorefonts-installer'
    appinstall 'Noto fonts'             'fonts-noto'
    appinstall 'Linux Libertine fonst'  'fonts-linuxlibertine'

;;

### ============================================================================
### Office applications ========================================================
### ============================================================================

"office")

    appinstall 'LibreOffice'            'libreoffice-calc libreoffice-writer libreoffice-pdfimport libreoffice-gtk3 libreoffice-gnome libreoffice-style-breeze libreoffice-l10n-ru libreoffice-help-ru'
    #appinstall 'OnlyOffice'             'onlyoffice-desktopeditors'
    appinstall 'Document viewer'        'evince'

;;

### ============================================================================
### Multimedia applications ====================================================
### ============================================================================

### Local music/video  =========================================================

"media")

    appinstall 'Restricted extras'      'ubuntu-restricted-extras'
    appinstall 'VA API drivers'         'va-driver-all gstreamer1.0-vaapi'

    appinstall 'Rhythmbox'              'rhythmbox rhythmbox-plugins'
    appinstall 'Totem video player'     'totem'
    appinstall 'MPV Player'             'mpv gnome-mpv'

    appinstall 'DLNA support'           'dleyna-server dleyna-renderer'

    appinstall 'EasyTag'                'easytag'

    appinstall 'Gnome Photos'           'gnome-photos'
    appinstall 'Shotwell'               'shotwell'

    gnomeshellextension 55              # Media player indicator
    gnomeshellextension 906             # Sound Input & Output Device Chooser

;;

### Online video ===============================================================

"media-online")

    appinstall 'Youtube downloader'     'youtube-dl'
    silentsudo 'Download youtube-dl'    wget https://yt-dl.org/downloads/latest/youtube-dl -O /usr/local/bin/youtube-dl
    silentsudo 'Setup youtube-dl'       chmod a+rx /usr/local/bin/youtube-dl

    appinstall 'Gnome Twitch app'       'gnome-twitch gnome-twitch-player-backend-mpv-opengl'

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

    appinstall 'Chromium browser'       'chromium-browser chromium-browser-l10n'

;;

### Mail =======================================================================

"network/mail")

    appinstall 'Evolution mail client'  'evolution evolution-data-server evolution-ews'

;;

### Chat =======================================================================

"network/chat")

    #appinstall 'Empathy'                'empathy telepathy-haze telepathy-accounts-signon telepathy-gabble'

    appinstall 'Pidgin'                 'pidgin pidgin-libnotify [pidgin-indicator]'

;;

### Chat extra protocols =======================================================

"network/chat-extra")

    appinstall 'Telegram client'        'telegram-desktop'
    appinstall 'Telegram protocol'      'telegram-purple'
    appinstall 'VK protocol'            'purple-vk-plugin'

;;

### Office =====================================================================

"network/office")

    appinstall 'Gnome documents'        'gnome-documents'

;;

### Online services ============================================================

"network/services")

    appinstall 'Gnome Maps'             'gnome-maps'
    appinstall 'Gnome Weather'          'gnome-weather'

;;

### Remote clients =============================================================

"network/remote")

    appinstall 'Transmission remote'    'transmission-remote-gtk'
    debinstall 'EiskaltDC++ Remote Qt'  'eiskaltdcpp-remote-qt' '27' 'amd64'

;;

### ============================================================================
### Graphic applications =======================================================
### ============================================================================

"graphics")

    appinstall 'GIMP'                   'gimp gimp-help-ru'
    appinstall 'Imagemagick'            'imagemagick'

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

    silentsudo 'Wireshark fix'          sh -c 'echo wireshark-common wireshark-common/install-setuid boolean true | sudo debconf-set-selections'
    appinstall 'tshark'                 'tshark'
    appinstall 'curl'                   'curl'
    appinstall 'CLI web browsers'       'elinks w3m'
    appinstall 'UPnP client'            'miniupnpc'
    appinstall 'Network tools'          'net-tools'
    appinstall 'Iperf'                  'iperf iperf3'

;;

### Command line tools for time sync ===========================================

"cli/time")

    appinstall 'NTP client'             'ntp'

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

    appinstall 'VMWare tools'   'open-vm-tools'

    if ispkginstalled 'xorg'
    then
        appinstall 'VMWare Xorg drivers' 'xserver-xorg-video-vmware [xserver-xorg-input-vmmouse] xauth xdg-utils'
    fi

;;

"vm-guest/vbox")

    appinstall 'VirtualBox tools' 'virtualbox-guest-utils'

    if ispkginstalled 'xorg'
    then
        appinstall 'VirtualBox X11 tools' 'virtualbox-guest-x11'
    fi

;;

### ============================================================================
### Virtual machine host tools =================================================
### ============================================================================

"vm-host")

    bash "${scriptpath}" 'vm-host/vbox'

;;

"vm-host/vbox")

    silentsudo 'Accepting Oracle EULA' sh -c 'echo virtualbox-ext-pack virtualbox-ext-pack/license boolean true | sudo debconf-set-selections'

    appinstall 'VirtualBox' 'virtualbox virtualbox-qt virtualbox-ext-pack virtualbox-guest-additions-iso'

;;

### ============================================================================
### ============================================================================
### ============================================================================

*)
    msgfail "[bundle '${bundle}' not found]"
;;

esac

