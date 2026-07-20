#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

## Set any user as work account ================================================

mkdir -p "${HOME}/.config"
touch    "${HOME}/.config/is-work-account"

### Add network switch =========================================================

if ispkginstalled network-switch
then
    nettype=eth

    mkdir -p "${HOME}/.config/autostart"

    cat > "${HOME}/.config/autostart/network-switch.desktop" << _EOF
[Desktop Entry]
Version=1.0
Name=Network switcher
Comment=Network switcher
Exec=network-switch ${nettype}
Terminal=false
Type=Application
Categories=Network
_EOF

    unset nettype
fi

## Clear launcher ==============================================================

launcherclear

##

if [[ -f "${HOME}/.config/is-work-account" ]]
then

## Disable first configuration =============================================

if [[ -f /usr/libexec/gnome-initial-setup ]]
then
    echo -n 'yes' > "${HOME}/.config/gnome-initial-setup-done"
fi

## User network configuration ==============================================

## Network switcher hotkey -------------------------------------------------

if ispkginstalled network-switch
then
    addkeybinding 'Switch network' 'network-switch' '<Ctrl><Alt>N'
fi

## Customization ===========================================================

## Generate SSH private and public key pair --------------------------------

if [[ ! -f "${HOME}/.ssh/id_rsa" ]]
then
    ssh-keygen -q -t rsa -N '' -f "${HOME}/.ssh/id_rsa" 2>/dev/null <<< y >/dev/null
fi

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

## =========================================================================

fi

## Enable Pomodoro extensions ==============================================

if ispkginstalled gnome-shell && isgnomeshellextensioninstalled 'pomodoro@arun.codito.in'
then
    gsettingsadd org.gnome.shell enabled-extensions 'pomodoro@arun.codito.in'
fi

## Disable suspend and screen off timeout ==================================

if ispkginstalled gnome-shell
then
    gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
    gsettings set org.gnome.desktop.session               idle-delay             0
fi

### Mail =======================================================================

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

### Chat =======================================================================

if ispkginstalled pidgin
then
    usercopy 'pidgin' --replace '.purple/prefs.xml'
fi
