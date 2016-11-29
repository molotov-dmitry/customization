#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

### Customization ==============================================================

## Cursor theme ----------------------------------------------------------------

bundle config 'appearance'

## Qt5 GTK2 theme --------------------------------------------------------------

bundle config 'qt'

## Development -----------------------------------------------------------------

bundle config 'dev'


