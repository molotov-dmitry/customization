#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

#### Configure NetworkManager for using Realtek 8812AU driver ==================

addconfigline 'wifi.scan-rand-mac-address' 'no' 'device' '/etc/NetworkManager/NetworkManager.conf'
