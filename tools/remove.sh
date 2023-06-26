#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

declare -a packages_to_remove

### Applications ===============================================================

## Kernel ----------------------------------------------------------------------

packages_to_remove+=('linux-headers-oem' 'linux-headers-4.15.0-1050-oem' 'linux-oem-headers-4.15.0-1050')
packages_to_remove+=('dkms')

## Firmware --------------------------------------------------------------------

packages_to_remove+=('raspi-firmware' 'firmware-netronome')

## Package management ----------------------------------------------------------

packages_to_remove+=('apt-listchanges')
packages_to_remove+=('unattended-upgrades')
packages_to_remove+=('aptitude' 'aptitude-common')
packages_to_remove+=('app-install-data-partner')
packages_to_remove+=('gnome-software gnome-software-common')
packages_to_remove+=('synaptic')

## Office ----------------------------------------------------------------------

packages_to_remove+=('brasero' 'brasero-cdrkit' 'brasero-common')
packages_to_remove+=('k3b' 'k3b-data')
packages_to_remove+=('simple-scan' 'skanlite')
packages_to_remove+=('libreoffice-draw' 'libreoffice-impress' 'libreoffice-math' 'libreoffice-help-common')
packages_to_remove+=('gimp-help-common')
packages_to_remove+=('kmail' 'kontact' 'korganizer' 'ktnef' 'kaddressbook' 'knotes')
packages_to_remove+=('goldendict')
packages_to_remove+=('tomboy')
packages_to_remove+=('printer-driver-brlaser' 'printer-driver-c2esp' 'printer-driver-m2300w' 'printer-driver-min12xxw' 'printer-driver-pnm2ppa' 'printer-driver-sag-gdi' 'printer-driver-splix')

## Network ---------------------------------------------------------------------

packages_to_remove+=('firefox' 'firefox-esr' 'xul-ext-ubufox' 'xul-ext-unity' 'xul-ext-webaccounts' 'xul-ext-websites-integration')
packages_to_remove+=('webbrowser-app')
packages_to_remove+=('thunderbird')
packages_to_remove+=('evolution' 'evolution-common')
packages_to_remove+=('remmina' 'remmina-common' 'remmina-plugin-rdp' 'remmina-plugin-vnc' 'krdc')
packages_to_remove+=('ubuntu-web-launchers')
packages_to_remove+=('transmission-common' 'transmission-gtk')
packages_to_remove+=('ktorrent' 'ktorrent-data')
packages_to_remove+=('hexchat' 'hexchat-common')
packages_to_remove+=('akregator')
packages_to_remove+=('konversation' 'konversation-data')
packages_to_remove+=('sugar-browse-activity')
packages_to_remove+=('kdeconnect')

## Accesibility and parental control -------------------------------------------

packages_to_remove+=('onboard')
packages_to_remove+=('orca' 'gnome-orca')
packages_to_remove+=('malcontent')
packages_to_remove+=('brltty')
packages_to_remove+=('gnome-accessibility-themes')

## System ----------------------------------------------------------------------

packages_to_remove+=('xdiagnose')
packages_to_remove+=('deja-dup')
packages_to_remove+=('ubuntu-report')
packages_to_remove+=('apparmor' 'apparmor-utils')
packages_to_remove+=('apport' 'apport-gtk')
packages_to_remove+=('gucharmap')
packages_to_remove+=('xterm' 'xiterm+thai' 'mlterm' 'mlterm-common' 'mlterm-tools')
packages_to_remove+=('dconf-editor')
packages_to_remove+=('landscape-client-ui-install')
packages_to_remove+=('usb-creator-common' 'usb-creator-gtk' 'usb-creator-kde')
packages_to_remove+=('btrfs-progs' 'reiserfsprogs')
packages_to_remove+=('cracklib-runtime')
packages_to_remove+=('espeak-ng-data' 'libespeak-ng1' 'speech-dispatcher-espeak-ng')
packages_to_remove+=('friendly-recovery')
packages_to_remove+=('plasma-systemmonitor')
packages_to_remove+=('libu2f-udev')
packages_to_remove+=('calamares')

## Help ------------------------------------------------------------------------

packages_to_remove+=('yelp' 'yelp-xsl' 'gnome-user-guide' 'ubuntu-docs')
packages_to_remove+=('debian-reference-common')

