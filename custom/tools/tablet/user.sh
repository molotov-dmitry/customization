#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

### Customization ==============================================================

## Clear launcher --------------------------------------------------------------

launcherclear

## Appearance ------------------------------------------------------------------

if test -f '/usr/share/backgrounds/linuxmint-tessa/skunze_beach.jpg'
then
    setwallpaper '/usr/share/backgrounds/linuxmint-tessa/skunze_beach.jpg'
else
    setwallpaper '#204a87'
fi

if test -f '/usr/share/backgrounds/Milky_Way_before_the_dawn_by_Tomas_Sobek.jpg'
then
    setlockscreen '/usr/share/backgrounds/Milky_Way_before_the_dawn_by_Tomas_Sobek.jpg'
fi
