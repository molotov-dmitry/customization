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

    ## launcher ----------------------------------------------------------------

    launcheradd 'nautilus'
    launcheradd 'gnome-terminal'

    ## hide apps from application menu -----------------------------------------

    hideapp 'ipython'
    hideapp 'im-config'
    hideapp 'gparted'
    hideapp 'gnome-control-center'
    hideapp 'gnome-tweak-tool'
    hideapp 'gnome-session-properties'
    hideapp 'software-properties-drivers'
    hideapp 'software-properties-gnome'
    hideapp 'software-properties-gtk'

    ## File templates ----------------------------------------------------------

    xdg-user-dirs-update
    rsync -r "${ROOT_PATH}/files/template/" "$(xdg-user-dir TEMPLATES)/"

    ## Keyboard ----------------------------------------------------------------

    gsettings set org.gnome.desktop.wm.keybindings switch-input-source "['<Shift>Alt_L']"
    gsettings set org.gnome.desktop.wm.keybindings switch-input-source-backward "['<Primary><Shift>Alt_L']"

    ## File chooser ------------------------------------------------------------

    gsettings set org.gtk.Settings.FileChooser sort-directories-first     true

    ## gedit -------------------------------------------------------------------

    gsettings set org.gnome.gedit.preferences.editor use-default-font       true

    gsettings set org.gnome.gedit.preferences.editor display-line-numbers   true
    gsettings set org.gnome.gedit.preferences.editor highlight-current-line true
    gsettings set org.gnome.gedit.preferences.editor bracket-matching       true

    gsettings set org.gnome.gedit.preferences.editor insert-spaces          true
    gsettings set org.gnome.gedit.preferences.editor tabs-size              4

    gsettings set org.gnome.gedit.preferences.editor display-right-margin   true
    gsettings set org.gnome.gedit.preferences.editor right-margin-position  80

    gsettings set org.gnome.gedit.preferences.editor syntax-highlighting    true

    gsettings set org.gnome.gedit.preferences.editor scheme                 'kate'

    gsettings set org.gnome.gedit.preferences.editor wrap-mode              'none'

    gsettings set org.gnome.gedit.preferences.editor display-overview-map   true

    gsettings set org.gnome.gedit.plugins active-plugins "['changecase', 'filebrowser', 'time', 'zeitgeistplugin', 'docinfo']"

    ## gnome-terminal ----------------------------------------------------------

    term_profile=$(gsettings get org.gnome.Terminal.ProfilesList default | cut -d "'" -f 2)

    gsettings set org.gnome.Terminal.Legacy.Settings default-show-menubar false

    if [[ "$(desktoptype)" == 'GNOME' ]]
    then
        gsettings set org.gnome.Terminal.Legacy.Settings theme-variant 'dark'
    fi

    gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${term_profile}/" use-transparent-background true
    gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${term_profile}/" background-transparency-percent 5
    gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${term_profile}/" scrollbar-policy 'never'
    gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${term_profile}/" allow-bold false

    ## night light -------------------------------------------------------------

    if ispkginstalled 'redshift-gtk'
    then

        hideapp 'redshift-gtk'

    fi

    if [[ "$(desktoptype)" == 'GNOME' && $(gnome-shell --version | cut -d '.' -f 2) -ge 24 ]]
    then

        gsettings set org.gnome.settings-daemon.plugins.color active true
        gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
        gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-automatic true

    elif ispkginstalled 'redshift-gtk'
    then

        mkdir -p "${HOME}.config/autostart/"
        cp -rf "${ROOT_PATH}/files/redshift/redshift-gtk.desktop" "${HOME}/.config/autostart/"

    fi

    ## aliases -----------------------------------------------------------------

    echo alias highlight=\'grep --color=always -z\' >> ~/.bash_aliases

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

;;

### Download server ============================================================

"server/download")

    echo "alias ytpl='youtube-dl -o \"%(playlist_index)02d. %(title)s.%(ext)s\"'" >> ~/.bash_aliases