## Games -----------------------------------------------------------------------

packages_to_remove+=('gnome-2048' 'gnome-mines' 'gnome-sudoku' 'gnome-mahjongg' 'aisleriot' 'gnome-klotski' 'gnome-chess' 'five-or-more' 'four-in-a-row' 'gnome-nibbles' 'hitori' 'iagno' 'lightsoff' 'quadrapassel' 'gnome-robots' 'swell-foop' 'tali' 'gnome-taquin' 'gnome-tetravex' 'kpat' 'ksudoku' 'kmahjongg' 'kmines')
packages_to_remove+=('gamemode')

## Multimedia ------------------------------------------------------------------

packages_to_remove+=('rhythmbox' 'rhythmbox-data')
packages_to_remove+=('gnome-music')
packages_to_remove+=('totem' 'totem-common')
packages_to_remove+=('vlc' 'vlc-bin' 'vlc-data')
packages_to_remove+=('cantata')
packages_to_remove+=('elisa')
packages_to_remove+=('mpd')
packages_to_remove+=('shotwell' 'shotwell-common')
packages_to_remove+=('cheese')
packages_to_remove+=('pavucontrol-qt')

## Gnome apps ------------------------------------------------------------------

packages_to_remove+=('gnome-sound-recorder' 'gnome-todo' 'gnome-weather' 'gnome-maps' 'gnome-contacts' 'gnome-clocks' 'eog' 'gnome-font-viewer' 'gnome-documents')
packages_to_remove+=('gnome-shell-extension-desktop-icons' 'gnome-shell-extension-desktop-icons-ng')
packages_to_remove+=('gnome-session-canberra')

## KDE & Qt --------------------------------------------------------------------

packages_to_remove+=('qtwayland5' 'qttranslations5-l10n' 'qt5-gtk-platformtheme')

## Localization and fonts ------------------------------------------------------

