#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")/.." && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

bundle="$1"

case "${bundle}" in

### Gnome ======================================================================

"gnome")

    appinstall 'Language pack'	            'hyphen-ru mythes-ru hunspell-ru language-pack-gnome-ru language-pack-gnome-ru-base language-pack-ru language-pack-ru-base'

;;

### Qt =========================================================================

"qt")

    appinstall 'GTK2 theme for Qt5'         'libqt5libqgtk2'

;;

### Development ================================================================

    "dev")
        scriptpath="${ROOT_PATH}/bundles/$(basename "$0")"

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
    ;;

### Build tools ================================================================

    "dev/build")
        appinstall 'Build tools'            'build-essential unifdef'
        appinstall 'Multilib tools'         'gcc-multilib g++-multilib'
        appinstall 'CMake'                  'cmake'
        appinstall 'Checkinstall'           'checkinstall'
        silentsudo 'Ptrace fix'             sed -i 's/[ \t]*kernel.yama.ptrace_scope[ \t]*=[ \t]*1/kernel.yama.ptrace_scope = 0/' /etc/sysctl.d/10-ptrace.conf
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
        appinstall 'Postgres'               'postgresql pgadmin3 libpq5 libpq-dev'
        appinstall 'SQLite'                 'sqlite sqliteman libsqlite3-0 libsqlite3-dev'
    ;;

### Version control system =====================================================

    "vcs")
        appinstall 'VCS'                    'git subversion'

        if ispkginstalled nautilus
        then
            appinstall 'RabbitVCS'          'rabbitvcs-core rabbitvcs-nautilus'
        fi
    ;;

### Desktop theme ==============================================================

    "themes")
        appinstall 'Numix theme'            'numix-icon-theme-circle numix-gtk-theme'
        appinstall 'Paper theme'            'paper-gtk-theme'
        appinstall 'Breeze theme'           'breeze-cursor-theme breeze-icon-theme'
        appinstall 'Oxygen cursors'         'oxygen-cursor-theme oxygen-cursor-theme-extra'
    ;;

### System fonts ===============================================================

    "fonts")
        silentsudo 'Accepting EULA license' sh -c 'echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections'
        appinstall 'MS TTF core fonts'      'ttf-mscorefonts-installer'
        appinstall 'Noto fonts'             'fonts-noto'
    ;;

### Office applications ========================================================

    "office")
        appinstall 'LibreOffice'            'libreoffice-calc libreoffice-writer libreoffice-pdfimport libreoffice-gtk3 libreoffice-style-breeze libreoffice-l10n-ru libreoffice-help-ru'
        appinstall 'Document viewer'        'evince'
    ;;

### Multimedia applications ====================================================

    "media")
        appinstall 'Restricted extras'      'ubuntu-restricted-extras'
        appinstall 'Rhythmbox'              'rhythmbox'
        appinstall 'Totem video player'     'totem'
        appinstall 'Kodi media center'      'kodi'
        gnomeshellextension 55              # Music player
    ;;

### Network and communication applications =====================================

    "network")
        appinstall 'Chromium browser'       'chromium chromium-l10n'
        appinstall 'Transmission remote'    'transmission-remote-gtk'
        appinstall 'Empathy'                'empathy'
        #TODO telepathy-morse
        #TODO eiskaltdcpp-remote
    ;;

### Graphic applications =======================================================

    "graphics")
        appinstall 'GIMP'                   'gimp gimp-help-ru'
        appinstall 'Imagemagick'            'imagemagick'
    ;;

### Compressing applications ===================================================

    "archive")
        appinstall '7-zip'                  'p7zip-rar p7zip-full'
    ;;

### Command line file manager applications =====================================

    "cli/files")
        appinstall 'Midnight Commander'     'mc'
        appinstall 'Directory tree'         'tree'
    ;;

### ============================================================================

    *)
        msgfail "[bundle '${bundle}' not found]"
    ;;

esac
