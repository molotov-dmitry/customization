
if [ -r /tools/user.sh ] && [ ! -e "${HOME}/.config/.firstboot" ] && [ -e "/tools/.firstboot" ] && [ -n "${-##*c*}" ]
then
    mkdir -p "${HOME}/.config"

    bash /tools/user.sh >> "${HOME}/.config/.firstboot.log" 2>&1
    echo "$?" >> "${HOME}/.config/.firstboot"

    bash /tools/bundle.sh user user >> "${HOME}/.config/.firstboot.log" 2>&1
    echo "$?" >> "${HOME}/.config/.firstboot"
fi
