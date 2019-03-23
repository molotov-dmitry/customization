#!/bin/bash

ROOT_PATH='/tools'

. "${ROOT_PATH}/functions.sh"

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

if [[ -f /tools/user.sh && ! -e "${HOME}/.config/.firstboot" ]]
then
    mkdir -p "${HOME}"/.config

    bash /tools/user.sh
    echo "$?" >  "${HOME}"/.config/.firstboot

    bash /tools/bundle.sh user user
    echo "$?" >> "${HOME}"/.config/.firstboot
fi

' >> "${user_dir}"/.profile

    chown "${user_name}" "${user_dir}"/.profile

    fi
done

if [[ ! -e /tools/.firstboot ]]
then

    setcap cap_net_raw+ep $(which ping)
    echo "$?" >  /tools/.firstboot

    bash /tools/firstboot.sh 2>> /tools/firstboot.log
    echo "$?" >> /tools/.firstboot

    bash /tools/bundle.sh firstboot firstboot 2>> /tools/firstboot.log
    echo "$?" >> /tools/.firstboot
fi

