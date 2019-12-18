#!/bin/bash

while read userinfo
do
    user_name="$(echo "${userinfo}" | cut -d ':' -f 1)"
    user_id="$(echo "${userinfo}" | cut -d ':' -f 3)"
    user_group="$(echo "${userinfo}" | cut -d ':' -f 4)"
    user_comment="$(echo "${userinfo}" | cut -d ':' -f 5)"
    user_home="$(echo "${userinfo}" | cut -d ':' -f 6)"
    user_login="$(echo "${userinfo}" | cut -d ':' -f 7)"

    echo "${userinfo}: name:[${user_name}] id:[${user_id}] group:[${user_group}] comment:[${user_comment}] home:[${user_home}] login:[${user_login}]" >> /tools/firstboot.log

    if [[ ${user_id} -lt 999 || ${user_id} -ge 60000 || -z "${user_home}" || "$(basename "${user_login}")" == 'nologin' ]]
    then
        continue
    fi

    if [[ -n "$(grep "^${user_id}$" /tools/.firstbootuser)" ]]
    then
        continue
    fi

    bash /tools/firstboot.sh 2>> /tools/firstboot.log
    echo "${user_id}: $?" >> /tools/.firstboot

    bash /tools/bundle.sh firstbootuser firstbootuser "${user_name}" "${user_id}" "${user_group}" "${user_comment}" "${user_home}" "${user_login}" 2>> /tools/firstbootuser.log
    echo "${user_id}: $?" >> /tools/.firstboot

    echo "${user_id}" >> /tools/.firstbootuser

done < /etc/passwd

if [[ ! -e /tools/.firstboot ]]
then

    setcap cap_net_raw+ep $(which ping)
    echo "$?" >>  /tools/.firstboot

    bash /tools/firstboot.sh 2>> /tools/firstboot.log
    echo "$?" >> /tools/.firstboot

    bash /tools/bundle.sh firstboot firstboot 2>> /tools/firstboot.log
    echo "$?" >> /tools/.firstboot
fi

