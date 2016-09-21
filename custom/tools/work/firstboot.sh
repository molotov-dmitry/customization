#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

sudo echo -n

clear
clear

### Customization ==============================================================

## Cursor theme ----------------------------------------------------------------

cursor_theme='breeze_cursors'

update-alternatives --set x-cursor-theme "/etc/X11/cursors/${cursor_theme}.theme"

## Qt5 GTK2 theme --------------------------------------------------------------

if ispkginstalled gnome-shell
then
    echo 'export QT_QPA_PLATFORMTHEME=qt5gtk2' > /etc/X11/Xsession.d/100-qt5gtk2
fi

### Add samba shares to fstab ==================================================

sed -i '/[ \t]cifs[ \t]/d' /etc/fstab

echo '' >> /etc/fstab
echo '//172.16.8.91/usr /media/dima cifs guest,user=root,uid=1000,forceuid,gid=1000,forcegid,file_mode=0775,dir_mode=0775,iocharset=utf8,sec=ntlm 0 0' >> /etc/fstab
echo '//172.16.8.91/share2 /media/cub_local cifs guest,user=root,uid=1000,forceuid,gid=1000,forcegid,file_mode=0775,dir_mode=0775,iocharset=utf8,sec=ntlm 0 0' >> /etc/fstab
echo '//172.16.8.21/share2 /media/cub cifs guest,user=root,uid=1000,forceuid,gid=1000,forcegid,file_mode=0775,dir_mode=0775,iocharset=utf8,sec=ntlm 0 0' >> /etc/fstab

### Fix directory permissions ==================================================

fixpermissions '/media/documents'

