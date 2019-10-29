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

    ## Aliases =================================================================

    echo alias highlight=\'grep --color=always -z\' >> ~/.bash_aliases

    echo -e "\nfunction ddusb()\n{\n    sudo dd if=\"\$1\" of=\"\$2\" bs=2M status=progress oflag=sync\n}\n\n" >> ~/.bash_aliases

;;

### Base GUI ===================================================================

"gui")

    ## File templates ==========================================================

    xdg-user-dirs-update
    rsync -r "${ROOT_PATH}/files/template/" "$(xdg-user-dir TEMPLATES)/"

;;

### GTK-based GUI ==============================================================

"gtk")

    if gnomebased
    then

    ## launcher ================================================================

    if ispkginstalled nautilus
    then
        launcheradd 'org.gnome.Nautilus'
    fi

    if ispkginstalled gnome-terminal
    then
        launcheradd 'org.gnome.Terminal'
    fi

    ## hide apps from application menu =========================================

    hideapp 'ipython'
    hideapp 'im-config'
    hideapp 'gparted'
    hideapp 'gnome-control-center'
    hideapp 'gnome-session-properties'
    hideapp 'gnome-language-selector'
    hideapp 'software-properties-drivers'
    hideapp 'software-properties-gnome'
    hideapp 'software-properties-gtk'
    hideapp 'software-properties-livepatch'
    hideapp 'org.gnome.PowerStats'
    hideapp 'redshift-gtk'

    ## Hide Nemo if Nautilus installed -----------------------------------------

    if ispkginstalled nemo && ispkginstalled nautilus
    then
        hideapp 'nemo'
    fi

    ## Keyboard ================================================================

    gsettings set org.gnome.desktop.wm.keybindings switch-input-source "['<Shift>Alt_L', '<Alt>Shift_L', '<Super>space']"
    gsettings set org.gnome.desktop.wm.keybindings switch-input-source-backward "['<Primary><Shift>Alt_L', '<Primary><Alt>Shift_L', '<Shift><Super>space', '<Primary><Super>space']"

    gsettings set org.gnome.desktop.wm.keybindings show-desktop "['<Super>d']"

    addkeybinding 'System Monitor' 'gnome-system-monitor' '<Ctrl><Shift>Escape'
    addkeybinding 'File Manager'   'nautilus -w'          '<Super>E'

    ## File manager keybindings ================================================

    addscenario 'terminal' 'F4' 'x-terminal-emulator' --fixpwd
    addscenario 'compress' 'F7' '[[ $# -gt 0 ]] && file-roller -d $@'

    ## File chooser ============================================================

    gsettings set org.gtk.Settings.FileChooser sort-directories-first       true

    ## Text editors ============================================================

    editors=()

    ispkginstalled gedit && editors+=( 'gnome.gedit' )
    ispkginstalled xed   && editors+=( 'x.editor' )

    for editor in "${editors[@]}"
    do
        gsettings set org.${editor}.preferences.editor use-default-font       true

        gsettings set org.${editor}.preferences.editor display-line-numbers   true
        gsettings set org.${editor}.preferences.editor highlight-current-line true
        gsettings set org.${editor}.preferences.editor bracket-matching       true

        gsettings set org.${editor}.preferences.editor insert-spaces          false
        gsettings set org.${editor}.preferences.editor tabs-size              4

        gsettings set org.${editor}.preferences.editor display-right-margin   true
        gsettings set org.${editor}.preferences.editor right-margin-position  80

        gsettings set org.${editor}.preferences.editor syntax-highlighting    true

        gsettings set org.${editor}.preferences.editor scheme                 'kate'

        gsettings set org.${editor}.preferences.editor wrap-mode              'none'

        if [[ "$editor" == 'gnome.gedit' ]]
        then
            gsettings set org.${editor}.preferences.editor display-overview-map   true

        elif [[ "$editor" == 'x.editor' ]]
        then
            gsettings set org.x.editor.preferences.ui minimap-visible true
        fi

        gsettings set org.${editor}.plugins active-plugins "['changecase', 'filebrowser', 'time', 'zeitgeistplugin', 'docinfo']"
    done

    unset editors

    ## gnome-terminal ----------------------------------------------------------

    if ispkginstalled gnome-terminal
    then
        term_profile=$(gsettings get org.gnome.Terminal.ProfilesList default | cut -d "'" -f 2)

        gsettings set org.gnome.Terminal.Legacy.Settings default-show-menubar false
        gsettings set org.gnome.Terminal.Legacy.Settings theme-variant 'dark'

        gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${term_profile}/" use-transparent-background true
        gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${term_profile}/" background-transparency-percent 5
        gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${term_profile}/" scrollbar-policy 'never'
        gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${term_profile}/" allow-bold false
    fi

    ## Setup night light -------------------------------------------------------

    if ispkginstalled redshift-gtk
    then

        mkdir -p "${HOME}/.config/autostart/"
        cp -rf "${ROOT_PATH}/files/redshift/redshift-gtk.desktop" "${HOME}/.config/autostart/"

    fi

    ## =========================================================================

    fi

