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