;;

### Proxy server ===============================================================

"server/proxy")

;;

### GitLab =====================================================================

"gitlab")

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

;;

### Code analysis tools ========================================================

"dev/analysis")

;;

### Code formatting ============================================================

"dev/style")

    ## Astyle ------------------------------------------------------------------

    rm -f "${HOME}/.astylerc"
    touch "${HOME}/.astylerc"

    echo '--style=allman'           >> "${HOME}/.astylerc"
    echo '--add-brackets'           >> "${HOME}/.astylerc"
    echo '--break-one-line-headers' >> "${HOME}/.astylerc"
    echo '--convert-tabs'           >> "${HOME}/.astylerc"
    echo '--indent=spaces=4'        >> "${HOME}/.astylerc"
    echo '--indent-namespaces'      >> "${HOME}/.astylerc"
    echo '--indent-preproc-define'  >> "${HOME}/.astylerc"
    echo '--indent-col1-comments'   >> "${HOME}/.astylerc"
    echo '--unpad-paren'            >> "${HOME}/.astylerc"
    echo '--pad-oper'               >> "${HOME}/.astylerc"
    echo '--pad-comma'              >> "${HOME}/.astylerc"
    echo '--pad-header'             >> "${HOME}/.astylerc"
    echo '--align-pointer=type'     >> "${HOME}/.astylerc"
    echo '--align-reference=type'   >> "${HOME}/.astylerc"
;;

### Documentation tools ========================================================

"dev/doc")

;;

### X11 SDK ====================================================================

"dev/x11")

;;

### OpenGL SDK =================================================================

"dev/opengl")

;;

### Qt SDK =====================================================================

"dev/qt")

    ## launcher ----------------------------------------------------------------

    launcheradd 'org.qt-project.qtcreator'

    hideapp 'assistant-qt5'
    hideapp 'designer-qt5'
    hideapp 'linguist-qt5'

    ## Qt Creator --------------------------------------------------------------

    rm -rf   "${HOME}/.config/QtProject"

    mkdir -p "${HOME}/.config/QtProject"

    cat << EOF > "${HOME}/.config/QtProject/QtCreator.ini"
[Core]
CreatorTheme=flat-light

[Directories]
BuildDirectory.Template=build/%{CurrentProject:Name}/%{CurrentBuild:Name}
Projects=${HOME}/Projects
UseProjectsDirectory=true

[Plugins]
ForceEnabled=Beautifier, ClangCodeModel, Todo
Ignored=Android, Bazaar, CMakeProjectManager, CVS, ClearCase, CodePaster, FakeVim, GLSLEditor, Git, Mercurial, Perforce, PythonEditor, QbsProjectManager, QmakeAndroidSupport, QmlDesigner, QmlJSEditor, QmlJSTools, QmlProfiler, QmlProjectManager, TaskList

[Beautifier]
artisticstyle\\useCustomStyle=false
artisticstyle\\useHomeFile=true
artisticstyle\\useOtherFiles=false

[TextEditor]
FontFamily=Ubuntu Mono
FontSize=12

[textDisplaySettings]
DisplayFileEncoding=true
CenterCursorOnScroll=true
HighlightCurrentLine2Key=true

[textMarginSettings]
MarginColumn=80
ShowMargin=true

[CppTools]
ClangDiagnosticConfig={f11d6a16-30e3-4e92-a9cb-e44b59cbbdf8}
ClangDiagnosticConfigs\\1\\diagnosticOptions=-Weverything, -Wno-c++98-compat, -Wno-c++98-compat-pedantic, -Wno-unused-macros, -Wno-newline-eof, -Wno-exit-time-destructors, -Wno-global-constructors, -Wno-gnu-zero-variadic-macro-arguments, -Wno-documentation, -Wno-shadow, -Wno-missing-prototypes, -Wno-unknown-pragmas, -Wno-old-style-cast, -Wno-cast-align
ClangDiagnosticConfigs\\1\\displayName=Custom
ClangDiagnosticConfigs\\1\\id={f11d6a16-30e3-4e92-a9cb-e44b59cbbdf8}
ClangDiagnosticConfigs\\size=1
EOF

    mkdir -p "${HOME}/.config/QtProject/qtcreator/styles"

    cp -f "${ROOT_PATH}/files/qtcreator/material.xml" "${HOME}/.config/QtProject/qtcreator/styles/"