;;

### ============================================================================
### DM =========================================================================
### ============================================================================

### Gnome ======================================================================

"gnome")

    if gnomebased
    then

    ## Gnome desktop ===========================================================

    if ispkginstalled gnome-shell
    then
        ## Hide desktop icons --------------------------------------------------
        gsettings set org.gnome.desktop.background show-desktop-icons false
    fi

    ## Gnome shell =============================================================

    if ispkginstalled gnome-shell
    then
        ## Enable hot corners --------------------------------------------------
        gsettings set org.gnome.shell enable-hot-corners true

        ## Disable modal dialogs attach ----------------------------------------
        gsettings set org.gnome.shell.overrides attach-modal-dialogs false
    fi

    ## night light =============================================================

    if ispkginstalled gnome-shell
    then
        gsettings set org.gnome.settings-daemon.plugins.color active                         true
        gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled            true
        gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-automatic true
    fi

    ## Gnome shell extensions ==================================================

    if ispkginstalled gnome-shell
    then
        ## enable app indicators -----------------------------------------------
        gsettingsadd org.gnome.shell enabled-extensions 'ubuntu-appindicators@ubuntu.com'

        ## remove accessibility icon -------------------------------------------
        gsettingsadd org.gnome.shell enabled-extensions 'removeaccesibility@lomegor'

    fi

    ## =========================================================================

    fi

;;

### Cinnamon ===================================================================

