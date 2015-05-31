#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

sudo echo -n

clear
clear

### Applications ===============================================================

## Remove ----------------------------------------------------------------------

appremove 'Brasero'                 'brasero brasero-cdrkit brasero-common'

appremove 'Simple Scanning Utility' 'simple-scan'
appremove 'LibreOffice unused apps' 'libreoffice-draw libreoffice-impress libreoffice-math'
appremove 'Games'                   'gnome-mines gnome-sudoku gnome-mahjongg aisleriot'
appremove 'Firefox Extensions'      'xul-ext-ubufox xul-ext-unity xul-ext-webaccounts xul-ext-websites-integration'
appremove 'Remote desktop client'   'remmina remmina-common remmina-plugin-rdp remmina-plugin-vnc'
appremove 'Unity web browser'       'webbrowser-app'
appremove 'Thunderbird mail client' 'thunderbird'
appremove 'Onboard'                 'onboard'
appremove 'Orca screen reader'      'gnome-orca'
appremove 'X Diagnostic utility'    'xdiagnose'
appremove 'Backup utility'          'deja-dup'
appremove 'Help'                    'yelp yelp-xsl gnome-user-guide ubuntu-docs'
appremove 'Font viewer'             'gnome-font-viewer'
appremove 'Symbols table'           'gucharmap'
appremove 'xterm'                   'xterm'
appremove 'Landscape'               'landscape-client-ui-install'

#wacom
#firefox
#appremove 'Web camera' 'cheese cheese-common'

### Enabling 'universe' and 'multiverse' package sources -----------------------

silentsudo 'Enabling universe source' add-apt-repository universe
silentsudo 'Enabling multiverse source' add-apt-repository multiverse

## Adding PPA`s ----------------------------------------------------------------

ppaadd  'Numix Project'             'numix'
ppaadd  'LibreOffice'               'libreoffice'
ppaadd  'Elementary OS'             'elementary-os'             'daily'
ppaadd  'Azure theme'               'noobslab'                  'themes'
ppaadd  'Ubuntu Make'               'ubuntu-desktop'            'ubuntu-make'

## Updating --------------------------------------------------------------------

appupdate
appupgrade

## Install ---------------------------------------------------------------------

appinstall 'Chromium'               'chromium-browser chromium-browser-l10n'

appinstall 'Numix theme'            'numix-icon-theme-circle numix-icon-theme-bevel numix-gtk-theme numix-plymouth-theme'
appinstall 'Oxygen cursors'         'oxygen-cursor-theme oxygen-cursor-theme-extra'
appinstall 'Libreoffice icons'      'libreoffice-style-sifr'
appinstall 'Elementary theme'       'elementary-icon-theme elementary-theme elementary-wallpapers'

appinstall 'Open Terminal Here'     'nautilus-open-terminal'

appinstall 'Postgres'               'postgresql pgadmin3 libpq5 libpq-dev'
appinstall 'SQLite'                 'sqlite sqliteman libsqlite3-0 libsqlite3-dev'
appinstall 'Build tools'            'build-essential astyle'
appinstall 'Qt SDK'                 'qtcreator'
appinstall 'VCS'                    'git subversion'
appinstall 'RabbitVCS'              'rabbitvcs-core rabbitvcs-nautilus'

appinstall 'ibus-gtk'               'ibus-gtk'

appinstall 'Ubuntu Make'            'ubuntu-make'

debinstall 'Numix wallpaper'        'numix-wallpaper-notd' "${ROOT_PATH}/files/numix-wallpaper-notd.deb"

debinstall 'Azure GTK theme'        'azure-gtk-theme'
debinstall 'Flattice GTK theme'     'flattice-theme'

### System =====================================================================

silentsudo 'Fixing ntfs permissions' sed -i "s/umask=[0-9]\{3\}/umask=000,uid=$(id -u ${USER})/" /etc/fstab

### Customization ==============================================================

title 'Customization'

