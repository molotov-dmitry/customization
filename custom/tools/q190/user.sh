#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

### User network configuration =================================================

### Add network shares ---------------------------------------------------------

mkdir -p "${HOME}/.config/gtk-3.0/"

addbookmark 'sftp://188.134.72.31:2222/media/documents' 'AHOME'

addbookmark 'smb://172.16.8.21/share2'         'KUB'
addbookmark 'smb://172.16.8.203'               'NAS'
addbookmark 'smb://data.rczifort.local/shares' 'RCZIFORT'

### Add network switch =========================================================

if [[ $UID -eq 1000 ]]
then
    nettype=eth
else
    nettype=wifi
fi

mkdir -p "${HOME}/.config/autostart"

cat > "${HOME}/.config/autostart/network-switch.desktop" << _EOF
[Desktop Entry]
Version=1.0
Name=Network switcher
Comment=Network switcher
Exec=network-switch ${nettype}
Terminal=false
Type=Application
Categories=Network
_EOF

unset nettype

### Customization ==============================================================

## Clear launcher --------------------------------------------------------------

launcherclear


