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

    ## Keyboard ----------------------------------------------------------------

    gsettings set org.gnome.desktop.wm.keybindings switch-input-source "['<Shift>Alt_L']"
    gsettings set org.gnome.desktop.wm.keybindings switch-input-source-backward "['<Primary><Shift>Alt_L']"

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

;;

### ============================================================================
### Development ================================================================
### ============================================================================

"dev")

    bash "${scriptpath}" 'dev/style'
    bash "${scriptpath}" 'dev/qt'
    bash "${scriptpath}" 'dev/gtk'
    bash "${scriptpath}" 'dev/gnome'
;;

### Code formatting ============================================================

"dev/style")

    ## Astyle ------------------------------------------------------------------

    rm -f "${HOME}/.astylerc"
    touch "${HOME}/.astylerc"

    echo '--style=allman'           >> "${HOME}/.astylerc"
    echo '--indent=spaces=4'        >> "${HOME}/.astylerc"
    echo '--indent-namespaces'      >> "${HOME}/.astylerc"
    echo '--indent-preproc-define'  >> "${HOME}/.astylerc"
    echo '--indent-col1-comments'   >> "${HOME}/.astylerc"
    echo '#--break-blocks'          >> "${HOME}/.astylerc"
    echo '--unpad-paren'            >> "${HOME}/.astylerc"
    echo '--pad-header'             >> "${HOME}/.astylerc"
    echo '--pad-oper'               >> "${HOME}/.astylerc"
    echo '#--delete-empty-lines'    >> "${HOME}/.astylerc"
    echo '--align-pointer=type'     >> "${HOME}/.astylerc"
    echo '--align-reference=type'   >> "${HOME}/.astylerc"
    echo '--convert-tabs'           >> "${HOME}/.astylerc"
    echo '--close-templates'        >> "${HOME}/.astylerc"
    echo '--max-code-length=80'     >> "${HOME}/.astylerc"
    echo '--break-after-logical'    >> "${HOME}/.astylerc"

;;

### Qt SDK =====================================================================

"dev/qt")

    ## launcher ----------------------------------------------------------------

    launcheradd 'qtcreator'

    ## Qt Creator --------------------------------------------------------------

    rm -rf   "${HOME}/.config/QtProject"

    mkdir -p "${HOME}/.config/QtProject"
    touch    "${HOME}/.config/QtProject/QtCreator.ini"

    echo '[Directories]'                    >> "${HOME}/.config/QtProject/QtCreator.ini"
    echo 'BuildDirectory.Template=build/%{CurrentProject:Name}/%{CurrentBuild:Name}'    >> "${HOME}/.config/QtProject/QtCreator.ini"
    echo "Projects=${HOME}/Projects"        >> "${HOME}/.config/QtProject/QtCreator.ini"
    echo 'UseProjectsDirectory=true'        >> "${HOME}/.config/QtProject/QtCreator.ini"
    echo ''                                 >> "${HOME}/.config/QtProject/QtCreator.ini"
    echo '[TextEditor]'                     >> "${HOME}/.config/QtProject/QtCreator.ini"
    echo 'FontFamily=Ubuntu Mono'           >> "${HOME}/.config/QtProject/QtCreator.ini"
    echo 'FontSize=12'                      >> "${HOME}/.config/QtProject/QtCreator.ini"
    echo ''                                 >> "${HOME}/.config/QtProject/QtCreator.ini"
    echo '[textDisplaySettings]'            >> "${HOME}/.config/QtProject/QtCreator.ini"
    echo 'DisplayFileEncoding=true'         >> "${HOME}/.config/QtProject/QtCreator.ini"
    echo 'CenterCursorOnScroll=true'        >> "${HOME}/.config/QtProject/QtCreator.ini"
    echo 'HighlightCurrentLine2Key=true'    >> "${HOME}/.config/QtProject/QtCreator.ini"
    echo ''                                 >> "${HOME}/.config/QtProject/QtCreator.ini"
    echo '[textMarginSettings]'             >> "${HOME}/.config/QtProject/QtCreator.ini"
    echo 'MarginColumn=80'                  >> "${HOME}/.config/QtProject/QtCreator.ini"
    echo 'ShowMargin=true'                  >> "${HOME}/.config/QtProject/QtCreator.ini"
    ;;

