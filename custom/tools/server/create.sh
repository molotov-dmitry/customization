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

## Add PPA`s -------------------------------------------------------------------

repoadd 'plexmediaserver'           'shell.ninthgate.se/packages/debian' 'wheezy' 'plexmediaserver/shell.ninthgate.se.gpg.key'
ppaadd  'Web Upd8'                  'nilarimogard' 'webupd8'

## Update ----------------------------------------------------------------------

appupdate
appupgrade

## Install ---------------------------------------------------------------------

bundle install 'dev/build'
bundle install 'dev/db'

bundle install 'server'

bundle install 'vcs'

bundle install 'cli'

