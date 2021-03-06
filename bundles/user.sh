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

    ## Remove annoying sudo banner =============================================

    touch "${HOME}/.sudo_as_admin_successful"

    ## Hide info documentation browser =========================================

    hideapp 'info'

    ## Disable Ubuntu telemetry ================================================

    if which ubuntu-report >/dev/null 2>/dev/null
    then
        ubuntu-report send no
    fi

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

    gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('xkb', 'ru')]"

    gsettings set org.gnome.desktop.wm.keybindings switch-input-source "['<Shift>Alt_L', '<Alt>Shift_L', '<Super>space']"
    gsettings set org.gnome.desktop.wm.keybindings switch-input-source-backward "['<Primary><Shift>Alt_L', '<Primary><Alt>Shift_L', '<Shift><Super>space', '<Primary><Super>space']"

    gsettings set org.gnome.desktop.wm.keybindings show-desktop "['<Super>d']"

    addkeybinding 'System Monitor' 'gnome-system-monitor' '<Ctrl><Shift>Escape'
    addkeybinding 'File Manager'   'nautilus -w'          '<Super>E'

    ## File manager keybindings ================================================

    addscenario 'terminal' 'F4' 'x-terminal-emulator &' --fixpwd
    addscenario 'compress' 'F7' '[[ $# -gt 0 ]] && file-roller -d "$@" &'

    ## File chooser ============================================================

    gsettings set org.gtk.Settings.FileChooser sort-directories-first       true

    ## Set Nautilus default icon size ==========================================

    if ispkginstalled nautilus
    then
        gsettings set org.gnome.nautilus.icon-view default-zoom-level 'large'
    fi

    ## Remove home folder and trash icons from desktop =========================

    if ispkginstalled gnome-shell-extension-desktop-icons
    then
        gsettings set org.gnome.shell.extensions.desktop-icons show-home false
        gsettings set org.gnome.shell.extensions.desktop-icons show-trash false
    fi

    ## Remove trash icon from dock =============================================

    if ispkginstalled gnome-shell-extension-ubuntu-dock
    then
        gsettings set org.gnome.shell.extensions.dash-to-dock show-trash false
    fi

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
            if [[ "$(pkgversion gedit | cut -d '.' -f 2)" -lt 36 ]]
            then
                gsettings set org.${editor}.preferences.editor display-overview-map true
            else
                gsettings set org.gnome.gedit.preferences.editor background-pattern 'grid'
            fi

            encodingsettings='candidate-encodings'

        elif [[ "$editor" == 'x.editor' ]]
        then
            gsettings set org.x.editor.preferences.ui minimap-visible true

            encodingsettings='auto-detected'
        fi


        gsettingsclear org.${editor}.preferences.encodings "$encodingsettings"

        for encoding in 'UTF-8' 'WINDOWS-1251' 'KOI8R' 'CP866' 'UTF-16'
        do
            gsettingsadd org.${editor}.preferences.encodings "$encodingsettings" "$encoding"
        done


        gsettings set org.${editor}.plugins active-plugins "['changecase', 'filebrowser', 'time', 'zeitgeistplugin', 'docinfo']"
    done

    unset editors

    ## gnome-terminal ==========================================================

    if ispkginstalled gnome-terminal
    then
        term_profile=$(gsettings get org.gnome.Terminal.ProfilesList default | cut -d "'" -f 2)

        gsettings set org.gnome.Terminal.Legacy.Settings default-show-menubar false
        gsettings set org.gnome.Terminal.Legacy.Settings menu-accelerator-enabled false
        gsettings set org.gnome.Terminal.Legacy.Settings theme-variant 'dark'

        gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${term_profile}/" visible-name 'UTF-8'
        gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${term_profile}/" use-transparent-background true
        gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${term_profile}/" background-transparency-percent 5
        gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${term_profile}/" scrollbar-policy 'always'
        gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${term_profile}/" allow-bold false
    fi

    ## Setup night light =======================================================

    if ispkginstalled redshift-gtk
    then
        usercopy 'redshift-gtk'
    fi

    ## Configure Gnome system monitor ==========================================

    if ispkginstalled gnome-system-monitor
    then
        gsettings set org.gnome.gnome-system-monitor network-in-bits true
    fi

    ## Lock screen orientation =================================================

    gsettings set org.gnome.settings-daemon.peripherals.touchscreen orientation-lock true

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

    ## Crerate utilities launcher group ========================================

    if ispkginstalled gnome-shell
    then
        gsettingsadd org.gnome.desktop.app-folders folder-children 'Utils'
        gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/Utils/ name 'Utils.directory'
        gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/Utils/ translate true

        for app in Characters FileRoller DiskUtility Devhelp Screenshot baobab seahorse.Application Software tweaks Extensions Logs
        do
            gsettingsadd org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/Utils/ apps "org.gnome.${app}.desktop"
        done

        for app in htop update-manager usb-creator-gtk gnome-system-monitor ubiquity gnome-nettool yelp ghostwriter com.github.fabiocolacio.marker
        do
            gsettingsadd org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/Utils/ apps "${app}.desktop"
        done
    fi

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
        gsettings set org.gnome.desktop.interface enable-hot-corners true

        ## Disable modal dialogs attach ----------------------------------------
        gsettings set org.gnome.shell.overrides attach-modal-dialogs false

        ## Disable frequent applications view ----------------------------------
        gsettings set org.gnome.desktop.privacy remember-app-usage false
    fi

    ## Location services =======================================================

    gsettings set org.gnome.system.location enabled true

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
        ## Enable app indicators -----------------------------------------------
        gsettingsadd org.gnome.shell enabled-extensions 'ubuntu-appindicators@ubuntu.com'

        ## Remove accessibility icon -------------------------------------------
        gsettingsadd org.gnome.shell enabled-extensions 'removeaccesibility@lomegor'

        ## Remove Dropdown Arrows ----------------------------------------------
        gsettingsadd org.gnome.shell enabled-extensions 'remove-dropdown-arrows@mpdeimos.com'

        ## Skip Window Ready Notification --------------------------------------
        gsettingsadd org.gnome.shell enabled-extensions 'skipwindowreadynotification@JasonLG1979.github.io'

        ## Bring Out Submenu Of Power Off/Logout Button ------------------------
        gsettingsadd org.gnome.shell enabled-extensions 'BringOutSubmenuOfPowerOffLogoutButton@pratap.fastmail.fm'

    fi

    ## Window control buttons --------------------------------------------------

    gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'

    ## Remove mounts from dash panel -------------------------------------------

    if gsettings writable org.gnome.shell.extensions.dash-to-dock show-mounts 1>/dev/null 2>/dev/null
    then
        gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts false
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

    ## KDE =====================================================================

    if kdebased
    then
        usercopy 'kde'

        ## Keyboard ------------------------------------------------------------

        addkeybinding 'System Monitor' 'ksysguard'        '<Ctrl><Shift>Escape'
        addkeybinding 'File Manager'   'dolphin'          '<Super>E'
    fi

    ## Konsole =================================================================

    if ispkginstalled konsole
    then
        usercopy 'konsole'
    fi

    ## Kate ====================================================================

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

    echo "alias makej='make -j \$(nproc)'" >> ~/.bash_aliases

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

    ## Qt Creator ==============================================================

    if ispkginstalled 'qtcreator'
    then

        ## launcher ------------------------------------------------------------

        launcheradd 'org.qt-project.qtcreator'

        hideapp 'assistant-qt5'
        hideapp 'designer-qt5'
        hideapp 'linguist-qt5'

        ## Mime type -----------------------------------------------------------

        mimedefault 'org.qt-project.qtcreator' 'application'

        ## Qt Creator ----------------------------------------------------------

        rm -rf "${HOME}/.config/QtProject"
        usercopy 'qtcreator' --replace '.config/QtProject/QtCreator.ini'

        ## Disable ClangFormat for QtCreator 4.11.0 ----------------------------

        #TODO: Remove after qtcreator update
        if [[ "$(pkgversion qtcreator | cut -d '-' -f 1)" == '4.11.0' ]]
        then
            addconfigline 'Ignored'      'Android, AutoTest, Bazaar, ClangFormat, CMakeProjectManager, CVS, CodePaster, FakeVim, GLSLEditor, Mercurial, Perforce, PythonEditor, QbsProjectManager, QmakeAndroidSupport, QmlDesigner, QmlJSEditor, QmlJSTools, QmlProfiler, QmlProjectManager, Qnx, TaskList' 'Plugins' "${HOME}/.config/QtProject/QtCreator.ini"
            addconfigline 'ForceEnabled' 'Beautifier, Cppcheck, Todo' 'Plugins' "${HOME}/.config/QtProject/QtCreator.ini"
        fi

        ## Configure color schemes ---------------------------------------------

        qvariant=''

        declare -A qtstyles

        qtstyles['flat-light']="${HOME}/.config/QtProject/qtcreator/styles/material.xml"
        qtstyles['flat-dark']="${HOME}/.config/QtProject/qtcreator/styles/material_dark.xml"

        count="${#qtstyles[@]}"

        qvariant="${qvariant}$(printf %08x%08x 8 $count)"

        for i in "${!qtstyles[@]}"
        do
            key="$i"
            val="${qtstyles[$i]}"

            keylength=$((${#key} * 2))
            vallength=$((${#val} * 2))

            keyhex=$(echo -n "$key" | iconv -t utf-16be | xxd -p | tr -d '\n')
            valhex=$(echo -n "$val" | iconv -t utf-16be | xxd -p | tr -d '\n')

            delimiter='0000000a'

            qvariant="${qvariant}$(printf %08x%s%s%08x%s "$keylength" "$keyhex" "$delimiter" "$vallength" "$valhex")"
        done

        qvariant="$(echo -n "$qvariant" | sed 's/\(..\)/\\x\1/g' | sed 's/\\x08/\\b/g;s/\\x0a/\\n/g' | sed 's/\\x2f/\//g' | sed 's/\\x00/\\0/g;s/\\x0/\\x/g')"

        addconfigline 'ColorSchemes' "@Variant(${qvariant})" 'TextEditor' "${HOME}/.config/QtProject/QtCreator.ini"

        unset qvariant
        unset qtstyles

        ## ---------------------------------------------------------------------

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

    ## Hide Sysprof ============================================================

    hideapp 'org.gnome.Sysprof2'
    hideapp 'org.gnome.Sysprof3'

    ## Gnome Builder ===========================================================

    if ispkginstalled 'gnome-builder'
    then

        ## Register mimetypes --------------------------------------------------

        mimeregister 'text/x-makefile'           'org.gnome.Builder.desktop'
        mimeregister 'application/x-shellscript' 'org.gnome.Builder.desktop'

        ## gnome builder -------------------------------------------------------

        gsettings set org.gnome.builder        follow-night-light   false
        gsettings set org.gnome.builder        night-mode           false
        gsettings set org.gnome.builder.editor show-map             true
        gsettings set org.gnome.builder.editor font-name            'Fira Code 12'

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

        for plugin in dspy glade gvls_plugin jhbuild_plugin newcomers npm_plugin podman python_gi_imports_completion qemu rust-analyzer rustup_plugin valgrind_plugin
        do
            gsettings set org.gnome.builder.plugin:/org/gnome/builder/plugins/${plugin}/ enabled false
        done
    fi

;;

### Database ===================================================================

"dev/db")

    if ispkginstalled sqlitebrowser
    then
        usercopy 'sqlitebrowser'
    fi

;;

### JSON libraries =============================================================

"dev/json")

;;

### Markdown editor ============================================================

"dev/markdown")

    ## Ghostwriter markdown editor ---------------------------------------------

    if ispkginstalled ghostwriter
    then
        usercopy 'ghostwriter'
    fi

    ## Marker markdown editor --------------------------------------------------

    if ispkginstalled marker
    then
        gsettings set com.github.fabiocolacio.marker.preferences.preview css-theme          'GitHub2.css'
        gsettings set com.github.fabiocolacio.marker.preferences.preview highlight-theme    'github'

        gsettings set com.github.fabiocolacio.marker.preferences.editor enable-syntax-theme 'true'
        gsettings set com.github.fabiocolacio.marker.preferences.editor syntax-theme        'tango'

        gsettings set com.github.fabiocolacio.marker.preferences.editor replace-tabs        'true'
    fi

;;

### Network ====================================================================

"dev/net")

;;

### TI TMS320C64XX =============================================================

"dev/ti")

;;

### KMX32 GCC ==================================================================

"dev/kmx32")

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
        echo -e "\nfunction gitversion()\n{\n    git log --pretty=format:'%h' \"\$@\" | wc -w\n}\n\n" >> ~/.bash_aliases
    fi

    if [[ -z "$(grep 'githash()' ~/.bash_aliases)" ]]
    then
        echo -e "\nfunction githash()\n{\n    git rev-parse --short HEAD \"\$@\"\n}\n\n" >> ~/.bash_aliases
    fi

    ## Make git save credentials by default ------------------------------------

    git config --global credential.helper store

    ## Set default pull startegy -----------------------------------------------

    git config --global pull.ff only

    ## Meld --------------------------------------------------------------------

    if ispkginstalled 'meld'
    then
        gsettings set org.gnome.meld highlight-syntax   true
        gsettings set org.gnome.meld style-scheme       'kate'
        gsettings set org.gnome.meld show-line-numbers  true
        gsettings set org.gnome.meld indent-width       4

        addscenario 'compare' 'F3' '[[ $# -eq 0 ]] && ( svn info || git status ) && meld . &\n[[ $# -eq 1 && -d "$1" ]] && ( svn info "$1" || ( cd "$1" && git status ) ) && meld "$1" &\n[[ $# -eq 1 && ! -d "$1" ]] && ( svn info "$1" || ( cd "$(dirname "$1")" && git ls-files --error-unmatch "$(basename "$1")" ) ) && meld "$1" &\n[[ $# -gt 1 ]] && meld "$@" &'
        addkdescenario 'compare' 'F3' 'meld %F' 'meld' 'all/allfiles'
    fi

    ## Gitg --------------------------------------------------------------------

    if ispkginstalled 'gitg'
    then
        addkeybinding 'Gitg' 'gitg' '<Ctrl><Alt>G'

        addscenario    'gitg'   '<Ctrl>G'  '[[ $# -eq 0 ]] && git status && test -n "$(git diff-index --name-only HEAD --)" && gitg --standalone --commit . &\n[[ $# -eq 0 ]] && git status && test -z "$(git diff-index --name-only HEAD --)" && gitg --standalone . &\n[[ $# -eq 1 ]] && ( cd "$1" && git status && test -n "$(git diff-index --name-only HEAD --)" ) && gitg --standalone --commit "$1" &\n[[ $# -eq 1 ]] && ( cd "$1" && git status && test -z "$(git diff-index --name-only HEAD --)" ) && gitg --standalone "$1" &'
        addkdescenario 'gitg'   '<Ctrl>G'  'gitg %f' 'gitg' 'inode/directory'
        addscenario    'gitgf3' '<Ctrl>F3' '[[ $# -eq 0 ]] && git status && test -n "$(git diff-index --name-only HEAD --)" && gitg --standalone --commit . &\n[[ $# -eq 0 ]] && git status && test -z "$(git diff-index --name-only HEAD --)" && gitg --standalone . &\n[[ $# -eq 1 ]] && ( cd "$1" && git status && test -n "$(git diff-index --name-only HEAD --)" ) && gitg --standalone --commit "$1" &\n[[ $# -eq 1 ]] && ( cd "$1" && git status && test -z "$(git diff-index --name-only HEAD --)" ) && gitg --standalone "$1" &'
        addkdescenario 'gitgf3' '<Ctrl>F3' 'gitg %f' 'gitg' 'inode/directory'
    fi

    ## Rabbitvcs ---------------------------------------------------------------

    if ispkginstalled rabbitvcs-core || ispkginstalled rabbitvcs-core-python3
    then
        addconfigline 'hg'  'True'  'HideItem' "${HOME}/.config/rabbitvcs/settings.conf"
        addconfigline 'svn' 'False' 'HideItem' "${HOME}/.config/rabbitvcs/settings.conf"
        addconfigline 'git' 'False' 'HideItem' "${HOME}/.config/rabbitvcs/settings.conf"
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

    icon_theme='mPapirus'
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

        gsettings set org.cinnamon.desktop.interface gtk-theme      'Mint-Y-Darker-Aqua'
        gsettings set org.cinnamon.desktop.wm.preferences theme     'Mint-Y-Dark'
        gsettings set org.cinnamon.theme name                       'Mint-Y-Aqua'
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
    font_doc='Noto Serif'
    font_fixed='Fira Code'

    font_ui_size='10'
    font_doc_size='12'
    font_fixed_size='12'

    if ispkginstalled gnome-shell
    then
        gsettings set org.gnome.desktop.interface font-name             "${font_ui} ${font_ui_size}"
        gsettings set org.gnome.desktop.interface document-font-name    "${font_doc} ${font_doc_size}"
        gsettings set org.gnome.desktop.interface monospace-font-name   "${font_fixed} ${font_fixed_size}"
        gsettings set org.gnome.desktop.wm.preferences titlebar-font    "${font_ui} ${font_ui_size}"
    fi

    if ispkginstalled cinnamon
    then
        gsettings set org.cinnamon.desktop.interface font-name          "${font_ui} ${font_ui_size}"
        gsettings set org.gnome.desktop.interface document-font-name    "${font_doc} ${font_doc_size}"
        gsettings set org.gnome.desktop.interface monospace-font-name   "${font_fixed} ${font_fixed_size}"
        gsettings set org.cinnamon.desktop.wm.preferences titlebar-font "${font_ui} ${font_ui_size}"
        gsettings set org.nemo.desktop font                             "${font_ui} ${font_ui_size}"
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

    if [[ ! -f "${HOME}/.config/is-work-account" ]]
    then
        bgtheme='custom'
        bgfile='file:///usr/share/backgrounds/custom/skunze_beach.jpg'
    else
        bgtheme='blueprint'
        bgfile='file:///usr/share/backgrounds/blueprint/blueprint-empty.jpg'
    fi

    if ispkginstalled gnome-shell
    then
        gsettings set org.gnome.desktop.background secondary-color      '#000000'
        gsettings set org.gnome.desktop.background primary-color        '#000000'
        gsettings set org.gnome.desktop.background picture-options      'zoom'
        gsettings set org.gnome.desktop.background color-shading-type   'solid'
        gsettings set org.gnome.desktop.background draw-background      true
        gsettings set org.gnome.desktop.background picture-opacity      100
        gsettings set org.gnome.desktop.background picture-uri          "file:///usr/share/backgrounds/${bgtheme}/${bgtheme}.xml"

        gsettings set org.gnome.desktop.screensaver secondary-color      '#000000'
        gsettings set org.gnome.desktop.screensaver primary-color        '#000000'
        gsettings set org.gnome.desktop.screensaver picture-options      'zoom'
        gsettings set org.gnome.desktop.screensaver color-shading-type   'solid'
        gsettings set org.gnome.desktop.screensaver picture-opacity      100
        gsettings set org.gnome.desktop.screensaver picture-uri          'file:///usr/share/backgrounds/night/night.xml'

    fi

    if ispkginstalled cinnamon
    then
        gsettings set org.cinnamon.desktop.background secondary-color    '#000000'
        gsettings set org.cinnamon.desktop.background primary-color      '#000000'
        gsettings set org.cinnamon.desktop.background picture-options    'zoom'
        gsettings set org.cinnamon.desktop.background color-shading-type 'solid'
        gsettings set org.cinnamon.desktop.background picture-opacity    100
        gsettings set org.cinnamon.desktop.background picture-uri        "$bgfile"

        gsettings set org.cinnamon.desktop.background.slideshow delay             30
        gsettings set org.cinnamon.desktop.background.slideshow random-order      true
        gsettings set org.cinnamon.desktop.background.slideshow slideshow-paused  false
        gsettings set org.cinnamon.desktop.background.slideshow image-source      'xml:///usr/share/cinnamon-background-properties/${bgtheme}.xml'
        gsettings set org.cinnamon.desktop.background.slideshow slideshow-enabled true
    fi

