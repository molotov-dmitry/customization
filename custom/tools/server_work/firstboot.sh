#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

### Add samba shares to fstab ==================================================

sed -i '/[ \t]cifs[ \t]/d' /etc/fstab

echo '' >> /etc/fstab
echo '//172.16.8.21/share2 /media/cub cifs guest,user=root,uid=1000,forceuid,gid=1000,forcegid,file_mode=0775,dir_mode=0775,iocharset=utf8,sec=ntlm 0 0' >> /etc/fstab

### Fix directory permissions ==================================================

fixpermissions '/media/documents' '1000'

