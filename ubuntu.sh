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

silentsudo 'Accepting EULA license' sh -c 'echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections'

## Adding PPA`s ----------------------------------------------------------------

ppaadd  'LibreOffice'               'libreoffice'
ppaadd  'Numix Project'             'numix'
ppaadd  'Elementary OS'             'elementary-os'             'daily'
ppaadd  'Paper theme'               'snwh'                      'pulp'

## Updating --------------------------------------------------------------------

appupdate
#appupgrade

## Install ---------------------------------------------------------------------

## Themes  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

appinstall 'Numix theme'            'numix-icon-theme-circle numix-gtk-theme'
appinstall 'Breeze theme'           'breeze-cursor-theme breeze-icon-theme'
appinstall 'Oxygen cursors'         'oxygen-cursor-theme oxygen-cursor-theme-extra'
appinstall 'Elementary theme'       'elementary-icon-theme elementary-theme elementary-wallpapers'
appinstall 'Paper theme'            'paper-gtk-theme paper-icon-theme'
debinstall 'Arc theme'              'arc-theme' "${ROOT_PATH}/files/arc/arc-theme_1465131682.3095952_all.deb"

## Fonts - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

#appinstall 'Droid fonts'            'fonts-droid-fallback'
appinstall 'MS TTF core fonts'      'ttf-mscorefonts-installer'
appinstall 'Noto fonts'             'fonts-noto'

## Internet  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

appinstall 'Chromium'               'chromium-browser chromium-browser-l10n'

### VCS  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

appinstall 'VCS'                    'git subversion'

if ispkginstalled nautilus
then
    appinstall 'RabbitVCS'          'rabbitvcs-core rabbitvcs-nautilus'
fi

## Other - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

appinstall 'Restricted extras'		'ubuntu-restricted-extras'
appinstall '7-zip'                  'p7zip-rar p7zip-full'
appinstall 'ibus-gtk'               'ibus-gtk'

## Remove unused ---------------------------------------------------------------

silentsudo 'Removing unused packages' apt-get autoremove --yes --force-yes --purge

### System =====================================================================

fixpermissions '/media/documents'
fixpermissions '/media/windows'

### Customization ==============================================================

title 'Customization'

## Icon theme ------------------------------------------------------------------

icon_theme='Numix-Circle'

gsettings set org.gnome.desktop.interface icon-theme "${icon_theme}"

## Cursor theme ----------------------------------------------------------------

cursor_theme='breeze_cursors'

gsettings set org.gnome.desktop.interface cursor-theme "${cursor_theme}"
silentsudo '' update-alternatives --set x-cursor-theme "/etc/X11/cursors/${cursor_theme}.theme"

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

## Finalization ================================================================

nautilus -q
setsid unity &

