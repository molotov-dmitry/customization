#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

### User network configuration =================================================

### Add network shares ---------------------------------------------------------

mkdir -p "${HOME}/.config/gtk-3.0/"

addbookmark 'smb://172.16.8.21/share2'  'KUB'
addbookmark 'smb://172.16.8.203'        'NAS'
addbookmark 'smb://data.rczifort.local' 'DATA'

### Customization ==============================================================

## Clear launcher --------------------------------------------------------------

launcherclear

## Appearance ------------------------------------------------------------------

setwallpaper '#204a87'
