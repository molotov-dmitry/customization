#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

sudo echo -n

clear
clear

### System =====================================================================

fixpermissions '/media/documents'
fixpermissions '/media/windows'

### Customization ==============================================================

## Cursor theme ----------------------------------------------------------------

cursor_theme='breeze_cursors'

silentsudo '' update-alternatives --set x-cursor-theme "/etc/X11/cursors/${cursor_theme}.theme"
