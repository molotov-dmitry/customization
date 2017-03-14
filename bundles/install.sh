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

    appinstall 'Language pack'	            'hyphen-ru mythes-ru hunspell-ru language-pack-gnome-ru language-pack-gnome-ru-base language-pack-ru language-pack-ru-base'

;;

### ============================================================================
### Qt =========================================================================
### ============================================================================

"qt")

    appinstall 'GTK2 theme for Qt5'         'libqt5libqgtk2'

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

    appinstall 'Samba'                  'cifs-utils samba'

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
    debinstall 'Plex Media Server'      'plexmediaserver' '1.3.4.3285-b46e0ea' 'amd64'

;;

### Download server ============================================================

"server/download")

    appinstall 'Youtube downloader'     'youtube-dl'
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
    bash "${scriptpath}" 'dev/x11'
    bash "${scriptpath}" 'dev/opengl'
    bash "${scriptpath}" 'dev/qt'
    bash "${scriptpath}" 'dev/gtk'
    bash "${scriptpath}" 'dev/gnome'
    bash "${scriptpath}" 'dev/db'
    bash "${scriptpath}" 'dev/json'
    bash "${scriptpath}" 'dev/net'

;;

### Build tools ================================================================

"dev/build")

    appinstall 'Build tools'            'build-essential unifdef'
    appinstall 'Multilib tools'         'gcc-multilib g++-multilib'
    appinstall 'CMake'                  'cmake'
    appinstall 'Checkinstall'           'checkinstall'

;;

### Code analysis tools ========================================================

"dev/analysis")

    appinstall 'Static analysis tools'  'cppcheck cppcheck-gui'
    appinstall 'Dynamic analysis tools' 'valgrind'

;;

### Code formatting ============================================================

"dev/style")

    appinstall 'Code beautifier'        'astyle'

;;

### Documentation tools ========================================================

"dev/doc")

    appinstall 'Doxygen'                'doxygen graphviz'

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
    appinstall 'Qt Libs'                'libqt5svg5 libqt5webkit5-dev'
    appinstall 'Qt IDE'                 'qtcreator'

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

    if [[ "$(lsb_release -si)" == "Ubuntu" ]] && ispkginstalled
    then
        appinstall 'Sqliteman'          'sqliteman'
    fi
;;

### JSON libraries =============================================================

"dev/json")

    appinstall 'JSON libraries'         'libjsoncpp-dev'

;;

### Network ====================================================================

"dev/net")

    silentsudo 'Wireshark fix'          sh -c 'echo wireshark-common wireshark-common/install-setuid boolean true | sudo debconf-set-selections'
    appinstall 'Wireshark'              'wireshark-gtk'

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

    appinstall 'Numix theme'            'numix-icon-theme-circle numix-gtk-theme'
    appinstall 'Paper theme'            'paper-gtk-theme paper-icon-theme'
    appinstall 'Breeze theme'           'breeze-cursor-theme breeze-icon-theme'
    appinstall 'Oxygen cursors'         'oxygen-cursor-theme oxygen-cursor-theme-extra'

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

    appinstall 'LibreOffice'            'libreoffice-calc libreoffice-writer libreoffice-pdfimport libreoffice-gtk2 libreoffice-gnome libreoffice-style-breeze libreoffice-l10n-ru libreoffice-help-ru'
    appinstall 'Document viewer'        'evince'

;;

### ============================================================================
### Multimedia =================================================================
### ============================================================================

### Local music/video  =========================================================

"media")

    appinstall 'Restricted extras'      'ubuntu-restricted-extras'
    appinstall 'VA API drivers'         'va-driver-all gstreamer1.0-vaapi'

    appinstall 'Rhythmbox'              'rhythmbox'
    appinstall 'Totem video player'     'totem'
    appinstall 'MPV Player'             'mpv gnome-mpv'

    appinstall 'EasyTag'                'easytag'

    gnomeshellextension 55              # Music player

;;

### Online video ===============================================================

"media-online")

    appinstall 'Youtube downloader'     'youtube-dl'
    appinstall 'Gnome Twitch app'       'gnome-twitch'

;;

### ============================================================================
### Network ====================================================================
### ============================================================================

### Network and communication applications =====================================

"network")

    appinstall 'Chromium browser'       'chromium-browser chromium-browser-l10n'
    appinstall 'Empathy'                'empathy telepathy-haze'
    appinstall 'Telegram protocol'      'telegram-purple'
    appinstall 'VK protocol'            'purple-vk-plugin'
    appinstall 'Gnome Maps'             'gnome-maps'
    appinstall 'Gnome Weather'          'gnome-weather'

;;

### Network remote =============================================================

"network-remote")

    appinstall 'Transmission remote'    'transmission-remote-gtk'
    debinstall 'EiskaltDC++ Remote Qt'  'eiskaltdcpp-remote-qt' '26' 'amd64'

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

;;

### Command line file manager applications =====================================

"cli/files")

    appinstall 'Midnight Commander'     'mc'
    appinstall 'Directory tree'         'tree'

;;

### Command line monitor applications ==========================================

"cli/monitor")

    appinstall 'htop'                   'htop'
    appinstall 'tmux'                   'tmux'

;;

### Command line network applications ==========================================

"cli/net")

    silentsudo 'Wireshark fix'          sh -c 'echo wireshark-common wireshark-common/install-setuid boolean true | sudo debconf-set-selections'
    appinstall 'tshark'                 'tshark'
    appinstall 'curl'                   'curl'
    appinstall 'CLI web browsers'       'elinks w3m'
    appinstall 'UPnP client'            'miniupnpc'

;;

### Command line tools for time sync ===========================================

"cli/time")

    appinstall 'NTP client'             'ntp'

;;

### ============================================================================
### Virtual machine tools ======================================================
### ============================================================================

"vm")

    appinstall 'VMWare tools'   'open-vm-tools'

    if ispkginstalled 'xorg'
    then
        appinstall 'VMWare Xorg drivers' 'xserver-xorg-video-vmware xauth xdg-utils'

        if ispkgavailable 'xserver-xorg-input-vmmouse'
        then
            appinstall 'VMWare mouse drivers' 'xserver-xorg-input-vmmouse'    
        fi
    fi

;;

### ============================================================================
### ============================================================================
### ============================================================================

*)
    msgfail "[bundle '${bundle}' not found]"
;;

esac

