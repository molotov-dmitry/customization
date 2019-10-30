#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

## Clear launcher --------------------------------------------------------------

launcherclear

## Appearance ------------------------------------------------------------------

setwallpaper '#204a87'

