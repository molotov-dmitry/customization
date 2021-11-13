#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

### Applications ===============================================================

## Update all packages ---------------------------------------------------------

appupdate

## Install additional packages -------------------------------------------------

appinstall 'Dir manager'            'dirmngr'
appinstall 'LSB release'            'lsb-release'
appinstall 'Base'                   'less mount grep sed wget'
