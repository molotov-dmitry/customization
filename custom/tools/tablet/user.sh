#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

sudo echo -n

clear
clear

### Customization ==============================================================

title 'Customization'

## Icon theme ------------------------------------------------------------------

icon_theme='Numix-Circle'

gsettings set org.gnome.desktop.interface icon-theme "${icon_theme}"

## Cursor theme ----------------------------------------------------------------

cursor_theme='breeze_cursors'

gsettings set org.gnome.desktop.interface cursor-theme "${cursor_theme}"

## Gtk theme -------------------------------------------------------------------

if [[ "$(desktoptype)" == 'GNOME' ]]
then
    theme_name='Paper'
    #theme_name='Arc'
else
    theme_name='Numix'
fi

if [[ -z "${theme_name}" ]]
then
    msgfail '[Theme name not set]'
    exit 1
fi

gsettings set org.gnome.desktop.interface gtk-theme     "${theme_name}"
gsettings set org.gnome.desktop.wm.preferences theme    "${theme_name}"

## Fonts -----------------------------------------------------------------------

gsettings set org.gnome.desktop.interface font-name             'Ubuntu 10'
gsettings set org.gnome.desktop.interface document-font-name    'Noto Serif 10'
gsettings set org.gnome.desktop.interface monospace-font-name   'Ubuntu Mono 11'
gsettings set org.gnome.desktop.wm.preferences titlebar-font    'Ubuntu 10'

## Wallpaper -------------------------------------------------------------------

#gsettings set org.gnome.desktop.background show-desktop-icons false
gsettings set org.gnome.desktop.background picture-uri 'file:///usr/share/backgrounds/168.jpg'

## Launcher applications -------------------------------------------------------

launcherclear
launcheradd 'nautilus'
launcheradd 'firefox'
launcheradd 'chromium-browser'
launcheradd 'gnome-terminal'

## Keyboard --------------------------------------------------------------------

gsettings set org.gnome.desktop.wm.keybindings switch-input-source          "['<Shift>Alt_L']"
gsettings set org.gnome.desktop.wm.keybindings switch-input-source-backward "['<Primary><Shift>Alt_L']"

### Application customization ==================================================

## gedit -----------------------------------------------------------------------

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

## gnome-terminal --------------------------------------------------------------

term_profile=$(gsettings get org.gnome.Terminal.ProfilesList default | cut -d "'" -f 2)

gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${term_profile}/" use-transparent-background true
gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${term_profile}/" background-transparency-percent 5

## LibreOffice -----------------------------------------------------------------

mkdir -p "${HOME}/.config/libreoffice/4/user/config/soffice.cfg/modules/swriter/toolbar"
cp -f "${ROOT_PATH}/files/libreoffice/writer/standardbar.xml" "${HOME}/.config/libreoffice/4/user/config/soffice.cfg/modules/swriter/toolbar/"
cp -f "${ROOT_PATH}/files/libreoffice/writer/textobjectbar.xml" "${HOME}/.config/libreoffice/4/user/config/soffice.cfg/modules/swriter/toolbar/"

mkdir -p "${HOME}/.config/libreoffice/4/user/config/soffice.cfg/modules/scalc/toolbar"
cp -f "${ROOT_PATH}/files/libreoffice/calc/standardbar.xml" "${HOME}/.config/libreoffice/4/user/config/soffice.cfg/modules/scalc/toolbar/"
cp -f "${ROOT_PATH}/files/libreoffice/calc/formatobjectbar.xml" "${HOME}/.config/libreoffice/4/user/config/soffice.cfg/modules/scalc/toolbar/"

## -----------------------------------------------------------------------------

msgdone
