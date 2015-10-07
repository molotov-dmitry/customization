#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

sudo echo -n

clear
clear

### Test internet connection ===================================================

title 'testing internet connection'

if conntest
then
    msgdone
else
    msgfail
    exit 1
fi

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
appremove 'Fcitx'                   'fcitx fcitx-bin fcitx-config-common fcitx-data fcitx-modules fcitx-frontend-all'
appremove 'Orca screen reader'      'gnome-orca'
appremove 'X Diagnostic utility'    'xdiagnose'
appremove 'Backup utility'          'deja-dup'
appremove 'Help'                    'yelp yelp-xsl gnome-user-guide ubuntu-docs'
appremove 'Font viewer'             'gnome-font-viewer'
appremove 'Symbols table'           'gucharmap'
appremove 'xterm'                   'xterm'
appremove 'Landscape'               'landscape-client-ui-install'
#appremove 'Firefox'                 'firefox'
appremove 'Evolution'               'evolution evolution-common evolution-plugins'
appremove 'Dconf editor'            'dconf-editor'
appremove 'Empathy'                 'empathy empathy-common'
appremove 'Web camera'              'cheese'
appremove 'Gnome applications'      'gnome-contacts gnome-weather gnome-documents gnome-maps'
appremove 'Transmission'            'transmission-common transmission-gtk'

### Enabling 'universe' and 'multiverse' package sources -----------------------

silentsudo 'Enabling universe source' add-apt-repository universe
silentsudo 'Enabling multiverse source' add-apt-repository multiverse

## Adding PPA`s ----------------------------------------------------------------

ppaadd  'Numix Project'             'numix'
ppaadd  'LibreOffice'               'libreoffice'
ppaadd  'Elementary OS'             'elementary-os'             'daily'
ppaadd  'Azure theme'               'noobslab'                  'themes'

## Updating --------------------------------------------------------------------

appupdate
#appupgrade

## Install ---------------------------------------------------------------------

#appinstall 'Chromium'               'chromium-browser chromium-browser-l10n'

appinstall 'VCS'                    'git subversion'

if ispkginstalled nautilus
then
    appinstall 'RabbitVCS'          'rabbitvcs-core rabbitvcs-nautilus'
fi

appinstall 'Numix theme'            'numix-icon-theme-circle numix-gtk-theme numix-plymouth-theme'
appinstall 'Azure theme'            'azure-gtk-theme'
appinstall 'Oxygen cursors'         'oxygen-cursor-theme oxygen-cursor-theme-extra'
appinstall 'Libreoffice icons'      'libreoffice-style-sifr'
appinstall 'Elementary theme'       'elementary-icon-theme elementary-theme elementary-wallpapers'

appinstall 'ibus-gtk'               'ibus-gtk'

appinstall 'Droid fonts'            'fonts-droid'

### System =====================================================================

silentsudo 'Fixing ntfs permissions' sed -i "s/umask=[0-9]\{3\}/umask=000,uid=$(id -u ${USER})/" /etc/fstab

### Customization ==============================================================

title 'Customization'

## Icon theme ------------------------------------------------------------------

icon_theme='Numix-Circle'
#icon_theme='Numix-Circle-Light'

gsettings set org.gnome.desktop.interface icon-theme "${icon_theme}"

## Cursor theme ----------------------------------------------------------------

cursor_theme='oxy-white'

gsettings set org.gnome.desktop.interface cursor-theme "${cursor_theme}"
silentsudo '' update-alternatives --set x-cursor-theme "/etc/X11/cursors/${cursor_theme}.theme"

## Gtk theme -------------------------------------------------------------------

theme_name='Numix'
#theme_name='Azure'

gsettings set org.gnome.desktop.interface gtk-theme "${theme_name}"
gsettings set org.gnome.desktop.wm.preferences theme "${theme_name}"

## Fonts -----------------------------------------------------------------------

gsettings set org.gnome.desktop.interface font-name 'Droid Sans 10'
gsettings set org.gnome.desktop.interface document-font-name 'Droid Serif 10'
gsettings set org.gnome.desktop.interface monospace-font-name 'Ubuntu Mono 11'
gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Droid Sans 10'

## Wallpaper -------------------------------------------------------------------

#gsettings set org.gnome.desktop.background show-desktop-icons false
gsettings set org.gnome.desktop.background picture-uri 'file:///usr/share/backgrounds/168.jpg'

## Launcher applications -------------------------------------------------------

launcherclear
launcheradd 'nautilus'
launcheradd 'firefox'
#launcheradd 'chromium-browser'
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

gsettings set org.gnome.gedit.plugins active-plugins "['changecase', 'filebrowser', 'time', 'zeitgeistplugin', 'docinfo']"

## gnome-terminal --------------------------------------------------------------

term_profile=$(gsettings get org.gnome.Terminal.ProfilesList default | cut -d "'" -f 2)

gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${term_profile}/" use-transparent-background true 
gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${term_profile}/" background-transparency-percent 5

## -----------------------------------------------------------------------------

msgdone

## Finalization ================================================================

nautilus -q
setsid unity &