;;

### KDE SDK ====================================================================

"dev/kde")

;;

### GTK SDK ====================================================================

"dev/gtk")

    ## launcher ----------------------------------------------------------------

    launcheradd 'anjuta'

;;

### Gnome SDK ==================================================================

"dev/gnome")

    ## launcher ----------------------------------------------------------------

    launcheradd 'org.gnome.Builder'

    ## gnome builder -----------------------------------------------------------

    gsettings set org.gnome.builder.editor show-map                         true
    gsettings set org.gnome.builder.editor font-name                        'Ubuntu Mono 12'

    for lang in awk c changelog cmake cpp cpphdr css csv desktop diff dosbatch dot gdb-log html ini java js json markdown pascal php sh sql vala xml yaml
    do
        gsettings set org.gnome.builder.editor.language:/org/gnome/builder/editor/language/${lang}/ indent-width            -1
        gsettings set org.gnome.builder.editor.language:/org/gnome/builder/editor/language/${lang}/ show-right-margin       true
        gsettings set org.gnome.builder.editor.language:/org/gnome/builder/editor/language/${lang}/ right-margin-position   80
        gsettings set org.gnome.builder.editor.language:/org/gnome/builder/editor/language/${lang}/ insert-spaces-instead-of-tabs true
        gsettings set org.gnome.builder.editor.language:/org/gnome/builder/editor/language/${lang}/ tab-width               4
        gsettings set org.gnome.builder.editor.language:/org/gnome/builder/editor/language/${lang}/ trim-trailing-whitespace true
        gsettings set org.gnome.builder.editor.language:/org/gnome/builder/editor/language/${lang}/ insert-matching-brace   true
        gsettings set org.gnome.builder.editor.language:/org/gnome/builder/editor/language/${lang}/ auto-indent             true
        gsettings set org.gnome.builder.editor.language:/org/gnome/builder/editor/language/${lang}/ overwrite-braces        true
    done

    for lang in makefile
    do
        gsettings set org.gnome.builder.editor.language:/org/gnome/builder/editor/language/${lang}/ indent-width            -1
        gsettings set org.gnome.builder.editor.language:/org/gnome/builder/editor/language/${lang}/ show-right-margin       true
        gsettings set org.gnome.builder.editor.language:/org/gnome/builder/editor/language/${lang}/ right-margin-position   80
        gsettings set org.gnome.builder.editor.language:/org/gnome/builder/editor/language/${lang}/ insert-spaces-instead-of-tabs false
        gsettings set org.gnome.builder.editor.language:/org/gnome/builder/editor/language/${lang}/ tab-width               4
        gsettings set org.gnome.builder.editor.language:/org/gnome/builder/editor/language/${lang}/ trim-trailing-whitespace true
        gsettings set org.gnome.builder.editor.language:/org/gnome/builder/editor/language/${lang}/ insert-matching-brace   true
        gsettings set org.gnome.builder.editor.language:/org/gnome/builder/editor/language/${lang}/ auto-indent             true
        gsettings set org.gnome.builder.editor.language:/org/gnome/builder/editor/language/${lang}/ overwrite-braces        true
    done

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

### Version control system =====================================================