### GTK SDK ====================================================================

"dev/gtk")

    ## launcher ----------------------------------------------------------------

    #launcheradd 'anjuta'

;;

### Gnome SDK ==================================================================

"dev/gnome")

    ## launcher ----------------------------------------------------------------

    #launcheradd 'org.gnome.Builder'

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

### Version control system =====================================================

"vcs")

    ## svn color side-by-side diff alias ---------------------------------------

    echo alias svndiff=\'svn --diff-cmd "colordiff" --extensions '"-y -W $(( $(tput cols) - 2 ))"' diff\' >> ~/.bash_aliases
;;

### ============================================================================
### Appearance =================================================================
### ============================================================================

"appearance")

    shift

    bash "${scriptpath}" 'appearance/themes' "$@"
    bash "${scriptpath}" 'appearance/fonts'  "$@"

;;

### Themes =====================================================================

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

    if [[ "$(desktoptype)" == 'Unity' ]]
    then
        theme_name='Numix'

    elif [[ "$(desktoptype)" == 'GNOME' && $(gnome-shell --version | cut -d '.' -f 2) -lt 20 ]]
    then
        theme_name='Paper'

    else
        theme_name='Numix'
    fi

    if [[ -n "${theme_name}" && "$2" != "tablet" ]]
    then
        gsettings set org.gnome.desktop.interface gtk-theme         "${theme_name}"
        gsettings set org.gnome.desktop.wm.preferences theme        "${theme_name}"
    fi
;;

### Font =======================================================================

"appearance/fonts")

    gsettings set org.gnome.desktop.interface font-name             'Ubuntu 10'
    gsettings set org.gnome.desktop.interface document-font-name    'Linux Libertine O 12'
    gsettings set org.gnome.desktop.interface monospace-font-name   'Ubuntu Mono 12'
    gsettings set org.gnome.desktop.wm.preferences titlebar-font    'Ubuntu 10'
;;

### ============================================================================
### Office =====================================================================
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

"media")

    ## launcher ----------------------------------------------------------------

    #launcheradd 'kodi'
    launcheradd 'rhythmbox'
    launcheradd 'totem'

    ## hide apps from application menu -----------------------------------------

    hideapp 'easytag'
    hideapp 'mpv'

    ## Media player gnome shell extension --------------------------------------

    if [[ "$(desktoptype)" == 'GNOME' ]]
    then
        gsettingsadd org.gnome.shell enabled-extensions             'mediaplayer@patapon.info'
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
;;

### ============================================================================
### Network ====================================================================
### ============================================================================

### Network and communication ==================================================

"network")

    ## Launcher ----------------------------------------------------------------

    launcheradd 'chromium-browser'

    ## Empathy -----------------------------------------------------------------

    mkdir -p "${HOME}/.config/autostart"
    cp -f "${ROOT_PATH}/files/empathy/empathy.desktop" "${HOME}/.config/autostart/"

    gsettings set org.gnome.Empathy.conversation theme          'material'
    gsettings set org.gnome.Empathy.conversation theme-variant  'Green'
    gsettings set org.gnome.Empathy.conversation adium-path     '/usr/share/adium/message-styles/material.AdiumMessageStyle'

    gsettings set org.gnome.Empathy.ui show-groups              true

    gsettings set org.gnome.Empathy.conversation spell-checker-languages 'en,ru'

;;

### Network remote =============================================================

"network-remote")

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
### Command line ===============================================================
### ============================================================================

"cli")

    bash "${scriptpath}" 'cli/files'

;;

### Command line file manager applications =====================================

"cli/files")

    hideapp 'mc'
    hideapp 'mcedit'

;;

### ============================================================================
### ============================================================================
### ============================================================================

esac

