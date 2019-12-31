#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

### Customization ==============================================================

## GSConnect -------------------------------------------------------------------

if ispkginstalled gnome-shell
then
    gsettingsadd org.gnome.shell enabled-extensions 'gsconnect@andyholmes.github.io'
fi

## Clear launcher --------------------------------------------------------------

launcherclear

