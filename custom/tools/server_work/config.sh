#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

### Applications ===============================================================

## Build tools - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

bundle config 'dev/build'

### Server =====================================================================

## SSH server ------------------------------------------------------------------

bundle config 'server/ssh'

## FTP server ------------------------------------------------------------------

bundle config 'server/ftp'

## SVN server ------------------------------------------------------------------

bundle config 'server/svn'

## Smb server ------------------------------------------------------------------

bundle config 'server/smb'

### Gitlab ---------------------------------------------------------------------

#bundle config 'gitlab'

### IR emulator ================================================================

addservice 'M711-IR build'          'irbuild'
addservice 'M711-IR emulator'       'irserver'

### Time sync ==================================================================

addservice 'Time sync'              'timesync'

