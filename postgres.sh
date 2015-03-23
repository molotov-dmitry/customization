#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

sudo echo -n

clear
clear

### Postgres configuration =====================================================

cd /

silentsudo '' su postgres -c "dropdb financedb --if-exists"
silentsudo '' su postgres -c "dropuser $USER --if-exists"

sudo su postgres -c "createuser -U postgres -d -e -E -l -P -r -s $USER"

silent '' createdb financedb
