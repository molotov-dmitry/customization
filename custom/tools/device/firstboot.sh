#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

### Add nameserver configuration ===============================================

for dns in '172.16.56.14' '172.16.56.10'
do
    if [[ -z "$(grep "${dns}$" /etc/resolv.conf)" ]]
    then
        echo "nameserver $dns" >> /etc/resolv.conf
    fi
done

if [[ -z "$(grep "rczifort.local$" /etc/resolv.conf)" ]]
then
    echo "domain rczifort.local" >> /etc/resolv.conf
fi

### Remove setup network configuration =========================================

rm -f '/etc/network/interfaces.d/setup'