;;

### User avatar ================================================================

"appearance/avatar")

;;

### ============================================================================
### Office applications ========================================================
### ============================================================================

"office")

    ## hide apps from application menu -----------------------------------------

    hideapp 'libreoffice-startcenter'

    ## Libreoffice  ------------------------------------------------------------

    usercopy 'libreoffice'

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

    ## rhythmbox ---------------------------------------------------------------

    if ispkginstalled rhythmbox
    then
        usercopy 'rhythmbox'

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
        usercopy 'mpv'
    fi

    ## Clementine --------------------------------------------------------------

    if ispkginstalled clementine
    then
        usercopy 'clementine'
    fi

    ## Shotwell ----------------------------------------------------------------

    if ispkginstalled shotwell
    then
        mimedefault 'shotwell-viewer' 'image'

        gsettings set org.yorba.shotwell.preferences.ui show-welcome-dialog false
        gsettings set org.yorba.shotwell.preferences.files auto-import true
        gsettings set org.yorba.shotwell.crop-settings last-crop-menu-choice 0
    fi

    ## A simple MPRIS indicator button Gnome Shell extension -------------------

    if ispkginstalled gnome-shell
    then
        gsettingsadd org.gnome.shell enabled-extensions 'mprisindicatorbutton@JasonLG1979.github.io'
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

    ## Caffeine ----------------------------------------------------------------

    if ispkginstalled gnome-shell
    then
        gsettingsadd org.gnome.shell enabled-extensions 'caffeine@patapon.info'

        dconf write /org/gnome/shell/extensions/caffeine/show-indicator     false
        dconf write /org/gnome/shell/extensions/caffeine/show-notifications false
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
    bash "${scriptpath}" 'network/chat-extra'
    bash "${scriptpath}" 'network/office'
    bash "${scriptpath}" 'network/services'
    bash "${scriptpath}" 'network/remote'
    bash "${scriptpath}" 'network/remotedesktop'

