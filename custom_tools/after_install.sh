#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

sudo echo -n

clear
clear

### Applications ===============================================================
## Install ---------------------------------------------------------------------

debinstall 'Cifs utils' 'cifs-utils' "$(ls /tools/cifs-utils_*.deb)"

### Fix permissions ============================================================

fixpermissions '/media/documents'

### Add smaba shares to fstab ==================================================

title 'Adding cifs shares'
silentsudo '' sed -i '/[ \t]cifs[ \t]/d' /etc/fstab

sudo sh -c "echo >> /etc/fstab"
sudo sh -c "echo '//172.16.8.91/usr /media/dima cifs guest,uid=1000,forceuid,gid=1000,forcegid,file_mode=0775,dir_mode=0775,iocharset=utf8 0 0' >> /etc/fstab"
sudo sh -c "echo '//172.16.8.91/share2 /media/cub cifs guest,uid=1000,forceuid,gid=1000,forcegid,file_mode=0775,dir_mode=0775,iocharset=utf8 0 0' >> /etc/fstab"

msgdone

### Customization ==============================================================

title 'Customization'

## Icon theme ------------------------------------------------------------------

icon_theme='Numix-Circle'

gsettings set org.gnome.desktop.interface icon-theme "${icon_theme}"

## Cursor theme ----------------------------------------------------------------

#cursor_theme='oxy-white'
cursor_theme='breeze_cursors'

gsettings set org.gnome.desktop.interface cursor-theme "${cursor_theme}"
silentsudo '' update-alternatives --set x-cursor-theme "/etc/X11/cursors/${cursor_theme}.theme"

## Gtk theme -------------------------------------------------------------------

theme_name='Numix'

gsettings set org.gnome.desktop.interface gtk-theme "${theme_name}"
gsettings set org.gnome.desktop.wm.preferences theme "${theme_name}"

## Fonts -----------------------------------------------------------------------

gsettings set org.gnome.desktop.interface font-name 'Droid Sans 10'
gsettings set org.gnome.desktop.interface document-font-name 'Droid Serif 10'
gsettings set org.gnome.desktop.interface monospace-font-name 'Ubuntu Mono 11'
gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Droid Sans 10'

## Wallpaper -------------------------------------------------------------------

#gsettings set org.gnome.desktop.background show-desktop-icons false
#gsettings set org.gnome.desktop.background picture-uri 'file:///usr/share/backgrounds/168.jpg'
gsettings set org.gnome.desktop.background primary-color '#20204a4a8787'
gsettings set org.gnome.desktop.background picture-options 'none'
gsettings set org.gnome.desktop.background picture-uri ''

## Launcher applications -------------------------------------------------------

launcherclear
launcheradd 'nautilus'
launcheradd 'firefox'
#launcheradd 'chromium-browser'
launcheradd 'qtcreator'
launcheradd 'anjuta'
launcheradd 'gnome-terminal'

## Keyboard --------------------------------------------------------------------

gsettings set org.gnome.desktop.wm.keybindings switch-input-source "['<Shift>Alt_L']"
gsettings set org.gnome.desktop.wm.keybindings switch-input-source-backward "['<Primary><Shift>Alt_L']"

### Application customization ==================================================

## gedit -----------------------------------------------------------------------

gsettings set org.gnome.gedit.preferences.editor use-default-font       true

gsettings set org.gnome.gedit.preferences.editor display-line-numbers   true
gsettings set org.gnome.gedit.preferences.editor highlight-current-line true

gsettings set org.gnome.gedit.preferences.editor insert-spaces          true
gsettings set org.gnome.gedit.preferences.editor tabs-size              4

gsettings set org.gnome.gedit.preferences.editor display-right-margin   true
gsettings set org.gnome.gedit.preferences.editor right-margin-position  80

gsettings set org.gnome.gedit.preferences.editor syntax-highlighting    true

gsettings set org.gnome.gedit.preferences.editor scheme                 'kate'

gsettings set org.gnome.gedit.preferences.editor wrap-mode              'none'

gsettings set org.gnome.gedit.plugins active-plugins "['changecase', 'filebrowser', 'time', 'zeitgeistplugin', 'docinfo']"

## gnome-terminal --------------------------------------------------------------

term_profile=$(gsettings get org.gnome.Terminal.ProfilesList default | cut -d "'" -f 2)

gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${term_profile}/" use-transparent-background true 
gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${term_profile}/" background-transparency-percent 5

## astyle local ----------------------------------------------------------------

silent '' rm -f "${HOME}/.astylerc"
silent '' touch "${HOME}/.astylerc"

echo '--style=allman' >> "${HOME}/.astylerc"
echo '--indent=spaces=4' >> "${HOME}/.astylerc"
echo '--indent-namespaces' >> "${HOME}/.astylerc"
echo '--indent-preproc-define' >> "${HOME}/.astylerc"
echo '--indent-col1-comments' >> "${HOME}/.astylerc"
echo '#--break-blocks' >> "${HOME}/.astylerc"
echo '--unpad-paren' >> "${HOME}/.astylerc"
echo '--pad-header' >> "${HOME}/.astylerc"
echo '--pad-oper' >> "${HOME}/.astylerc"
echo '#--delete-empty-lines' >> "${HOME}/.astylerc"
echo '--align-pointer=type' >> "${HOME}/.astylerc"
echo '--align-reference=type' >> "${HOME}/.astylerc"
echo '--convert-tabs' >> "${HOME}/.astylerc"
echo '--close-templates' >> "${HOME}/.astylerc"
echo '--max-code-length=80' >> "${HOME}/.astylerc"
echo '--break-after-logical' >> "${HOME}/.astylerc"

## -----------------------------------------------------------------------------

## -----------------------------------------------------------------------------

msgdone

## Finalization ================================================================

nautilus -q
setsid unity &

