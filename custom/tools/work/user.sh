#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

### User network configuration =================================================

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

## Network ---------------------------------------------------------------------

bundle user 'network/mail'
bundle user 'network/chat'

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

