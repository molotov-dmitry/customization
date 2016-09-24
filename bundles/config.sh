#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")/.." && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

bundle="$1"

case "${bundle}" in

### Themes =====================================================================

"themes")

    ## Cursor theme ------------------------------------------------------------

    cursor_theme='breeze_cursors'

    update-alternatives --set x-cursor-theme "/etc/X11/cursors/${cursor_theme}.theme"

;;

## Qt ==========================================================================

"qt")

    ## Qt5 GTK2 theme ----------------------------------------------------------

    if ispkginstalled gnome-shell
    then
        echo 'export QT_QPA_PLATFORMTHEME=qt5gtk2' > /etc/X11/Xsession.d/100-qt5gtk2
    fi

;;

### ============================================================================

esac