#!/bin/bash

cat >> ~/.bash_aliases << '_EOF'
function wpaconnect()
{
    local essid="$1"

    if [[ -z "$2" ]]
    then
        local iface="wlan0"
    else
        local iface="$2"
    fi

    while [[ ! -f "${HOME}/.local/share/wpa_essid/${essid}" ]]
    do
        mkdir -p "${HOME}/.local/share/wpa_essid"

        echo "input password:"

        wpa_passphrase ${essid} > "${HOME}/.local/share/wpa_essid/${essid}"
    done

    sudo wpa_supplicant -B -i $iface -c "${HOME}/.local/share/wpa_essid/${essid}"

    local result=$?
    if [[ $result -ne 0 ]]
    then
        return $result
    fi

    sudo timeout 5 dhclient $iface

    local result=$?
    if [[ $result -ne 0 ]]
    then
        echo 'Not connected'

        return $result
    fi

    echo 'Connected'

    return 0
}
_EOF
