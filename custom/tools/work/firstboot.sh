#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

sudo echo -n

clear
clear

### Add all users to wireshark group ===========================================

for userinfo in $(cat /etc/passwd | grep -v nologin | grep -v /bin/false | grep -v /bin/sync | grep -v postgres | grep -v ftp | cut -d ':' -f 1,6)
do
    user_name=$(echo "${userinfo}" | cut -d ':' -f 1)

    usermod -a -G wireshark ${user_name}
done

### Add samba shares to fstab ==================================================

sed -i '/[ \t]cifs[ \t]/d' /etc/fstab

echo '' >> /etc/fstab
echo '//172.16.8.91/usr /media/dima cifs guest,user=root,uid=1000,forceuid,gid=1000,forcegid,file_mode=0775,dir_mode=0775,iocharset=utf8,sec=ntlm 0 0' >> /etc/fstab
echo '//172.16.8.91/share2 /media/cub_local cifs guest,user=root,uid=1000,forceuid,gid=1000,forcegid,file_mode=0775,dir_mode=0775,iocharset=utf8,sec=ntlm 0 0' >> /etc/fstab
echo '//172.16.8.21/share2 /media/cub cifs guest,user=root,uid=1000,forceuid,gid=1000,forcegid,file_mode=0775,dir_mode=0775,iocharset=utf8,sec=ntlm 0 0' >> /etc/fstab

### Fix directory permissions ==================================================

fixpermissions '/media/documents'

