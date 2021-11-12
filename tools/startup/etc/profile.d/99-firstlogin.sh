
if [ -r /tools/user.sh ] && [ ! -e "${HOME}/.config/.firstboot" ] && [ -e "/tools/status/.completed" ] && [ -n "${XDG_CURRENT_DESKTOP}" ]
then
    mkdir -p "${HOME}/.config"

    bash /tools/user.sh >> "${HOME}/.config/.firstboot.log" 2>&1
    echo "$?" >> "${HOME}/.config/.firstboot"

    bash /tools/bundle.sh user user >> "${HOME}/.config/.firstboot.log" 2>&1
    echo "$?" >> "${HOME}/.config/.firstboot"
fi
