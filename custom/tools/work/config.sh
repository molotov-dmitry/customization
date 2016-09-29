#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

### Customization ==============================================================

## Cursor theme ----------------------------------------------------------------

bundle config 'themes'

## Qt5 GTK2 theme --------------------------------------------------------------

bundle config 'qt'

## Development -----------------------------------------------------------------

bundle config 'dev'

### Server =====================================================================

## FTP server ------------------------------------------------------------------

bundle config 'server/ftp'

## SVN server ------------------------------------------------------------------

bundle config 'server/svn'

### IR emulator ================================================================

addservice 'M711-IR build'          'irbuild'
addservice 'M711-IR emulator'       'irserver'

### Time sync ==================================================================

addservice 'Time sync'              'timesync'