;;

### Browser ====================================================================

"network/browser")

    if ispkginstalled google-chrome-stable && [[ ! -f "${HOME}/.config/is-work-account" ]]
    then
        launcheradd 'google-chrome'
    fi

;;

### Mail =======================================================================

"network/mail")

    if ispkginstalled geary
    then

        if ! ishidden 'org.gnome.Geary'
        then
            launcheradd 'org.gnome.Geary'

            setdefaultapp 'x-scheme-handler/mailto' 'org.gnome.Geary.desktop'

            usercopy 'geary'
        fi
    fi

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

### Remote desktop =============================================================

"network/remotedesktop")

;;

### ============================================================================
### Graphic applications =======================================================
### ============================================================================

"graphics")

    hideapp 'display-im6.q16'

    if ispkginstalled gimp
    then
        mimedefault 'gimp' 'image'
    fi

    if ispkginstalled shotwell
    then
        mimedefault 'shotwell-viewer' 'image'

        gsettings set org.yorba.shotwell.preferences.ui show-welcome-dialog false
        gsettings set org.yorba.shotwell.preferences.files auto-import true
        gsettings set org.yorba.shotwell.crop-settings last-crop-menu-choice 0
    fi

    if ispkginstalled shotwell && ispkginstalled gimp
    then
        gsettings set org.yorba.shotwell.preferences.editing external-photo-editor "$(getconfigline 'Exec' 'Desktop Entry' /usr/share/applications/gimp.desktop)"
    fi

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

    if [[ -n "$(which nano)" ]]
    then
        echo "SELECTED_EDITOR=\"$(which nano)\"" > "${HOME}/.selected_editor"
    fi

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
    bash "${scriptpath}" 'optimize/disable-tracker'