"cinnamon")

    if gnomebased
    then

    ## Keyboard layout ---------------------------------------------------------

    gsettingsclear org.gnome.libgnomekbd.keyboard options

    gsettingsadd org.gnome.libgnomekbd.keyboard options 'terminate\tterminate:ctrl_alt_bksp'
    gsettingsadd org.gnome.libgnomekbd.keyboard options 'grp\tgrp:alt_shift_toggle'
    gsettingsadd org.gnome.libgnomekbd.keyboard options 'grp\tgrp:win_space_toggle'
    gsettingsadd org.gnome.libgnomekbd.keyboard options 'grp_led\tgrp_led:scroll'

    ## Set custom start menu icon ----------------------------------------------

    cfgfile="${HOME}/.cinnamon/configs/menu@cinnamon.org/1.json"

    mkdir -p "$(dirname "${cfgfile}")"
    [[ ! -f "${cfgfile}" ]] && echo '{}' > "${cfgfile}"

    tmpf=$(mktemp --tmpdir=$(dirname "${cfgfile}") -t)
    jq '."menu-custom"."value" = true' "${cfgfile}" > "${tmpf}"
    mv -f "${tmpf}" "${cfgfile}"

    unset tmpf
    unset cfgfile

    ## Clear launcher ----------------------------------------------------------

    cfgfile="${HOME}/.cinnamon/configs/panel-launchers@cinnamon.org/3.json"

    mkdir -p "$(dirname "${cfgfile}")"
    [[ ! -f "${cfgfile}" ]] && echo '{}' > "${cfgfile}"

    tmpf=$(mktemp --tmpdir=$(dirname "${cfgfile}") -t)
    jq '."launcherList"."value" = []' "${cfgfile}" > "${tmpf}"
    mv -f "${tmpf}" "${cfgfile}"

    unset tmpf
    unset cfgfile

    ## Clear grouped window list pinned applications ---------------------------

    cfgfile="${HOME}/.cinnamon/configs/grouped-window-list@cinnamon.org/3.json"

    mkdir -p "$(dirname "${cfgfile}")"
    [[ ! -f "${cfgfile}" ]] && echo '{}' > "${cfgfile}"

    tmpf=$(mktemp --tmpdir=$(dirname "${cfgfile}") -t)
    jq '."pinned-apps"."value" = []' "${cfgfile}" > "${tmpf}"
    mv -f "${tmpf}" "${cfgfile}"

    unset tmpf
    unset cfgfile

    ## Hide desktop icons ------------------------------------------------------

    gsettings set org.nemo.desktop desktop-layout 'false::false'

    ## Disable Nemo plugins ----------------------------------------------------

    gsettingsadd org.nemo.plugins disabled-actions    'add-desklets.nemo_action'
    gsettingsadd org.nemo.plugins disabled-extensions 'ChangeColorFolder+NemoPython'

    ## Set Nautilus as default file manager ------------------------------------

    if ispkginstalled nemo && ispkginstalled nautilus
    then
        mimeregister    'inode/directory' 'org.gnome.Nautilus.desktop'
        setdefaultapp   'inode/directory' 'org.gnome.Nautilus.desktop'
    fi

    ## Use text instead of layout flags ----------------------------------------

    gsettings set org.cinnamon.desktop.interface keyboard-layout-show-flags false
    gsettings set org.cinnamon.desktop.interface keyboard-layout-use-upper  true

    ## Setup hot corners -------------------------------------------------------

    gsettings set org.cinnamon hotcorner-layout  "['scale:true:0', 'scale:false:0', 'scale:false:0', 'desktop:true:700']"

    ## =========================================================================

    fi

;;

### KDE ========================================================================

"kde")

    ## KDE ---------------------------------------------------------------------

    if kdebased
    then
        usercopy 'kde'
    fi

    ## Konsole -----------------------------------------------------------------

    if ispkginstalled konsole
    then
        usercopy 'konsole'
    fi

    ## Kate --------------------------------------------------------------------

    if ispkginstalled kate
    then
        usercopy 'kate'
    fi

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

;;

### Code analysis tools ========================================================

"dev/analysis")

;;

### Code formatting ============================================================

"dev/style")

    ## UTF-8 BOM ---------------------------------------------------------------

    if ! test -f "${HOME}/.bash_aliases" || ! grep -F 'utf8bom()' "${HOME}/.bash_aliases"
    then
        cat >> "${HOME}/.bash_aliases" << '_EOF'
function utf8bom()
{
for file in "$@"
do
    if test -s "${file}"
    then
        if [[ $(cut -z -b1-3 "${file}" | hexdump -v -e '/1 "%02X"') == 'EFBBBF00' ]]
        then
            echo "Unchanged ${file}"
        else
            sed -i '1s/^/\xef\xbb\xbf/' "${file}" || return $?
            echo "Added UTF-8 BOM to ${file}"
        fi
    elif test -w $file
    then
        echo -en "\xef\xbb\xbf" > "${file}" || return $?
        echo "Added UTF-8 BOM to ${file}"
    else
        file "${file}" || return $?
        return 1
    fi
done
}