"vcs")

    ## svn color side-by-side diff alias ---------------------------------------

    echo alias svndiff=\'svn --diff-cmd "colordiff" --extensions '"-y -W $(( $(tput cols) - 2 ))"' diff\' >> ~/.bash_aliases
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

    ## Icon theme --------------------------------------------------------------

    if [[ "$(desktoptype)" == 'Unity' ]]
    then
        icon_theme='Numix-Circle'

    elif [[ "$(desktoptype)" == 'GNOME' ]]
    then
        icon_theme='Paper'
    fi

    gsettings set org.gnome.desktop.interface icon-theme "${icon_theme}"

    ## Cursor theme ------------------------------------------------------------

    cursor_theme='breeze_cursors'

    gsettings set org.gnome.desktop.interface cursor-theme "${cursor_theme}"

    ## Gtk theme ---------------------------------------------------------------

    gtk_theme='NumixBlue'
    wm_theme='Numix'

    gsettings set org.gnome.desktop.interface gtk-theme         "${gtk_theme}"
    gsettings set org.gnome.desktop.wm.preferences theme        "${wm_theme}"
;;

### System fonts ===============================================================

"appearance/fonts")

    gsettings set org.gnome.desktop.interface font-name             'Ubuntu 10'
    gsettings set org.gnome.desktop.interface document-font-name    'Linux Libertine O 12'
    gsettings set org.gnome.desktop.interface monospace-font-name   'Ubuntu Mono 12'
    gsettings set org.gnome.desktop.wm.preferences titlebar-font    'Ubuntu 10'
;;

### ============================================================================
### Office applications ========================================================
### ============================================================================

"office")

    ## hide apps from application menu -----------------------------------------

    hideapp 'libreoffice-startcenter'

    ## Libreoffice  ------------------------------------------------------------

    mkdir -p "${HOME}/.config/libreoffice/4/user/config/soffice.cfg/modules/swriter/toolbar"
    cp -f "${ROOT_PATH}/files/libreoffice/writer/standardbar.xml" "${HOME}/.config/libreoffice/4/user/config/soffice.cfg/modules/swriter/toolbar/"
    cp -f "${ROOT_PATH}/files/libreoffice/writer/textobjectbar.xml" "${HOME}/.config/libreoffice/4/user/config/soffice.cfg/modules/swriter/toolbar/"

    mkdir -p "${HOME}/.config/libreoffice/4/user/config/soffice.cfg/modules/scalc/toolbar"
    cp -f "${ROOT_PATH}/files/libreoffice/calc/standardbar.xml" "${HOME}/.config/libreoffice/4/user/config/soffice.cfg/modules/scalc/toolbar/"
    cp -f "${ROOT_PATH}/files/libreoffice/calc/formatobjectbar.xml" "${HOME}/.config/libreoffice/4/user/config/soffice.cfg/modules/scalc/toolbar/"
;;

### ============================================================================
### Multimedia applications ====================================================
### ============================================================================

### Local music/video  =========================================================

