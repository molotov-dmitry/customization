#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

sudo echo -n

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

## Update ----------------------------------------------------------------------

changemirror  'ftp.ru.debian.org'
changerelease 'stretch'

appupdate
appupgrade

## Install ---------------------------------------------------------------------

## Build tools - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

bundle install 'dev/build'

## Server  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

bundle install 'server/ssh'
bundle install 'server/ftp'
bundle install 'server/smb'
bundle install 'server/svn'
bundle install 'server/db'
bundle install 'server/iperf'

## VCS - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

bundle install 'vcs'

## Console tools - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

bundle install 'cli'

## VMWare tools  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

bundle install 'vm'

## Remove unused applications  - - - - - - - - - - - - - - - - - - - - - - - - -

## GitLab  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

#bundle install 'gitlab'


