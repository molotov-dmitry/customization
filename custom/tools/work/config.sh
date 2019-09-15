#!/bin/bash

#### Configure NetworkManager for using Realtek 8812AU driver ==================

addconfigline 'wifi.scan-rand-mac-address' 'no' 'device' '/etc/NetworkManager/NetworkManager.conf'