_EOF

    fi

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

    if ispkginstalled 'qtcreator'
    then

        ## launcher ------------------------------------------------------------

        launcheradd 'org.qt-project.qtcreator'

        changeapp 'org.qt-project.qtcreator' 'StartupWMClass' 'qtcreator'

        hideapp 'assistant-qt5'
        hideapp 'designer-qt5'
        hideapp 'linguist-qt5'

        ## Mime type -----------------------------------------------------------

        mimeregister 'application/vnd.nokia.qt.qmakeprofile' 'org.qt-project.qtcreator.desktop'

        ## Qt Creator ----------------------------------------------------------

        rm -rf   "${HOME}/.config/QtProject"

        mkdir -p "${HOME}/.config/QtProject"
        sed "s/{HOME}/$(safestring "${HOME}")/g" "${ROOT_PATH}/files/qtcreator/QtCreator.ini" > "${HOME}/.config/QtProject/QtCreator.ini"

        mkdir -p "${HOME}/.config/QtProject/qtcreator/styles"
        cp -f "${ROOT_PATH}/files/qtcreator/material.xml" "${HOME}/.config/QtProject/qtcreator/styles/"
        cp -f "${ROOT_PATH}/files/qtcreator/material_dark.xml" "${HOME}/.config/QtProject/qtcreator/styles/"

        mkdir -p "${HOME}/.config/QtProject/qtcreator/snippets"
        cp -f "${ROOT_PATH}/files/qtcreator/snippets.xml" "${HOME}/.config/QtProject/qtcreator/snippets/"

        mkdir -p "${HOME}/.config/QtProject/qtcreator/codestyles/Cpp"
        cp -f "${ROOT_PATH}/files/qtcreator/allman.xml" "${HOME}/.config/QtProject/qtcreator/codestyles/Cpp"
    fi

;;

### Qt4 SDK ====================================================================

"dev/qt4")

    if ispkginstalled 'qtcreator'
    then
        hideapp 'assistant-qt4'
        hideapp 'designer-qt4'
        hideapp 'linguist-qt4'
    fi

;;

### KDE SDK ====================================================================

"dev/kde")

;;

### GTK SDK ====================================================================

"dev/gtk")

    ## launcher ----------------------------------------------------------------

    if ispkginstalled 'anjuta'
    then
        launcheradd 'anjuta'
    fi

;;

### Gnome SDK ==================================================================

"dev/gnome")

    if ispkginstalled 'gnome-builder'
    then

        ## launcher ------------------------------------------------------------

        launcheradd 'org.gnome.Builder'

        ## Register mimetypes --------------------------------------------------

        mimeregister 'text/x-makefile'           'org.gnome.Builder.desktop'
        mimeregister 'application/x-shellscript' 'org.gnome.Builder.desktop'

        ## gnome builder -------------------------------------------------------

        gsettings set org.gnome.builder        follow-night-light               true
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
    fi

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

;;

### Version control system =====================================================

