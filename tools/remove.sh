#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

### Applications ===============================================================

## Kernel ----------------------------------------------------------------------

appremove 'OEM kernel headers'      'linux-headers-oem linux-headers-4.15.0-1050-oem linux-oem-headers-4.15.0-1050'

## Package management ----------------------------------------------------------

appremove 'Apt listchanges'         'apt-listchanges'
appremove 'Unattended upgrades'     'unattended-upgrades'
appremove 'Aptitude'                'aptitude aptitude-common'
appremove 'Partner packages'        'app-install-data-partner'


## Office ----------------------------------------------------------------------

appremove 'Brasero'                 'brasero brasero-cdrkit brasero-common'
appremove 'K3b'                     'k3b k3b-data'
appremove 'Scanning Utilities'      'simple-scan skanlite'
appremove 'LibreOffice unused apps' 'libreoffice-draw libreoffice-impress libreoffice-math'
appremove 'KDE PIM'                 'kmail kontact korganizer ktnef kaddressbook knotes'
appremove 'Goldendict'              'goldendict'
appremove 'Tomboy'                  'tomboy'

## Network ---------------------------------------------------------------------

appremove 'Firefox'                 'firefox firefox-esr xul-ext-ubufox xul-ext-unity xul-ext-webaccounts xul-ext-websites-integration'
appremove 'Unity web browser'       'webbrowser-app'
appremove 'Thunderbird mail client' 'thunderbird'
appremove 'Evolution mail client'   'evolution evolution-common'
appremove 'Remote desktop client'   'remmina remmina-common remmina-plugin-rdp remmina-plugin-vnc'
appremove 'Ubuntu web launchers'    'ubuntu-web-launchers'
appremove 'Transmission'            'transmission-common transmission-gtk'
appremove 'KTorrent'                'ktorrent ktorrent-data'
appremove 'HexChat'                 'hexchat hexchat-common'
appremove 'Akregator'               'akregator'
appremove 'Konversation IRC client' 'konversation konversation-data'

## Accesibility and parental control -------------------------------------------

appremove 'Onboard'                 'onboard'
appremove 'Orca screen reader'      'orca gnome-orca'
appremove 'Parental control'        'malcontent'
appremove 'Braille display'         'brltty'

## System ----------------------------------------------------------------------

appremove 'X Diagnostic utility'    'xdiagnose'
appremove 'Backup utility'          'deja-dup'
appremove 'Ubuntu telemetry'        'ubuntu-report'
appremove 'AppArmor'                'apparmor apparmor-utils'
appremove 'Apport'                  'apport apport-gtk'
appremove 'Symbols table'           'gucharmap'
appremove 'Terminals'               'xterm xiterm+thai mlterm mlterm-common mlterm-tools'
appremove 'Dconf editor'            'dconf-editor'
appremove 'Landscape'               'landscape-client-ui-install'
appremove 'USB image writer'        'usb-creator-common usb-creator-gtk usb-creator-kde'
appremove 'BTRFS tools'             'btrfs-progs'
appremove 'Password checker'        'cracklib-runtime'
appremove 'Speech synthesizer'      'espeak-ng-data libespeak-ng1 speech-dispatcher-espeak-ng'

## Help ------------------------------------------------------------------------

appremove 'Help'                    'yelp yelp-xsl gnome-user-guide ubuntu-docs'
appremove 'Debian references'       'debian-reference-common'

## Games -----------------------------------------------------------------------

appremove 'Games'                   'gnome-2048 gnome-mines gnome-sudoku gnome-mahjongg aisleriot gnome-klotski gnome-chess five-or-more four-in-a-row gnome-nibbles hitori iagno lightsoff quadrapassel gnome-robots swell-foop tali gnome-taquin gnome-tetravex kpat ksudoku kmahjongg kmines'

## Multimedia ------------------------------------------------------------------

appremove 'Rhythmbox'               'rhythmbox rhythmbox-data'
appremove 'Gnome Music'             'gnome-music'
appremove 'Totem'                   'totem totem-common'
appremove 'VLC'                     'vlc vlc-bin vlc-data'
appremove 'Cantata music player'    'cantata'
appremove 'Elisa music player'      'elisa'
appremove 'MPD'                     'mpd'
appremove 'Shotwell'                'shotwell shotwell-common'
appremove 'Cheese'                  'cheese'

## Gnome apps ------------------------------------------------------------------

appremove 'Gnome Apps'              'gnome-sound-recorder gnome-todo gnome-weather gnome-maps gnome-contacts eog gnome-font-viewer gnome-documents'
appremove 'Gnome desktop icons'     'gnome-shell-extension-desktop-icons gnome-shell-extension-desktop-icons-ng'
appremove 'Font viewer'             ''

## Localization and fonts ------------------------------------------------------

