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

;;

### Base GUI ===================================================================

"gui")

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

    ## Keyboard ================================================================

    gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('xkb', 'ru')]"

    gsettings set org.gnome.desktop.wm.keybindings switch-input-source "['<Shift>Alt_L', '<Alt>Shift_L', '<Super>space']"
    gsettings set org.gnome.desktop.wm.keybindings switch-input-source-backward "['<Primary><Shift>Alt_L', '<Primary><Alt>Shift_L', '<Shift><Super>space', '<Primary><Super>space']"

    gsettings set org.gnome.desktop.wm.keybindings show-desktop "['<Super>d']"

    addkeybinding 'System Monitor' 'gnome-system-monitor' '<Ctrl><Shift>Escape'

    if gsettings writable org.gnome.settings-daemon.plugins.media-keys home 1>/dev/null 2>/dev/null
    then
        gsettings set org.gnome.settings-daemon.plugins.media-keys home "['<Super>e']"
        addkeybinding 'File Manager'   'nautilus -w'                    '<Ctrl><Super>E'
    else
        addkeybinding 'File Manager'   'nautilus -w'                    '<Super>E'
    fi

    if ! gsettings writable org.gnome.settings-daemon.plugins.media-keys terminal 1>/dev/null 2>/dev/null
    then
        addkeybinding 'Terminal'        'x-terminal-emulator'           '<Ctrl><Alt>T'
    fi

    ## File manager keybindings ================================================

    addscenario 'terminal' 'F4' 'x-terminal-emulator &' --fixpwd
    addscenario 'compress' 'F7' '[[ $# -gt 0 ]] && file-roller -d "$@" &'

    ## gnome-terminal ==========================================================

    if ispkginstalled gnome-terminal
    then
        term_profile=$(gsettings get org.gnome.Terminal.ProfilesList default | cut -d "'" -f 2)
        term_profile_path="org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${term_profile}/"

        gsettings set "${term_profile_path}" visible-name 'UTF-8'
        gsettings set "${term_profile_path}" scrollbar-policy 'always'

        gsettings set "${term_profile_path}" palette "['rgb(23,20,33)', 'rgb(192,28,40)', 'rgb(38,162,105)', 'rgb(162,115,76)', 'rgb(18,72,139)', 'rgb(163,71,186)', 'rgb(42,161,179)', 'rgb(208,207,204)', 'rgb(94,92,100)', 'rgb(246,97,81)', 'rgb(51,209,122)', 'rgb(233,173,12)', 'rgb(42,123,222)', 'rgb(192,97,203)', 'rgb(51,199,222)', 'rgb(255,255,255)']"

        if gsettings writable "${term_profile_path}" use-transparent-background 1>/dev/null 2>/dev/null
        then
            gsettings set "${term_profile_path}" use-transparent-background true
            gsettings set "${term_profile_path}" background-transparency-percent 5
        fi
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

    ## Crerate utilities launcher group ========================================

    if ispkginstalled gnome-shell
    then
        # Utilities ------------------------------------------------------------

        gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/Utils/ name 'System-Tools.directory'
        gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/Utils/ translate true

        for app in Characters FileRoller DiskUtility Devhelp Screenshot baobab seahorse.Application Software tweaks Extensions Logs
        do
            gsettingsadd org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/Utils/ apps "org.gnome.${app}.desktop"
        done

        for app in htop btop update-manager usb-creator-gtk gnome-system-monitor ubiquity gnome-nettool yelp nm-connection-editor sqlitebrowser
        do
            gsettingsadd org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/Utils/ apps "${app}.desktop"
        done

        gsettingsadd org.gnome.desktop.app-folders folder-children 'Utils'

        # Media ----------------------------------------------------------------

        gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/Office/ name 'Office.directory'
        gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/Office/ translate true

        for app in eog Evince Builder
        do
            gsettingsadd org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/Office/ apps "org.gnome.${app}.desktop"
        done

        for app in com.github.fabiocolacio.marker gimp
        do
            gsettingsadd org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/Office/ apps "${app}.desktop"
        done

        for app in startcenter writer calc impress base math
        do
            gsettingsadd org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/Office/ apps "libreoffice-${app}.desktop"
        done

        gsettingsadd org.gnome.desktop.app-folders folder-children 'Office'

    fi

    ## Gnome shell extensions ==================================================

    if ispkginstalled gnome-shell
    then
        ## Enable app indicators -----------------------------------------------

        if isgnomeshellextensioninstalled 'ubuntu-appindicators@ubuntu.com'
        then
            gsettingsadd org.gnome.shell enabled-extensions 'ubuntu-appindicators@ubuntu.com'
        fi

        ## Remove accessibility icon -------------------------------------------

        if isgnomeshellextensioninstalled 'removeaccesibility@lomegor'
        then
            gsettingsadd org.gnome.shell enabled-extensions 'removeaccesibility@lomegor'
        fi

        ## Bring Out Submenu Of Power Off/Logout Button ------------------------

        if isgnomeshellextensioninstalled 'BringOutSubmenuOfPowerOffLogoutButton@pratap.fastmail.fm'
        then
            dconf write /org/gnome/shell/extensions/brngout/remove-suspend-button true

            gsettingsadd org.gnome.shell enabled-extensions 'BringOutSubmenuOfPowerOffLogoutButton@pratap.fastmail.fm'
        fi

        ## Removable Drive Menu ------------------------------------------------

        if isgnomeshellextensioninstalled 'drive-menu@gnome-shell-extensions.gcampax.github.com'
        then
            gsettingsadd org.gnome.shell enabled-extensions 'drive-menu@gnome-shell-extensions.gcampax.github.com'
        fi

        ## Dash to dock --------------------------------------------------------

        dconf write /org/gnome/shell/extensions/dash-to-dock/apply-custom-theme true

        dconf write /org/gnome/shell/extensions/dash-to-dock/show-trash         false
        dconf write /org/gnome/shell/extensions/dash-to-dock/show-mounts        false

        dconf write /org/gnome/shell/extensions/dash-to-dock/dock-position      "'LEFT'"
        dconf write /org/gnome/shell/extensions/dash-to-dock/extend-height      true
        dconf write /org/gnome/shell/extensions/dash-to-dock/dock-fixed         true

        dconf write /org/gnome/shell/extensions/dash-to-dock/animation-time     0.0

        dconf write /org/gnome/shell/extensions/dash-to-dock/custom-theme-shrink true

        if isgnomeshellextensioninstalled 'dash-to-dock@micxgx.gmail.com'
        then
            gsettingsadd org.gnome.shell enabled-extensions 'dash-to-dock@micxgx.gmail.com'

        elif isgnomeshellextensioninstalled 'ubuntu-dock@ubuntu.com'
        then
            gsettingsadd org.gnome.shell enabled-extensions 'ubuntu-dock@ubuntu.com'
        fi
    fi

    ## =========================================================================

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
    bash "${scriptpath}" 'server/svn'
    bash "${scriptpath}" 'server/db'
    bash "${scriptpath}" 'server/iperf'
    bash "${scriptpath}" 'server/media'
    bash "${scriptpath}" 'server/download'