"vcs")

    ## SVN color side-by-side diff alias ---------------------------------------

    echo alias svndiff=\'svn --diff-cmd "colordiff" diff\' >> ~/.bash_aliases

    ## SVN working copy clean function -----------------------------------------

    if [[ -z "$(grep 'svnclean()' ~/.bash_aliases)" ]]
    then
        echo -e "\nfunction svnclean()\n{\n    svn st \"\$@\" --no-ignore | grep '^?\\|^I' | sed 's/^.[ ]*//' | tr '\\\\n' '\\\\0' | xargs -0 rm -rf\n}\n\n" >> ~/.bash_aliases
    fi

    ## Git revision number -----------------------------------------------------

    if [[ -z "$(grep 'gitversion()' ~/.bash_aliases)" ]]
    then
        echo -e "\nfunction gitversion()\n{\n    git log --pretty=format:'%h' \"\$@\" | wc -l\n}\n\n" >> ~/.bash_aliases
    fi

    if [[ -z "$(grep 'githash()' ~/.bash_aliases)" ]]
    then
        echo -e "\nfunction githash()\n{\n    git rev-parse --short HEAD \"\$@\"\n}\n\n" >> ~/.bash_aliases
    fi

    ## Make git save credentials by default ------------------------------------

    git config --global credential.helper store

    ## Meld --------------------------------------------------------------------

    if ispkginstalled 'meld'
    then
        gsettings set org.gnome.meld highlight-syntax   true
        gsettings set org.gnome.meld style-scheme       'kate'
        gsettings set org.gnome.meld show-line-numbers  true
        gsettings set org.gnome.meld indent-width       4
    fi

    if ispkginstalled 'meld' && ispkginstalled 'nautilus'
    then
        addscenario 'compare' 'F3' '[[ $# -eq 0 ]] && ( svn info || git status ) && meld .\n[[ $# -eq 1 ]] && ( svn info "$1" || ( cd "$1" && git status ) ) && meld "$1"\n[[ $# -gt 1 ]] && meld "$@"'
    fi

    if ispkginstalled 'gitg' && ispkginstalled 'nautilus'
    then
        addscenario 'gitg' '<Ctrl>F3' '[[ $# -eq 0 ]] && ( git status ) && gitg .\n[[ $# -eq 1 ]] && ( cd "$1" && git status ) && gitg "$1"'
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

    icon_theme='Papirus'
    cursor_theme='breeze_cursors'
    gtk_theme='Adwaita'
    wm_theme='Adwaita'


    if ispkginstalled gnome-shell
    then
        gsettings set org.gnome.desktop.interface icon-theme    "${icon_theme}"
        gsettings set org.gnome.desktop.interface cursor-theme  "${cursor_theme}"
        gsettings set org.gnome.desktop.interface gtk-theme     "${gtk_theme}"
        gsettings set org.gnome.desktop.wm.preferences theme    "${wm_theme}"
    fi

    if ispkginstalled cinnamon
    then
        gsettings set org.cinnamon.desktop.interface icon-theme     "${icon_theme}"
        gsettings set org.cinnamon.desktop.interface cursor-theme   "${cursor_theme}"

        gsettings set org.cinnamon.desktop.interface gtk-theme      'Mint-Y-Darker'
        gsettings set org.cinnamon.desktop.wm.preferences theme     'Mint-Y-Dark'
        gsettings set org.cinnamon.theme name                       'Mint-Y-Dark'
    fi

    if kdebased
    then
        for file in "${HOME}/.config/kdeglobals" "${HOME}/.kde/share/config/kdeglobals"
        do
            addconfigline 'Theme' "${icon_theme}" 'Icons' "$file"
        done
    fi
;;

### System fonts ===============================================================

"appearance/fonts")

    font_ui='Google Sans'
    font_doc='Linux Libertine O'
    font_fixed='Ubuntu Mono'

    font_ui_size='10'
    font_doc_size='12'
    font_fixed_size='12'

    if ispkginstalled gnome-shell
    then
        gsettings set org.gnome.desktop.interface font-name             "${font_ui} {font_ui_size}"
        gsettings set org.gnome.desktop.interface document-font-name    "${font_doc} {font_doc_size}"
        gsettings set org.gnome.desktop.interface monospace-font-name   "${font_fixed} {font_fixed_size}"
        gsettings set org.gnome.desktop.wm.preferences titlebar-font    "${font_ui} {font_ui_size}"
    fi

    if ispkginstalled cinnamon
    then
        gsettings set org.cinnamon.desktop.interface font-name          "${font_ui} {font_ui_size}"
        gsettings set org.gnome.desktop.interface document-font-name    "${font_doc} {font_doc_size}"
        gsettings set org.gnome.desktop.interface monospace-font-name   "${font_fixed} {font_fixed_size}"
        gsettings set org.cinnamon.desktop.wm.preferences titlebar-font "${font_ui} {font_ui_size}"
        gsettings set org.nemo.desktop font                             "${font_ui} {font_ui_size}"
    fi

    if kdebased
    then
        font_options="-1,5,50,0,0,0,0,0,Regular"

        addconfigline 'XftHintStyle' 'hintslight' 'General' "${HOME}/.config/kdeglobals"
        addconfigline 'XftSubPixel'  ''           'General' "${HOME}/.config/kdeglobals"

        addconfigline 'fixed' "${font_fixed},${font_fixed_size},${font_options}" 'General' "${HOME}/.config/kdeglobals"

        for file in "${HOME}/.config/kdeglobals" "${HOME}/.kde/share/config/kdeglobals"
        do
            for font in font menuFont smallestReadableFont toolBarFont
            do
                addconfigline "$font" "${font_ui},${font_ui_size},${font_options}" 'General' "$file"
            done
        done

        unset font_options
    fi

    unset font_ui
    unset font_doc
    unset font_fixed

    unset font_ui_size
    unset font_doc_size
    unset font_fixed_size