packages_to_remove+=('fonts-beng' 'fonts-beng-extra' 'fonts-lohit-beng-assamese' 'fonts-lohit-beng-bengali' 'fonts-deva' 'fonts-gargi' 'fonts-lohit-deva' 'fonts-nakula' 'fonts-sahadeva' 'fonts-samyak-deva' 'fonts-gujr' 'fonts-gujr-extra' 'fonts-kalapi' 'fonts-lohit-gujr' 'fonts-samyak-gujr' 'fonts-guru' 'fonts-guru-extra' 'fonts-lohit-guru' 'fonts-knda' 'fonts-gubbi' 'fonts-lohit-knda' 'fonts-navilu' 'fonts-mlym' 'fonts-lohit-mlym' 'fonts-samyak-mlym' 'fonts-smc' 'fonts-orya' 'fonts-lohit-orya' 'fonts-orya-extra' 'fonts-taml' 'fonts-lohit-taml' 'fonts-samyak-taml' 'fonts-lohit-taml-classical' 'fonts-telu' 'fonts-lohit-telu' 'fonts-lohit-telu' 'fonts-pagul' 'fonts-indic' 'fonts-kacst' 'fonts-kacst-one' 'fonts-khmeros-core' 'fonts-lao' 'fonts-lklug-sinhala' 'fonts-noto-cjk' 'fonts-noto-cjk-extra' 'fonts-noto-unhinted' 'fonts-sil-abyssinica' 'fonts-sil-padauk' 'fonts-tibetan-machine' 'fonts-thai-tlwg' 'fonts-tlwg-garuda' 'fonts-tlwg-garuda-ttf' 'fonts-tlwg-kinnari' 'fonts-tlwg-kinnari-ttf' 'fonts-tlwg-laksaman' 'fonts-tlwg-laksaman-ttf' 'fonts-tlwg-loma' 'fonts-tlwg-loma-ttf' 'fonts-tlwg-mono' 'fonts-tlwg-mono-ttf' 'fonts-tlwg-norasi' 'fonts-tlwg-norasi-ttf' 'fonts-tlwg-purisa' 'fonts-tlwg-purisa-ttf' 'fonts-tlwg-sawasdee' 'fonts-tlwg-sawasdee-ttf' 'fonts-tlwg-typewriter' 'fonts-tlwg-typewriter-ttf' 'fonts-tlwg-typist' 'fonts-tlwg-typist-ttf' 'fonts-tlwg-typo' 'fonts-tlwg-typo-ttf' 'fonts-tlwg-umpush' 'fonts-tlwg-umpush-ttf' 'fonts-tlwg-waree' 'fonts-tlwg-waree-ttf' 'fonts-droid-fallback' 'fonts-linuxlibertine' 'fonts-freefont-ttf' 'fonts-liberation2' 'fonts-arphic-ukai' 'fonts-arphic-uming')
packages_to_remove+=('language-pack-zh-hans-base' 'language-pack-zh-hans' 'language-pack-pt-base' 'language-pack-pt' 'language-pack-it-base' 'language-pack-it' 'language-pack-gnome-zh-hans-base' 'language-pack-gnome-zh-hans' 'language-pack-gnome-pt-base' 'language-pack-gnome-pt' 'language-pack-gnome-it-base' 'language-pack-gnome-it' 'language-pack-gnome-fr-base' 'language-pack-gnome-fr' 'language-pack-gnome-es-base' 'language-pack-gnome-es' 'language-pack-gnome-de-base' 'language-pack-gnome-de' 'language-pack-fr-base' 'language-pack-fr' 'language-pack-es-base' 'language-pack-es' 'language-pack-de-base' 'language-pack-de')
packages_to_remove+=('wfrench' 'wbrazilian' 'wngerman' 'wogerman' 'wportuguese' 'wspanish' 'wswiss' 'witalian' 'wbulgarian' 'wcatalan' 'wdanish' 'wdutch' 'wnorwegian' 'wpolish' 'wswedish' 'wswedish')
packages_to_remove+=('ispell' 'iamerican' 'ibrazilian' 'ibritish' 'ibulgarian' 'icatalan' 'idanish' 'idutch' 'ienglish-common' 'ifrench-gut' 'ihungarian' 'iitalian' 'ilithuanian' 'ingerman' 'inorwegian' 'ipolish' 'iportuguese' 'irussian' 'ispanish' 'iswiss')
packages_to_remove+=('firefox-locale-de' 'firefox-locale-es' 'firefox-locale-fr' 'firefox-locale-it' 'firefox-locale-pt' 'firefox-locale-zh-hans')
packages_to_remove+=('libreoffice-l10n-zh-tw' 'libreoffice-l10n-zh-cn' 'libreoffice-l10n-pt-br' 'libreoffice-l10n-pt' 'libreoffice-l10n-it' 'libreoffice-l10n-fr' 'libreoffice-l10n-es' 'libreoffice-l10n-en-za' 'libreoffice-l10n-de' 'libreoffice-help-zh-tw' 'libreoffice-help-zh-cn' 'libreoffice-help-pt-br' 'libreoffice-help-pt' 'libreoffice-help-it' 'libreoffice-help-fr' 'libreoffice-help-es' 'libreoffice-help-de')
packages_to_remove+=('hunspell-de-at-frami' 'hunspell-de-ch-frami' 'hunspell-de-de-frami' 'hunspell-en-au' 'hunspell-en-ca' 'hunspell-en-za' 'hunspell-es' 'hunspell-fr' 'hunspell-fr-classical' 'hunspell-it' 'hunspell-pt-br' 'hunspell-pt-pt')
packages_to_remove+=('hyphen-de' 'hyphen-en-ca' 'hyphen-es' 'hyphen-fr' 'hyphen-it' 'hyphen-pt-br' 'hyphen-pt-pt' 'mythes-de' 'hyphen-hr' 'hyphen-hu' 'hyphen-lt')
packages_to_remove+=('mythes-de-ch' 'mythes-en-au' 'mythes-es' 'mythes-fr' 'mythes-it' 'mythes-pt-pt')
packages_to_remove+=('khmerconverter')
packages_to_remove+=('hdate-applet')
packages_to_remove+=('hspell' 'libhdate1')
packages_to_remove+=('itools' 'libitl0')
packages_to_remove+=('fcitx5' 'fcitx5-data' 'fcitx5-modules' 'fcitx5-chewing' 'fcitx5-chineese-addons' 'fcitx' 'fcitx-bin' 'fcitx-config-common' 'fcitx-data' 'fcitx-modules' 'fcitx-frontend-all' 'fcitx-mozc' 'fcitx-mozc-data' 'fcitx5-mozc' 'mozc-utils-gui' 'mozc-data' 'mozc-server' 'ibus-mozc' 'anthy' 'anthy-common' 'gtk-im-libthai' 'gtk3-im-libthai' 'ibus-libpinyin' 'ibus-hangul' 'ibus-chewing' 'ibus-table-cangjie' 'ibus-table-cangjie-big' 'ibus-table-cangjie3' 'ibus-table-cangjie5' 'ibus-table-wubi' 'ibus-unikey' )
packages_to_remove+=('libpinyin13' 'libpinyin-data')
packages_to_remove+=('aspell-am' 'aspell-ar' 'aspell-ar-large' 'aspell-bg' 'aspell-bn' 'aspell-ca' 'aspell-cs' 'aspell-cy' 'aspell-da' 'aspell-de' 'aspell-el' 'aspell-eo' 'aspell-es' 'aspell-et' 'aspell-eu' 'aspell-fa' 'aspell-fr' 'aspell-ga' 'aspell-gl-minimos' 'aspell-gu' 'aspell-he' 'aspell-hi' 'aspell-hr' 'aspell-hu' 'aspell-is' 'aspell-it' 'aspell-kk' 'aspell-ku' 'aspell-lt' 'aspell-lv' 'aspell-ml' 'aspell-mr' 'aspell-nl' 'aspell-no' 'aspell-pa' 'aspell-pl' 'aspell-pt-br' 'aspell-pt-pt' 'aspell-ro' 'aspell-sk' 'aspell-sl' 'aspell-sv' 'aspell-ta' 'aspell-te' 'aspell-tl' 'aspell-uk')
packages_to_remove+=('hunspell' 'hunspell-ar' 'hunspell-be' 'hunspell-bg' 'hunspell-bs' 'hunspell-ca' 'hunspell-cs' 'hunspell-da' 'hunspell-de-at' 'hunspell-de-ch' 'hunspell-de-de' 'hunspell-el' 'hunspell-en-gb' 'hunspell-eu' 'hunspell-gl' 'hunspell-gu' 'hunspell-hi' 'hunspell-hr' 'hunspell-hu' 'hunspell-id' 'hunspell-is' 'hunspell-kk' 'hunspell-kmr' 'hunspell-ko' 'hunspell-lt' 'hunspell-lv' 'hunspell-ml' 'hunspell-ne' 'hunspell-nl' 'hunspell-pl' 'hunspell-ro' 'hunspell-si' 'hunspell-sl' 'hunspell-sr' 'hunspell-sv' 'hunspell-te' 'hunspell-th' 'hunspell-vi')
packages_to_remove+=('fcitx5-chinese-addons' 'fcitx5-chinese-addons-bin' 'fcitx5-chinese-addons-data' 'fcitx5-module-chttrans' 'fcitx5-module-cloudpinyin' 'fcitx5-module-fullwidth' 'fcitx5-module-lua' 'fcitx5-module-lua-common' 'fcitx5-module-pinyinhelper' 'fcitx5-module-punctuation' 'fcitx5-pinyin' 'fcitx5-table')

## Development -----------------------------------------------------------------

for package in $(apt-mark showmanual | grep '^libabsl[0-9]')
do
    packages_to_remove+=("$package")
done

## Snapd -----------------------------------------------------------------------

if ispkginstalled snapd
then
    packages_to_remove+=('snapd')
fi

## -----------------------------------------------------------------------------

if [[ ${#packages_to_remove[@]} -gt 0 ]]
then
    appremove 'Unused packages' "${packages_to_remove[*]}"
fi

## Disabling Snapd =============================================================

if ispkgavailable snapd
then
    silent    'Disable Snapd'       apt-mark hold 'snapd'
fi

## Unused applications ---------------------------------------------------------

DEBIAN_FRONTEND=noninteractive silent 'Purge removed packages'      apt purge --yes --force-yes --allow-downgrades --allow-remove-essential --purge -qq $(dpkg -l | awk '/^rc/ {print $2}')
DEBIAN_FRONTEND=noninteractive silent 'Remove unnecessary packages' apt autopurge --yes --force-yes --allow-downgrades --allow-remove-essential --purge -qq
