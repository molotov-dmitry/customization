#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

### Add samba shares to fstab ==================================================

sed -i '/[ \t]/media/backup[ \t]/d' /etc/fstab

echo '' >> /etc/fstab
echo '//172.16.8.203/backup /media/backup cifs guest,file_mode=0777,dir_mode=0777,iocharset=utf8 0 0' >> /etc/fstab