;;

### Wallpaper ==================================================================

"appearance/wallpaper")

    if test -f '/usr/share/backgrounds/custom/backgrounds/skunze_beach.jpg'
    then
        ( sleep 20 ; setwallpaper '/usr/share/backgrounds/custom/backgrounds/skunze_beach.jpg' ) &
    else
        ( sleep 20 ; setwallpaper '#204a87' ) &
    fi

    if test -f '/usr/share/backgrounds/custom/lock/stars.jpg'
    then
        ( sleep 20 ; setlockscreen '/usr/share/backgrounds/custom/lock/stars.jpg' ) &
    fi

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

    if ispkginstalled rhythmbox
    then
        launcheradd 'rhythmbox'
    fi

    ## hide apps from application menu -----------------------------------------

    hideapp 'easytag'
    hideapp 'mpv'

    ## A simple MPRIS indicator button Gnome Shell extension -------------------

    if ispkginstalled gnome-shell
    then
        gsettingsadd org.gnome.shell enabled-extensions 'mprisindicatorbutton@JasonLG1979.github.io'
    fi

    ## rhythmbox ---------------------------------------------------------------

    if ispkginstalled rhythmbox
    then
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
        #gsettingsadd org.gnome.rhythmbox.plugins active-plugins 'notification'
        gsettingsadd org.gnome.rhythmbox.plugins active-plugins 'mpris'
        gsettingsadd org.gnome.rhythmbox.plugins active-plugins 'mmkeys'
        gsettingsadd org.gnome.rhythmbox.plugins active-plugins 'grilo'
        gsettingsadd org.gnome.rhythmbox.plugins active-plugins 'generic-player'

        gsettings set org.gnome.rhythmbox.plugins.iradio initial-stations-loaded true
    fi

    ## MPV ---------------------------------------------------------------------

    if ispkginstalled mpv
    then
        mkdir -p "${HOME}/.config/mpv"
        cp -f "${ROOT_PATH}/files/mpv/mpv.conf" "${HOME}/.config/mpv/"
    fi


    ## Sound Input & Output Device Chooser Gnome Shell extension ---------------

    if ispkginstalled gnome-shell
    then
        gsettingsadd org.gnome.shell enabled-extensions 'sound-output-device-chooser@kgshank.net'

        dconf write /org/gnome/shell/extensions/sound-output-device-chooser/hide-on-single-device   true
        dconf write /org/gnome/shell/extensions/sound-output-device-chooser/show-input-devices      false
        dconf write /org/gnome/shell/extensions/sound-output-device-chooser/show-profiles           false
        dconf write /org/gnome/shell/extensions/sound-output-device-chooser/show-output-devices     true
        dconf write /org/gnome/shell/extensions/sound-output-device-chooser/hide-menu-icons         false
        dconf write /org/gnome/shell/extensions/sound-output-device-chooser/icon-theme              "'monochrome'"
        dconf write /org/gnome/shell/extensions/sound-output-device-chooser/show-input-slider       false
    fi