"media")

    ## launcher ----------------------------------------------------------------

    launcheradd 'rhythmbox'
    launcheradd 'totem'

    ## hide apps from application menu -----------------------------------------

    hideapp 'easytag'
    hideapp 'mpv'

    ## Media player indicator Gnome Shell extension ----------------------------

    if [[ "$(desktoptype)" == 'GNOME' ]]
    then
        gsettingsadd org.gnome.shell enabled-extensions 'mediaplayer@patapon.info'
    fi

    ## rhythmbox ---------------------------------------------------------------

    mkdir -p "${HOME}/.local/share/rhythmbox"
    cp -f "${ROOT_PATH}/files/rhythmbox/rhythmdb.xml" "${HOME}/.local/share/rhythmbox/"

    gsettingsclear org.gnome.rhythmbox.plugins seen-plugins

    gsettingsadd org.gnome.rhythmbox.plugins seen-plugins 'soundcloud'
    gsettingsadd org.gnome.rhythmbox.plugins seen-plugins 'sendto'
    gsettingsadd org.gnome.rhythmbox.plugins seen-plugins 'replaygain'
    gsettingsadd org.gnome.rhythmbox.plugins seen-plugins 'rbzeitgeist'
    gsettingsadd org.gnome.rhythmbox.plugins seen-plugins 'rblirc'
    gsettingsadd org.gnome.rhythmbox.plugins seen-plugins 'rb'
    gsettingsadd org.gnome.rhythmbox.plugins seen-plugins 'pythonconsole'
    gsettingsadd org.gnome.rhythmbox.plugins seen-plugins 'notification'
    gsettingsadd org.gnome.rhythmbox.plugins seen-plugins 'mtpdevice'
    gsettingsadd org.gnome.rhythmbox.plugins seen-plugins 'mpris'
    gsettingsadd org.gnome.rhythmbox.plugins seen-plugins 'magnatune'
    gsettingsadd org.gnome.rhythmbox.plugins seen-plugins 'lyrics'
    gsettingsadd org.gnome.rhythmbox.plugins seen-plugins 'ipod'
    gsettingsadd org.gnome.rhythmbox.plugins seen-plugins 'im-status'
    gsettingsadd org.gnome.rhythmbox.plugins seen-plugins 'grilo'
    gsettingsadd org.gnome.rhythmbox.plugins seen-plugins 'fmradio'
    gsettingsadd org.gnome.rhythmbox.plugins seen-plugins 'dbus-media-server'
    gsettingsadd org.gnome.rhythmbox.plugins seen-plugins 'daap'
    gsettingsadd org.gnome.rhythmbox.plugins seen-plugins 'audioscrobbler'
    gsettingsadd org.gnome.rhythmbox.plugins seen-plugins 'artsearch'

    gsettingsclear org.gnome.rhythmbox.plugins active-plugins

    gsettingsadd org.gnome.rhythmbox.plugins active-plugins 'replaygain'
    gsettingsadd org.gnome.rhythmbox.plugins active-plugins 'rb'
    gsettingsadd org.gnome.rhythmbox.plugins active-plugins 'power-manager'
    gsettingsadd org.gnome.rhythmbox.plugins active-plugins 'notification'
    gsettingsadd org.gnome.rhythmbox.plugins active-plugins 'mpris'
    gsettingsadd org.gnome.rhythmbox.plugins active-plugins 'mmkeys'
    gsettingsadd org.gnome.rhythmbox.plugins active-plugins 'grilo'
    gsettingsadd org.gnome.rhythmbox.plugins active-plugins 'generic-player'

    gsettings set org.gnome.rhythmbox.plugins.iradio initial-stations-loaded true

    ## MPV ---------------------------------------------------------------------

    mkdir -p "${HOME}/.config/mpv"
    cp -f "${ROOT_PATH}/files/mpv/mpv.conf" "${HOME}/.config/mpv/"


    ## Sound Input & Output Device Chooser Gnome Shell extension ---------------

    if [[ "$(desktoptype)" == 'GNOME' ]]
    then
        gsettingsadd org.gnome.shell enabled-extensions 'sound-output-device-chooser@kgshank.net'
    fi

    dconf write /org/gnome/shell/extensions/sound-output-device-chooser/hide-on-single-device   true
    dconf write /org/gnome/shell/extensions/sound-output-device-chooser/show-input-devices      false
    dconf write /org/gnome/shell/extensions/sound-output-device-chooser/show-profiles           false
    dconf write /org/gnome/shell/extensions/sound-output-device-chooser/show-output-devices     true
    dconf write /org/gnome/shell/extensions/sound-output-device-chooser/hide-menu-icons         false
    dconf write /org/gnome/shell/extensions/sound-output-device-chooser/icon-theme              "'monochrome'"
    dconf write /org/gnome/shell/extensions/sound-output-device-chooser/show-input-slider       false

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
    bash "${scriptpath}" 'network/office'
    bash "${scriptpath}" 'network/services'
    bash "${scriptpath}" 'network/remote'
    
;;

### Browser ====================================================================

"network/browser")

    launcheradd 'chromium-browser'

;;

### Mail =======================================================================

"network/mail")

    

;;

### Chat =======================================================================

