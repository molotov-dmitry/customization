#!/bin/bash

ROOT_PATH='/tools'

. "${ROOT_PATH}/functions.sh"

if [[ ! islive && ! -e /tools/.firstboot ]]
then
    bash /tools/firstboot.sh

    touch /tools/.firstboot
fi

for userinfo in $(cat /etc/passwd | grep -v nologin | grep -v /bin/false | grep -v /bin/sync | grep -v postgres | grep -v ftp | cut -d ':' -f 1,6)
do
    user_name=$(echo "${userinfo}" | cut -d ':' -f 1)
    user_dir=$(echo "${userinfo}" | cut -d ':' -f 2)

    [[ -z "${user_name}" ]] && continue
    [[ -z "${user_dir}" ]] && continue

    cd "${user_dir}" || continue

    if [[ -z "$(grep /tools/user.sh "${user_dir}"/.profile)" ]]
    then
        echo '

if [[ -f /tools/user.sh && ! -e "${HOME}"/.firstboot ]]
then
    bash /tools/user.sh && touch "${HOME}"/.firstboot
fi

' >> "${user_dir}"/.profile

    chown "${user_name}" "${user_dir}"/.profile

    fi
done
