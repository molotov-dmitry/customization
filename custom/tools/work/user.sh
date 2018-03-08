#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

### User network configuration =================================================

ifnames=( $(ip link | grep '^[[:digit:]]*:' | cut -d ':' -f 2 | sed 's/^[ \t]*//' | grep -v '^lo$') )

ifname=${ifnames[0]}

nmcli connection delete WiredConnection
nmcli connection add con-name WiredConnection ifname ${ifname} type ethernet ip4 172.16.8.92/24 gw4 172.16.8.253
nmcli connection modify WiredConnection ipv4.dns "172.16.56.14 172.16.56.10"
nmcli connection modify WiredConnection ipv4.ignore-auto-dns yes
nmcli connection modify WiredConnection ipv6.method ignore

nmcli connection show | tail -n +2 | sed 's/ *[^ ]*-.*//' | grep -v '^WiredConnection$' | while read profile
do
    nmcli connection delete "${profile}"
done

### Add network shares ---------------------------------------------------------

mkdir -p "${HOME}/.config/gtk-3.0/"

echo 'smb://172.16.8.91/usr Dima'          >> "${HOME}/.config/gtk-3.0/bookmarks"
echo 'smb://172.16.8.91/share2 Dima (Cub)' >> "${HOME}/.config/gtk-3.0/bookmarks"
echo 'smb://172.16.8.21/share2 Cub'        >> "${HOME}/.config/gtk-3.0/bookmarks"

### Customization ==============================================================

## Clear launcher --------------------------------------------------------------

launcherclear

## Appearance ------------------------------------------------------------------

bundle user 'appearance'

setwallpaper '#204a87'

### Application customization ==================================================

## Gnome apps configuration ----------------------------------------------------

bundle user 'gnome'

## Development -----------------------------------------------------------------

bundle user 'dev/style'
bundle user 'dev/qt'

## Version control system ------------------------------------------------------

bundle user 'vcs'

## Office ----------------------------------------------------------------------

bundle user 'office'

## Graphics --------------------------------------------------------------------

bundle user 'graphics'

## Console ---------------------------------------------------------------------

bundle user 'cli'

