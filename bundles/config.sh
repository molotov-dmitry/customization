#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")/.." && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

bundle="$1"

scriptpath="${ROOT_PATH}/bundles/$(basename "$0")"

case "${bundle}" in

### ============================================================================
### Development ================================================================
### ============================================================================

"dev")

    bash "${scriptpath}" 'dev/build'

;;

### Build tools ================================================================

"dev/build")

    silentsudo 'Ptrace fix'             sed -i 's/[ \t]*kernel.yama.ptrace_scope[ \t]*=[ \t]*1/kernel.yama.ptrace_scope = 0/' /etc/sysctl.d/10-ptrace.conf

;;

### ============================================================================
### Server =====================================================================
### ============================================================================

"server")

    bash "${scriptpath}" 'server/ftp'
    bash "${scriptpath}" 'server/svn'

;;

### FTP server =================================================================

"server/ftp")

    silentsudo 'Configuring vsftpd'     cp -f "${ROOT_PATH}/files/vsftpd/vsftpd.conf" '/etc/'

;;

### SMB server =================================================================

"server/smb")

    #TODO

;;

### SVN server =================================================================

"server/svn")

    addservice 'Subversion server'      'svnserve' 'svnserve'

;;

### Media server ===============================================================

"server/media")

    #TODO

;;

### ============================================================================
### Themes =====================================================================
### ============================================================================

"themes")

    ## Cursor theme ------------------------------------------------------------

    cursor_theme='breeze_cursors'

    update-alternatives --set x-cursor-theme "/etc/X11/cursors/${cursor_theme}.theme"

;;

### ============================================================================
### Qt =========================================================================
### ============================================================================

"qt")

    ## Qt5 GTK2 theme ----------------------------------------------------------

    if ispkginstalled gnome-shell
    then
        echo 'export QT_QPA_PLATFORMTHEME=qt5gtk2' > /etc/X11/Xsession.d/100-qt5gtk2
    fi

;;

### ============================================================================
### Network and communication ==================================================
### ============================================================================

"network")

    ## Empathy -----------------------------------------------------------------

    mkdir -p '/usr/share/adium/message-styles'
    cp -rf "${ROOT_PATH}/files/empathy/material.AdiumMessageStyle" '/usr/share/adium/message-styles/'

    while read color
    do
        colorvalue=$(echo "${color}" | cut -d ' ' -f 1)
        colorname=$(echo "${color}" | cut -d ' ' -f 2-)

        bash '/usr/share/adium/message-styles/material.AdiumMessageStyle/Contents/Resources/create.sh' "${colorname}" "${colorvalue}"

    done < '/usr/share/adium/message-styles/material.AdiumMessageStyle/Contents/Resources/colorlist'

;;

### ============================================================================
### ============================================================================
### ============================================================================

esac

