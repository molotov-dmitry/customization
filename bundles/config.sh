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

    bash "${scriptpath}" 'server/ssh'
    bash "${scriptpath}" 'server/ftp'
    bash "${scriptpath}" 'server/smb'
    bash "${scriptpath}" 'server/svn'
    bash "${scriptpath}" 'server/media'
    bash "${scriptpath}" 'server/download'

;;

### OpenSSH server =============================================================

"server/ssh")

    silentsudo 'Configuring Open SSH' touch /etc/ssh/sshd_config
    silentsudo 'Configuring Open SSH' sed -i '/^ClientAliveInterval/d;/^ClientAliveCountMax/d' /etc/ssh/sshd_config
    silentsudo 'Configuring Open SSH' bash -c 'echo -e "\nClientAliveInterval 300\nClientAliveCountMax 2" >> /etc/ssh/sshd_config'

;;

### FTP server =================================================================

"server/ftp")

    silentsudo 'Configuring vsftpd'     cp -f "${ROOT_PATH}/files/vsftpd/vsftpd.conf" '/etc/'

;;

### SMB server =================================================================

"server/smb")

    silentsudo 'Creating Samba config dir'      mkdir -p '/etc/samba'
    silentsudo 'Configuring Samba'              cp -f "${ROOT_PATH}/files/samba/smb.conf" '/etc/samba/'

;;

### SVN server =================================================================

"server/svn")

    addservice 'Subversion server'      'svnserve' 'svnserve'

;;

### Media server ===============================================================

"server/media")

    ## MiniDLNA ----------------------------------------------------------------

    silentsudo 'Inotyfy max watchs fix' bash -c 'echo -e "fs.inotify.max_user_watches = 100000" > /etc/sysctl.d/90-inotify.conf'
    silentsudo 'Inotify max watchs fix' sysctl fs.inotify.max_user_watches=100000

    silentsudo 'Configuring MiniDLNA'   sudo cp -f "${ROOT_PATH}/files/minidlna/minidlna.conf" '/etc/'

    ## Plex Media Server -------------------------------------------------------

    silentsudo 'Creating Plex config dir'   mkdir -p '/var/lib/plexmediaserver/Library/Application Support/Plex Media Server'
    silentsudo 'Configuring Plex'           sudo cp -f "${ROOT_PATH}/files/plexmediaserver/Preferences.xml" '/var/lib/plexmediaserver/Library/Application Support/Plex Media Server/'
    silentsudo 'Changing Plex config owner' chown -R plex:plex '/var/lib/plexmediaserver'

    silentsudo 'Modify firstboot script'    sed -i 's/^After=/After=plexmediaserver.service /' '/tools/files/custom-startup.service'

;;

### Download server ============================================================

"server/download")

    ## Transmission ------------------------------------------------------------

    silentsudo 'Creating Transmission config dir' mkdir -p '/etc/transmission-daemon'
    silentsudo 'Configuring Transmission'   cp -f "${ROOT_PATH}/files/transmission/settings.json" '/etc/transmission-daemon/'

    ## EiskaltDC++ -------------------------------------------------------------

    silentsudo 'Creating EiskaltDC++ config dir' mkdir -p '/etc/eiskaltdcpp'
    silentsudo 'Configuring EiskaltDC++'        cp -f "${ROOT_PATH}/files/eiskaltdcpp/DCPlusPlus.xml" '/etc/eiskaltdcpp/'
    silentsudo 'Configuring EiskaltDC++ Hubs'   cp -f "${ROOT_PATH}/files/eiskaltdcpp/Favorites.xml" '/etc/eiskaltdcpp/'

    addservice 'EiskaltDC++' 'eiskaltdcpp' 'eiskaltdcpp'

;;

### GitLab =====================================================================

"gitlab")

    if [[ -d /etc/nginx/sites-enabled/default ]]
    then
        silentsudo 'Removing default nginx site' rm /etc/nginx/sites-enabled/default
    fi

    silentsudo 'Modify firstboot script'    sed -i 's/^After=/After=postgresql.service /' '/tools/files/custom-startup.service'

;;

### ============================================================================
### Appearance =================================================================
### ============================================================================

"appearance")

    bash "${scriptpath}" 'appearance/themes'

;;

### Themes =====================================================================

"appearance/themes")

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

