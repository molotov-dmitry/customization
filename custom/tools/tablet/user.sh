#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

### Customization ==============================================================

## Clear launcher --------------------------------------------------------------

launcherclear

## Appearance ------------------------------------------------------------------

bundle user 'appearance'

setwallpaper '#204a87'

### Application customization ==================================================

## Gnome apps configuration ----------------------------------------------------

bundle user 'gnome'

## Network ---------------------------------------------------------------------

bundle user 'network'

## Version control system ------------------------------------------------------

bundle user 'vcs'

## Office ----------------------------------------------------------------------

bundle user 'office'

## Multimedia ------------------------------------------------------------------

bundle user 'media'

## Graphics --------------------------------------------------------------------

bundle user 'graphics'

## Console ---------------------------------------------------------------------

bundle user 'cli'

## Optimizations ---------------------------------------------------------------

bundle user 'optimize'

### Directories ================================================================

bash "${ROOT_PATH}/folders.sh"