appremove 'Fonts'                   'fonts-beng fonts-beng-extra fonts-lohit-beng-assamese fonts-lohit-beng-bengali fonts-deva fonts-gargi fonts-lohit-deva fonts-nakula fonts-sahadeva fonts-samyak-deva fonts-gujr fonts-gujr-extra fonts-kalapi fonts-lohit-gujr fonts-samyak-gujr fonts-guru fonts-guru-extra fonts-lohit-guru fonts-knda fonts-gubbi fonts-lohit-knda fonts-navilu fonts-mlym fonts-lohit-mlym fonts-samyak-mlym fonts-smc fonts-orya fonts-lohit-orya fonts-orya-extra fonts-taml fonts-lohit-taml fonts-samyak-taml fonts-lohit-taml-classical fonts-telu fonts-lohit-telu fonts-lohit-telu fonts-pagul fonts-indic fonts-kacst fonts-kacst-one fonts-khmeros-core fonts-lao fonts-lklug-sinhala fonts-noto-cjk fonts-noto-cjk-extra fonts-noto-unhinted fonts-sil-abyssinica fonts-sil-padauk fonts-tibetan-machine fonts-thai-tlwg fonts-tlwg-garuda fonts-tlwg-garuda-ttf fonts-tlwg-kinnari fonts-tlwg-kinnari-ttf fonts-tlwg-laksaman fonts-tlwg-laksaman-ttf fonts-tlwg-loma fonts-tlwg-loma-ttf fonts-tlwg-mono fonts-tlwg-mono-ttf fonts-tlwg-norasi fonts-tlwg-norasi-ttf fonts-tlwg-purisa fonts-tlwg-purisa-ttf fonts-tlwg-sawasdee fonts-tlwg-sawasdee-ttf fonts-tlwg-typewriter fonts-tlwg-typewriter-ttf fonts-tlwg-typist fonts-tlwg-typist-ttf fonts-tlwg-typo fonts-tlwg-typo-ttf fonts-tlwg-umpush fonts-tlwg-umpush-ttf fonts-tlwg-waree fonts-tlwg-waree-ttf fonts-droid-fallback fonts-linuxlibertine fonts-freefont-ttf fonts-liberation2 fonts-arphic-ukai fonts-arphic-uming'
appremove 'Language packs'          'language-pack-zh-hans-base language-pack-zh-hans language-pack-pt-base language-pack-pt language-pack-it-base language-pack-it language-pack-gnome-zh-hans-base language-pack-gnome-zh-hans language-pack-gnome-pt-base language-pack-gnome-pt language-pack-gnome-it-base language-pack-gnome-it language-pack-gnome-fr-base language-pack-gnome-fr language-pack-gnome-es-base language-pack-gnome-es language-pack-gnome-de-base language-pack-gnome-de language-pack-fr-base language-pack-fr language-pack-es-base language-pack-es language-pack-de-base language-pack-de wfrench wbrazilian wngerman wogerman wportuguese wspanish wswiss witalian firefox-locale-de firefox-locale-es firefox-locale-fr firefox-locale-it firefox-locale-pt firefox-locale-zh-hans libreoffice-l10n-zh-tw libreoffice-l10n-zh-cn libreoffice-l10n-pt-br libreoffice-l10n-pt libreoffice-l10n-it libreoffice-l10n-fr libreoffice-l10n-es libreoffice-l10n-en-za libreoffice-l10n-de libreoffice-help-zh-tw libreoffice-help-zh-cn libreoffice-help-pt-br libreoffice-help-pt libreoffice-help-it libreoffice-help-fr libreoffice-help-es libreoffice-help-de hunspell-de-at-frami hunspell-de-ch-frami hunspell-de-de-frami hunspell-en-au hunspell-en-ca hunspell-en-za hunspell-es hunspell-fr hunspell-fr-classical hunspell-it hunspell-pt-br hunspell-pt-pt hyphen-de hyphen-en-ca hyphen-es hyphen-fr hyphen-it hyphen-pt-br hyphen-pt-pt mythes-de mythes-de-ch mythes-en-au mythes-es mythes-fr mythes-it mythes-pt-pt'
appremove 'Khmer converter'         'khmerconverter'
appremove 'Hebrew calendar applet'  'hdate-applet'
appremove 'Input methods'           'fcitx5 fcitx5-data fcitx5-modules fcitx5-chewing fcitx5-chineese-addons fcitx fcitx-bin fcitx-config-common fcitx-data fcitx-modules fcitx-frontend-all fcitx-mozc fcitx-mozc-data fcitx5-mozc mozc-utils-gui mozc-data mozc-server ibus-mozc anthy anthy-common gtk-im-libthai'

## Unused applications ---------------------------------------------------------

silent 'Removing unused packages' apt autoremove --yes --force-yes --purge