;;

### OpenSSH server =============================================================

"server/ssh")

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

### Qt SDK =====================================================================

"dev/qt")

    ## Qt Creator ==============================================================

    if ispkginstalled 'qtcreator'
    then

        ## launcher ------------------------------------------------------------

        launcheradd 'org.qt-project.qtcreator'

        ## Mime type -----------------------------------------------------------

        mimedefault 'org.qt-project.qtcreator' 'application'

        ## Qt Creator ----------------------------------------------------------

        addconfigline 'Projects' "${HOME}/Projects" 'Directories' "${HOME}/.config/QtProject/QtCreator.ini"

        ## Add Clangd folder to gitignore --------------------------------------

        if dpkg --compare-versions "$(pkgversion qtcreator)" ge 7
        then
            if ! grep -q ^.qtc_clangd$ .config/git/ignore 2>/dev/null
            then
                mkdir -p "${HOME}/.config/git"
                echo '.qtc_clangd' >> "${HOME}/.config/git/ignore"
            fi
        fi

        ## ---------------------------------------------------------------------

    fi

;;

### GTK SDK ====================================================================

"dev/gtk")

;;

### Gnome SDK ==================================================================

"dev/gnome")

    ## Hide Sysprof ============================================================

    hideapp 'org.gnome.Sysprof3'

    ## Gnome Builder ===========================================================

    if ispkginstalled gnome-builder
    then

        ## Register mimetypes --------------------------------------------------

        mimeregister 'text/plain'                'org.gnome.Builder.desktop'

        ## gnome builder -------------------------------------------------------

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

        for plugin in c-pack code-index codespell color-picker copyright_plugin ctags dspy gdiagnose gettext gjs_symbols glade gnome-code-assistance gvls_plugin jhbuild_plugin newcomers npm_plugin podman python_gi_imports_completion qemu rust-analyzer rustup_plugin vala_pack_plugin valgrind_plugin
        do
            gsettings set org.gnome.builder.plugin:/org/gnome/builder/plugins/${plugin}/ enabled false
        done
    fi

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

