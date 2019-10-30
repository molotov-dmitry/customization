#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

### Gnome shell extensions =====================================================

if ispkginstalled gnome-shell
then
    gnomeshellextension 7               # Removable Drive Menu
fi


### User network configuration =================================================

### Add network shares ---------------------------------------------------------

addbookmark 'sftp://188.134.72.31:2222/media/documents' 'AHOME'

addbookmark 'smb://172.16.8.21/share2'         'KUB'
addbookmark 'smb://172.16.8.203'               'NAS'
addbookmark 'smb://data.rczifort.local/shares' 'RCZIFORT'

### Customization ==============================================================

## Make GIT accept self-signed certificate -------------------------------------

git config --global http.sslVerify false

## Clear launcher --------------------------------------------------------------

launcherclear

## Appearance ------------------------------------------------------------------

setwallpaper '#204a87'

