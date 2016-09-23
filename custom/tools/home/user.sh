#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

### Customization ==============================================================

## Clear launcher --------------------------------------------------------------

launcherclear

## Appearance ------------------------------------------------------------------

bundle user 'themes'

bundle user 'fonts'

setwallpaper '#204a87'

### Application customization ==================================================

## Gnome apps configuration ----------------------------------------------------

bundle user 'gnome'

## Development -----------------------------------------------------------------

bundle user 'dev'

## Version control system ------------------------------------------------------

bundle user 'vcs'

## Office ----------------------------------------------------------------------

bundle user 'office'

## Multimedia ------------------------------------------------------------------

bundle user 'media'