### Version control system =====================================================

"vcs")

    ## Meld --------------------------------------------------------------------

    if ispkginstalled 'meld'
    then
        addscenario 'compare' 'F3' '[[ $# -eq 0 ]] && ( svn info || git status ) && meld . &\n[[ $# -eq 1 && -d "$1" ]] && ( svn info "$1" || ( cd "$1" && git status ) ) && meld "$1" &\n[[ $# -eq 1 && ! -d "$1" ]] && ( svn info "$1" || ( cd "$(dirname "$1")" && git ls-files --error-unmatch "$(basename "$1")" ) ) && meld "$1" &\n[[ $# -gt 1 ]] && meld "$@" &'
    fi

    ## Gitg --------------------------------------------------------------------

    if ispkginstalled 'gitg'
    then
        addkeybinding 'Gitg' 'gitg' '<Ctrl><Alt>G'

        addscenario    'gitg'   '<Ctrl>G'  '[[ $# -eq 0 ]] && git status && test -n "$(git diff-index --name-only HEAD --)" && gitg --standalone --commit . &\n[[ $# -eq 0 ]] && git status && test -z "$(git diff-index --name-only HEAD --)" && gitg --standalone . &\n[[ $# -eq 1 ]] && ( cd "$1" && git status && test -n "$(git diff-index --name-only HEAD --)" ) && gitg --standalone --commit "$1" &\n[[ $# -eq 1 ]] && ( cd "$1" && git status && test -z "$(git diff-index --name-only HEAD --)" ) && gitg --standalone "$1" &'
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

;;

### Desktop theme ==============================================================

"appearance/themes")

    icon_theme='mPapirus'
    gtk_theme='Adwaita'
    wm_theme='Adwaita'

    if ispkginstalled gnome-shell
    then
        gsettings set org.gnome.desktop.interface icon-theme    "${icon_theme}"
        gsettings set org.gnome.desktop.interface gtk-theme     "${gtk_theme}"
        gsettings set org.gnome.desktop.wm.preferences theme    "${wm_theme}"
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
    font_table_size='10'

    if ispkginstalled gnome-shell
    then
        gsettings set org.gnome.desktop.interface font-name             "${font_ui} ${font_ui_size}"
        gsettings set org.gnome.desktop.interface document-font-name    "${font_doc} ${font_doc_size}"
        gsettings set org.gnome.desktop.interface monospace-font-name   "${font_fixed} ${font_fixed_size}"
        gsettings set org.gnome.desktop.wm.preferences titlebar-font    "${font_ui} ${font_ui_size}"
    fi

    if ispkginstalled gnome-builder
    then
        gsettings set org.gnome.builder.editor font-name    "${font_fixed} ${font_fixed_size}"
        gsettings set org.gnome.builder.terminal font-name  "${font_fixed} ${font_fixed_size}"
    fi

    unset font_ui
    unset font_doc
    unset font_fixed

    unset font_ui_size
    unset font_doc_size
    unset font_fixed_size
    unset font_table_size

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

    ## hide apps from application menu -----------------------------------------

    hideapp 'easytag'
    hideapp 'mpv'

    ## Eye of Gnome ------------------------------------------------------------

    if ispkginstalled eog
    then
        mimedefault 'org.gnome.eog' 'image'
    fi

    ## A simple MPRIS indicator button Gnome Shell extension -------------------

    if ispkginstalled gnome-shell && isgnomeshellextensioninstalled 'mprisindicatorbutton@JasonLG1979.github.io'
    then
        gsettingsadd org.gnome.shell enabled-extensions 'mprisindicatorbutton@JasonLG1979.github.io'
    fi

    ## Sound Input & Output Device Chooser Gnome Shell extension ---------------

    if ispkginstalled gnome-shell && isgnomeshellextensioninstalled 'sound-output-device-chooser@kgshank.net'
    then
        dconf write /org/gnome/shell/extensions/sound-output-device-chooser/hide-on-single-device   true
        dconf write /org/gnome/shell/extensions/sound-output-device-chooser/show-input-devices      false
        dconf write /org/gnome/shell/extensions/sound-output-device-chooser/show-profiles           false
        dconf write /org/gnome/shell/extensions/sound-output-device-chooser/show-output-devices     true
        dconf write /org/gnome/shell/extensions/sound-output-device-chooser/hide-menu-icons         false
        dconf write /org/gnome/shell/extensions/sound-output-device-chooser/icon-theme              "'monochrome'"
        dconf write /org/gnome/shell/extensions/sound-output-device-chooser/show-input-slider       false

        gsettingsadd org.gnome.shell enabled-extensions 'sound-output-device-chooser@kgshank.net'
    fi

    ## Caffeine ----------------------------------------------------------------

    if ispkginstalled gnome-shell && isgnomeshellextensioninstalled 'caffeine@patapon.info'
    then
        dconf write /org/gnome/shell/extensions/caffeine/show-indicator     false
        dconf write /org/gnome/shell/extensions/caffeine/show-notifications false

        gsettingsadd org.gnome.shell enabled-extensions 'caffeine@patapon.info'
    fi

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
    bash "${scriptpath}" 'network/remote'

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
        fi
    fi