"network/chat")

    ## Empathy -----------------------------------------------------------------

    mkdir -p "${HOME}/.config/autostart"
    cp -f "${ROOT_PATH}/files/empathy/empathy.desktop" "${HOME}/.config/autostart/"

    gsettings set org.gnome.Empathy.conversation theme          'material'
    gsettings set org.gnome.Empathy.conversation theme-variant  'Green'
    gsettings set org.gnome.Empathy.conversation adium-path     '/usr/share/adium/message-styles/material.AdiumMessageStyle'

    gsettings set org.gnome.Empathy.ui show-groups              true

    gsettings set org.gnome.Empathy.conversation spell-checker-languages 'en,ru'

;;

### Office =====================================================================

"network/office")

;;

### Online services ============================================================

"network/services")

;;

### Remote clients =============================================================

"network/remote")

    ## Transmission Remote -----------------------------------------------------

    mkdir -p "${HOME}/.config/transmission-remote-gtk/"
    cp -rf "${ROOT_PATH}/files/transmission-remote-gtk/config.json" "${HOME}/.config/transmission-remote-gtk/"

    ## EiskaltDC++ Remote ------------------------------------------------------

    eiskaltdcpp-remote-qt-config --server-ip '188.134.72.31'

    eiskaltdcpp-remote-qt-config --clear-directory

    eiskaltdcpp-remote-qt-config --add-directory /media/documents/Video/Фильмы
    eiskaltdcpp-remote-qt-config --add-directory /media/documents/Video/Youtube
    eiskaltdcpp-remote-qt-config --add-directory /media/documents/Video/Аниме
    eiskaltdcpp-remote-qt-config --add-directory /media/documents/Video/Мультфильмы
    eiskaltdcpp-remote-qt-config --add-directory /media/documents/Books
    eiskaltdcpp-remote-qt-config --add-directory /media/documents/Documents
    eiskaltdcpp-remote-qt-config --add-directory /media/documents/Music
    eiskaltdcpp-remote-qt-config --add-directory /media/documents/Downloads
    eiskaltdcpp-remote-qt-config --add-directory /media/documents/Images
    eiskaltdcpp-remote-qt-config --add-directory /media/documents/Distrib
    eiskaltdcpp-remote-qt-config --add-directory /media/documents/Distrib/Драйверы
    eiskaltdcpp-remote-qt-config --add-directory /media/documents/Distrib/Игры
    eiskaltdcpp-remote-qt-config --add-directory /media/documents/Distrib/OS
    eiskaltdcpp-remote-qt-config --add-directory /media/documents/Distrib/Утилиты
    eiskaltdcpp-remote-qt-config --add-directory /media/documents/Distrib/Сеть
    eiskaltdcpp-remote-qt-config --add-directory /media/documents/Distrib/Медиа

    eiskaltdcpp-remote-qt-config --last-directory /media/documents/Downloads

    ## Bookmarks for SFTP ------------------------------------------------------

    mkdir -p "${HOME}/.config/gtk-3.0/"

    echo 'sftp://188.134.72.31:2222/media/documents SFTP' >> "${HOME}/.config/gtk-3.0/bookmarks"
    echo 'sftp://192.168.1.5/media/documents SFTP (LAN)' >> "${HOME}/.config/gtk-3.0/bookmarks"

;;

### ============================================================================
### Graphic applications =======================================================
### ============================================================================

"graphics")

    hideapp 'display-im6.q16'

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

    hideapp 'mc'
    hideapp 'mcedit'

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

    bash "${ROOT_PATH}/folders.sh"

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

    tracker daemon -t

    mkdir -p "${HOME}/.config/autostart"
    cd "${HOME}/.config/autostart"

    cp  /etc/xdg/autostart/tracker-* ./

    for FILE in tracker-*.desktop
    do
        echo 'Hidden=true' >> "$FILE"
    done

    rm -rf "${HOME}/.cache/tracker" "${HOME}/.local/share/tracker"

;;

### ============================================================================
### Virtual machine tools ======================================================
### ============================================================================

"vm")

;;

### ============================================================================
### ============================================================================
### ============================================================================

esac