## Icon theme ------------------------------------------------------------------

icon_theme='Numix-Circle'
#icon_theme='Numix-Circle-Light'

gsettings set org.gnome.desktop.interface icon-theme "${icon_theme}"

## Cursor theme ----------------------------------------------------------------

#cursor_theme='oxy-white'
#cursor_theme='oxy-sea_blue'
cursor_theme='oxy-zion'

gsettings set org.gnome.desktop.interface cursor-theme "${cursor_theme}"
silentsudo '' update-alternatives --set x-cursor-theme "/etc/X11/cursors/${cursor_theme}.theme"

## Gtk theme -------------------------------------------------------------------

theme_name='Numix'
#theme_name='Azure'
#theme_name='Flattice'

gsettings set org.gnome.desktop.interface gtk-theme "${theme_name}"
gsettings set org.gnome.desktop.wm.preferences theme "${theme_name}"

## Fonts -----------------------------------------------------------------------

gsettings set org.gnome.desktop.interface font-name 'Droid Sans 10'
gsettings set org.gnome.desktop.interface document-font-name 'Droid Serif 10'
gsettings set org.gnome.desktop.interface monospace-font-name 'Droid Sans Mono 10'
gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Droid Sans 10'

## Wallpaper -------------------------------------------------------------------

gsettings set org.gnome.desktop.background picture-uri 'file:///usr/share/backgrounds/168.jpg'

## Border for unity launcher ---------------------------------------------------

silentsudo '' tar zxvf "${ROOT_PATH}/files/icons.tar.gz" -C /usr/share/unity

## Launcher applications -------------------------------------------------------

gsettings set com.canonical.Unity.Launcher favorites "['nautilus.desktop', 'chromium-browser.desktop', 'firefox.desktop', 'gnome-terminal.desktop', 'qtcreator.desktop']"

## Keyboard --------------------------------------------------------------------

gsettings set org.gnome.desktop.wm.keybindings switch-input-source "['<Shift>Alt_L']"
gsettings set org.gnome.desktop.wm.keybindings switch-input-source-backward "['<Primary><Shift>Alt_L']"

### Application customization ==================================================

## gedit -----------------------------------------------------------------------

gsettings set org.gnome.gedit.preferences.editor use-default-font       true

#gsettings set org.gnome.gedit.preferences.editor use-default-font       false
#gsettings set org.gnome.gedit.preferences.editor editor-font            'Droid Sans Mono 10'

gsettings set org.gnome.gedit.preferences.editor display-line-numbers   true
gsettings set org.gnome.gedit.preferences.editor highlight-current-line true

gsettings set org.gnome.gedit.preferences.editor insert-spaces          true
gsettings set org.gnome.gedit.preferences.editor tabs-size              4

gsettings set org.gnome.gedit.preferences.editor display-right-margin   true
gsettings set org.gnome.gedit.preferences.editor right-margin-position  80

gsettings set org.gnome.gedit.preferences.editor syntax-highlighting    true

gsettings set org.gnome.gedit.preferences.editor scheme                 'kate'

gsettings set org.gnome.gedit.plugins active-plugins "['changecase', 'filebrowser', 'time', 'zeitgeistplugin', 'docinfo']"

## gnome-terminal --------------------------------------------------------------

gconftool-2 --set '/apps/gnome-terminal/profiles/Default/background_type'       --type string   'transparent'
gconftool-2 --set '/apps/gnome-terminal/profiles/Default/background_darkness'   --type float    '0.95'

gconftool-2 --set '/apps/gnome-terminal/profiles/Default/use_system_font'       --type bool     'true'

#gconftool-2 --set '/apps/gnome-terminal/profiles/Default/use_system_font'       --type bool     'false'
#gconftool-2 --set '/apps/gnome-terminal/profiles/Default/font'                  --type string   'Droid Sans Mono 10'

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

msgdone

## Finalization ================================================================

nautilus -q
setsid unity &