;;

### Chat extra protocols =======================================================

"network/chat")

;;

### Remote clients =============================================================

"network/remote")

;;

### ============================================================================
### Graphic applications =======================================================
### ============================================================================

"graphics")

    if ispkginstalled gimp
    then
        mimedefault 'gimp' 'image'
    fi

    if ispkginstalled eog
    then
        mimedefault 'org.gnome.eog' 'image'
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

### ============================================================================
### Folders setup ==============================================================
### ============================================================================

"folders")

    user-folders

    addbookmark "file://${HOME}/Projects" 'Projects'

    for dir in 'Общедоступные' 'Шаблоны' 'Рабочий стол'
    do
        grep -qs "^${dir}$" "${HOME}/.hidden" || echo "$dir" >> "${HOME}/.hidden"
    done

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

    network-update

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

    printer-update

    ## Customization ===========================================================

    ## Generate SSH private and public key pair --------------------------------

    if [[ ! -f "${HOME}/.ssh/id_rsa" ]]
    then
        ssh-keygen -q -t rsa -N '' -f "${HOME}/.ssh/id_rsa" 2>/dev/null <<< y >/dev/null
    fi

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
        newprofilepath="org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${newprofileid}/"

        gsettings set "${newprofilepath}" visible-name 'KOI8-R'
        gsettings set "${newprofilepath}" encoding 'KOI8-R'
        gsettings set "${newprofilepath}" scrollbar-policy 'always'

        gsettings set "${newprofilepath}" palette "['rgb(23,20,33)', 'rgb(192,28,40)', 'rgb(38,162,105)', 'rgb(162,115,76)', 'rgb(18,72,139)', 'rgb(163,71,186)', 'rgb(42,161,179)', 'rgb(208,207,204)', 'rgb(94,92,100)', 'rgb(246,97,81)', 'rgb(51,209,122)', 'rgb(233,173,12)', 'rgb(42,123,222)', 'rgb(192,97,203)', 'rgb(51,199,222)', 'rgb(255,255,255)']"

        if gsettings writable "${newprofilepath}" use-transparent-background 1>/dev/null 2>/dev/null
        then
            gsettings set "${newprofilepath}" use-transparent-background true
            gsettings set "${newprofilepath}" background-transparency-percent 5
        fi

        gsettingsadd org.gnome.Terminal.ProfilesList list "${newprofileid}"
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

    ## =========================================================================

    fi

    ## Create bookmark to rczi user ============================================

    if [[ "${USER}" != 'rczi' && -n "$(cut -d ':' -f 1 /etc/passwd | grep '^rczi$')"  ]]
    then
        addbookmark 'sftp://rczi@localhost/home/rczi' 'rczi user'
    fi

    ## Disable suspend and screen off timeout ==================================

    if ispkginstalled gnome-shell
    then
        gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
        gsettings set org.gnome.desktop.session               idle-delay             0
    fi

    ## =========================================================================

;;

### Mail =======================================================================

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

