#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

### Customization ==============================================================

### Server ---------------------------------------------------------------------

bundle config 'server/ftp'
bundle config 'server/smb'
bundle config 'server/svn'

### Nginx ----------------------------------------------------------------------

silentsudo 'Removing default nginx site' rm /etc/nginx/sites-enabled/default
