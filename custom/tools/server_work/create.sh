#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

sudo echo -n

clear

### Test internet connection ===================================================

title 'Testing internet connection'

if conntest
then
    msgdone
else
    msgfail
    exit 1
fi

### Applications ===============================================================

appremove 'apt-listchanges' 'apt-listchanges'

## Updating --------------------------------------------------------------------

changemirror  'mirror.yandex.ru'
changerelease 'stretch'

sudo apt-get update --yes --force-yes
sudo apt-get dist-upgrade --yes --force-yes

#appupdate
#appupgrade

## Install ---------------------------------------------------------------------

bundle install 'server/ssh'
bundle install 'server/ftp'
bundle install 'server/smb'
bundle install 'server/svn'
bundle install 'server/iperf'

bundle install 'cli'

bundle install 'gitlab'