;;

### Mount directories with high I/O as tmpfs ===================================

"optimize/tmpfs")

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

    if [[ -f "${HOME}/.config/is-work-account" ]]
    then

    ## Disable first configuration =============================================

    if [[ -f /usr/libexec/gnome-initial-setup ]]
    then
        echo -n 'yes' > "${HOME}/.config/gnome-initial-setup-done"
    fi

    ## User network configuration ==============================================

    ## Configure network connections -------------------------------------------

    if ispkginstalled network-manager
    then

        uuidstoremove="$(nmcli --fields=UUID,TYPE connection show | grep 'ethernet[[:space:]]*' | cut -d ' ' -f 1)"

        nmcli conn add type ethernet con-name "RCZIFORT (DHCP)" \
                       ifname '' ipv4.method auto \
                       ipv4.dns "172.16.56.14 172.16.56.10" \
                       ipv4.dns-search "rczifort.local" \
                       ipv4.ignore-auto-dns true \
                       ipv6.method ignore 2>/dev/null \
            || echo "Failed to add network connection" >&2


        if [[ -f '/sys/class/net/eth0/address' ]]
        then
            addr=''

            case "$(cat /sys/class/net/eth0/address)" in

            'ac:22:0b:27:c5:ec')
                addr='172.16.8.91'
                ;;

            'b4:2e:99:be:df:69')
                addr='172.16.8.52'
                ;;

            esac

            if [[ -n "$addr" ]]
            then

                nmcli conn add type ethernet con-name "RCZIFORT (STATIC)" \
                               ifname '' ipv4.method manual \
                               ipv4.address "${addr}/24" \
                               ipv4.gateway "172.16.8.253" \
                               ipv4.dns "172.16.56.14 172.16.56.10" \
                               ipv4.dns-search "rczifort.local" \
                               ipv4.ignore-auto-dns true \
                               ipv6.method ignore \
                               connection.autoconnect-priority 1 2>/dev/null \
                    || echo "Failed to add network connection" >&2

            fi

        fi

        while read uuid
        do
            [[ -z "${uuid}" ]] && continue

            nmcli connection del uuid "${uuid}" 2>/dev/null

        done <<< "${uuidstoremove}"

    fi

    ## Network switcher hotkey -------------------------------------------------

    if ispkginstalled network-switch
    then
        addkeybinding 'Switch network' 'network-switch' '<Ctrl><Alt>N'
    fi

    ## Add network shares ------------------------------------------------------

    addbookmark 'smb://172.16.8.21/share2'         'KUB'
    addbookmark 'smb://172.16.8.203'               'NAS'
    addbookmark 'smb://172.16.56.23/shares'        'RCZIFORT'

    ## Add network printer -----------------------------------------------------

    if ispkginstalled cups-client
    then
        if [[ -z "$(lpstat -v | grep ' socket://172.16.8.200:9100$')" ]]
        then
            lpadmin -p 'HP_Laserjet_1320' -D 'HP LaserJet 1320' -L 'Комната 11' \
                -E -v 'socket://172.16.8.200:9100' \
                -m 'foomatic-db-compressed-ppds:0/ppd/foomatic-ppd/Generic-PCL_5e_Printer-hpijs-pcl5e.ppd' \
                -o printer-is-shared=false

            lpadmin -d 'HP_Laserjet_1320'
        fi

        if [[ -z "$(lpstat -v | grep ' socket://172.16.8.201$')" ]]
        then
            lpadmin -p 'Kyocera_Dev' -D 'Kyocera Dev' -L 'Комната 8' \
                -E -v 'socket://172.16.8.201' \
                -m 'foomatic-db-compressed-ppds:0/ppd/foomatic-ppd/Generic-PCL_6_PCL_XL_Printer-pxlcolor.ppd' \
                -o printer-is-shared=false

            lpadmin -d 'Kyocera_Dev'
        fi
    fi

    ## Customization ===========================================================

    ## Generate SSH private and public key pair --------------------------------

    if [[ ! -f "${HOME}/.ssh/id_rsa" ]]
    then
        ssh-keygen -q -t rsa -N '' -f "${HOME}/.ssh/id_rsa" 2>/dev/null <<< y >/dev/null
    fi

    ## Make Git accept self-signed certificate ---------------------------------

    git config --global http.https://git.rczifort.local.sslVerify false
    git config --global http.https://172.16.56.22.sslVerify       false

    ## Make Git use specific username for home projects ------------------------

    for userdir in '~' "/media/documents/${USER}"
    do
        git config --global "includeIf.gitdir:${userdir}/Projects/home/.path" '.gitconfig-home'
    done

    git config --file "${HOME}/.gitconfig-home" user.name  ''
    git config --file "${HOME}/.gitconfig-home" user.email ''

    ## Add KOI8-R terminal profile ---------------------------------------------

    if ispkginstalled gnome-terminal
    then
        newprofileid="$(uuidgen)"

        gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${newprofileid}/" visible-name 'KOI8-R'
        gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${newprofileid}/" encoding 'KOI8-R'
        gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${newprofileid}/" use-transparent-background true
        gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${newprofileid}/" background-transparency-percent 5
        gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${newprofileid}/" scrollbar-policy 'always'
        gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${newprofileid}/" allow-bold false

        gsettingsadd org.gnome.Terminal.ProfilesList list "${newprofileid}"
    fi

    ## Gnome shell extensions ==================================================

    if ispkginstalled gnome-shell
    then
        gsettingsadd org.gnome.shell enabled-extensions 'drive-menu@gnome-shell-extensions.gcampax.github.com'
    fi

    ## Configure Epiphany ======================================================

    if ispkginstalled epiphany-browser
    then

        ## Set user agent ------------------------------------------------------

        dconf write /org/gnome/epiphany/web/user-agent "'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:72.0) Gecko/20100101 Firefox/72.0'"

        ## Disable safe browsing and ad blocking -------------------------------

        dconf write /org/gnome/epiphany/web/enable-adblock       false
        dconf write /org/gnome/epiphany/web/enable-safe-browsing false

        ## Do not restore tabs -------------------------------------------------

        dconf write /org/gnome/epiphany/restore-session-policy  "'crashed'"

        ## Configure encodings -------------------------------------------------

        for encoding in 'KOI8-R' 'IBM866' 'windows-1251' 'UTF-8'
        do
            dconfadd /org/gnome/epiphany/state recent-encodings "${encoding}"
        done

        ## Set Epiphany as default web browser =================================

        setdefaultapp   'x-scheme-handler/http'  'org.gnome.Epiphany.desktop'
        setdefaultapp   'x-scheme-handler/https' 'org.gnome.Epiphany.desktop'

        ## ---------------------------------------------------------------------

    fi

    ## Configure calculator ====================================================

    if ispkginstalled gnome-calculator
    then
        gsettings set org.gnome.calculator button-mode 'programming'
    fi

    ## Crerate RCZI web services group =========================================

    if ispkginstalled gnome-shell
    then
        gsettingsadd org.gnome.desktop.app-folders folder-children 'RcziWeb'
        gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/RcziWeb/ name 'RCZI Web Services'
        gsettingsadd  org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/RcziWeb/ categories "X-WEB-RCZI"
    fi

    ## Photo editor ============================================================

    if ispkginstalled shotwell
    then
        gsettings set org.yorba.shotwell.plugins.enable-state publishing-facebook false
        gsettings set org.yorba.shotwell.plugins.enable-state publishing-gallery3 false
        gsettings set org.yorba.shotwell.plugins.enable-state publishing-tumblr false
        gsettings set org.yorba.shotwell.plugins.enable-state publishing-yandex-fotki false
        gsettings set org.yorba.shotwell.plugins.enable-state publishing-piwigo false
        gsettings set org.yorba.shotwell.plugins.enable-state publishing-rajce false
        gsettings set org.yorba.shotwell.plugins.enable-state org-gnome-shotwell-publishing-google-photos false
        gsettings set org.yorba.shotwell.plugins.enable-state publishing-flickr false
        gsettings set org.yorba.shotwell.plugins.enable-state publishing-youtube false
    fi

    ## =========================================================================

    fi

    ## Create bookmark to rczi user ============================================

    if [[ "${USER}" != 'rczi' && -n "$(cut -d ':' -f 1 /etc/passwd | grep '^rczi$')"  ]]
    then
        addbookmark 'sftp://rczi@localhost/home/rczi' 'rczi user'
    fi

    ## =========================================================================

;;

"work-mail")

    ## Evolution ---------------------------------------------------------------

    if ispkginstalled evolution
    then
        if ! ishidden 'org.gnome.Evolution'
        then
            launcheradd 'org.gnome.Evolution'

            setdefaultapp 'x-scheme-handler/mailto' 'org.gnome.Evolution.desktop'
        fi

        usercopy 'evolution'

        gsettings set org.gnome.evolution.mail mark-seen-timeout 750

        gsettingsclear org.gnome.evolution disabled-eplugins

        for plugin in plugin.dbx.import bbdb plugin.templates face plugin.mailToTask save_calendar plugin.preferPlain attachment-reminder email-custom-header
        do
            gsettingsadd org.gnome.evolution disabled-eplugins "org.gnome.evolution.$plugin"
        done

        gsettingsadd org.gnome.evolution disabled-eplugins 'org.gnome.plugin.mailing-list.actions'
    fi

;;

### Chat =======================================================================

"work-chat")

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
        usercopy 'pidgin' --replace '.purple/prefs.xml'
    fi

;;


### ============================================================================
### ============================================================================
### ============================================================================

esac

