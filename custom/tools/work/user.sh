#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

### User network configuration =================================================

ifnames=( $(ip link | grep '^[[:digit:]]*:' | cut -d ':' -f 2 | sed 's/^[ \t]*//' | grep -v '^lo$') )

ifname=${ifnames[0]}

nmcli connection delete DmitryServer
nmcli connection add con-name DmitryServer ifname ${ifname} type ethernet ip4 172.16.8.81/24 gw4 172.16.8.253
nmcli connection modify DmitryServer ipv4.dns "172.16.56.3 172.16.56.1"
nmcli connection modify DmitryServer ipv4.ignore-auto-dns yes
nmcli connection modify DmitryServer ipv6.method ignore

nmcli connection show | tail -n +2 | sed 's/ *[^ ]*-.*//' | grep -v '^DmitryServer$' | while read profile
do
    nmcli connection delete "${profile}"
done

### Customization ==============================================================

## Animations ------------------------------------------------------------------

gsettings set org.gnome.desktop.interface enable-animations false

## Appearance ------------------------------------------------------------------

bundle user 'appearance'

## Wallpaper -------------------------------------------------------------------

setwallpaper '#204a87'

## Launcher applications -------------------------------------------------------

launcherclear

### Application customization ==================================================

## Gnome -----------------------------------------------------------------------

bundle user 'gnome'

## Development -----------------------------------------------------------------

bundle user 'dev'
bundle user 'vcs'

## Office  ----------------------------------------------------------------

bundle user 'office'