;;

### Online video ===============================================================

"media-online")

    echo "alias ytmp3='youtube-dl -f bestaudio --extract-audio --audio-format mp3 --audio-quality 0'" >> ~/.bash_aliases

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
    bash "${scriptpath}" 'network/remotedesktop'

;;

### Browser ====================================================================

"network/browser")

    if ispkginstalled google-chrome-stable
    then
        launcheradd 'google-chrome'
    fi

;;

### Mail =======================================================================

"network/mail")

    if ispkginstalled
    then
        launcheradd 'org.gnome.Evolution'
    fi

;;

### Chat =======================================================================

"network/chat")

    ## Empathy -----------------------------------------------------------------

    if ispkginstalled empathy
    then
        mkdir -p "${HOME}/.config/autostart"
        cp -f "${ROOT_PATH}/files/empathy/empathy.desktop" "${HOME}/.config/autostart/"

        gsettings set org.gnome.Empathy.conversation theme          'material'
        gsettings set org.gnome.Empathy.conversation theme-variant  'Green'
        gsettings set org.gnome.Empathy.conversation adium-path     '/usr/share/adium/message-styles/material.AdiumMessageStyle'

        gsettings set org.gnome.Empathy.ui show-groups              true

        gsettings set org.gnome.Empathy.conversation spell-checker-languages 'en,ru'
    fi

    ## Pidgin ------------------------------------------------------------------

    if ispkginstalled pidgin
    then
        mkdir -p "${HOME}/.config/autostart"
        cp -f "${ROOT_PATH}/files/pidgin/pidgin.desktop" "${HOME}/.config/autostart/"

        mkdir -p "${HOME}/.purple/themes"

        sed "s/{HOME}/$(safestring "${HOME}")/g" "${ROOT_PATH}/files/pidgin/prefs.xml" > "${HOME}/.purple/prefs.xml"

        cp -rf "${ROOT_PATH}/files/pidgin/themes/"* "${HOME}/.purple/themes"
    fi

;;

### Chat extra protocols =======================================================

"network/chat-extra")

    mkdir -p "${HOME}/.config/autostart"

    if ispkginstalled telegram-desktop
    then
        cp -f "${ROOT_PATH}/files/telegram/telegramdesktop.desktop" "${HOME}/.config/autostart/"
    fi

    if ispkginstalled vk
    then
        cp -f '/usr/share/applications/vk.desktop' "${HOME}/.config/autostart/"
    fi

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

    if ispkginstalled transmission-remote-gtk
    then
        mkdir -p "${HOME}/.config/transmission-remote-gtk/"
        cp -rf "${ROOT_PATH}/files/transmission-remote-gtk/config.json" "${HOME}/.config/transmission-remote-gtk/"
    fi

    ## EiskaltDC++ Remote ------------------------------------------------------

    if ispkginstalled eiskaltdcpp-remote-qt
    then
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
    fi

    ## Bookmarks for SFTP ------------------------------------------------------

    addbookmark 'sftp://188.134.72.31:2222/media/documents' 'SFTP'
    addbookmark 'sftp://192.168.1.5/media/documents'        'SFTP (LAN)'

;;

### Remote desktop =============================================================

"network/remotedesktop")

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

    addbookmark "file://${HOME}/Projects" 'Projects'

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

    if ispkginstalled tracker
    then
        tracker daemon -t

        mkdir -p "${HOME}/.config/autostart"
        cd "${HOME}/.config/autostart"

        cp  /etc/xdg/autostart/tracker-* ./

        for FILE in tracker-*.desktop
        do
            echo 'Hidden=true' >> "$FILE"
        done

        rm -rf "${HOME}/.cache/tracker" "${HOME}/.local/share/tracker"
    fi

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

esac

