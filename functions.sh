#!/bin/bash

### constants ==================================================================

readonly CL_RED='\e[31m'
readonly CL_YELLOW='\e[33m'
readonly CL_GREEN='\e[32m'
readonly CL_BLUE='\e[34m'

readonly TITLE_LENGTH=70
readonly SPACE_CHAR='.'

### Messages ===================================================================

function spaces()
{
    string="$1"
    len=${#string}
    let count=${TITLE_LENGTH}-len
    for i in $(seq 1 $count)
    do
        echo -n ${SPACE_CHAR}
    done

    return 0
}

function title()
{
    title="$1"
    echo -n "[$(date -u +%H:%M:%S)] $title"
    spaces "$title"

    return 0
}

function message()
{
    msg="$1"
    color="$2"

    echo -en "$color"
    echo -n "$msg"
    tput sgr0
    echo

    return 0
}

function msgdone()
{
    message "${1:-"[done]"}" "$CL_GREEN"

    return 0
}

function msginfo()
{
    message "${1:-"[info]"}" "$CL_BLUE"

    return 0
}

function msgwarn()
{
    message "${1:-"[warn]"}" "$CL_YELLOW"

    return 0
}

function msgfail()
{
    message "${1:-"[fail]"}" "$CL_RED"

    return 0
}

### Strings ====================================================================

function safestring()
{
    inputstr="$1"

    echo "${inputstr}" | sed 's/\\/\\\\/g;s/\//\\\//g'
}

### Connection =================================================================

function conntest()
{
    if ping -w 5 -c 1 mirror.yandex.ru 1>/dev/null 2>&1
    then
        return 0
    else
        return 1
    fi
}

### Preparing files ============================================================

function preparefiles()
{
    local name="$1"
    local dir="$2"

    if [[ -z "$dir" ]]
    then
        dir="${name,,}"
    fi

    silent "Copy $name files" cp -rf "${ROOT_PATH}/files/$dir" "${rootfs_dir}/tools/files/"
}

function usercopy()
{
    local dir="$1"
    local need_repalce="$2"

    shift
    shift

    cp -rf "${ROOT_PATH}/files/${dir}/." "${HOME}/"

    if [[ "$need_repalce" == "--replace" ]]
    then
        for file in "$@"
        do
            sed -i "s/<<HOME>>/$(safestring "${HOME}")/g" "${HOME}/${file}"
        done
    fi
}

### Packages ===================================================================

function ispkginstalled()
{
    app="$1"

    if dpkg -s "${app}" >/dev/null 2>&1
    then
        return 0
    else
        return 1
    fi
}

function ispkgavailable()
{
    app="$1"

    if [[ -n "$(apt-cache pkgnames | grep "^$app$")" ]]
    then
        return 0
    else
        return 1
    fi
}

function pkgversion()
{
    app="$1"

    LC_ALL=C dpkg -s "${app}" 2>/dev/null | grep '^Version:' | cut -d ' ' -f 2-
}

function appinstall()
{
    local appname="$1"
    local applist="$2"

    local -a installlist

    local -a missinglist
    local -a skippedlist

    title "Installing $appname"

    for app in ${applist}
    do
        if [[ "$app" == "["*"]" ]]
        then
            local pkgname=${app:1:-1}
            local required=0
        else
            local pkgname=$app
            local required=1
        fi

        if [[ -n "$(apt-mark showmanual | grep "^${pkgname}$" )" ]]
        then
            continue
        fi

        if ispkgavailable "${pkgname}"
        then
            installlist+=("${pkgname}")
        #
        elif [[ $required -gt 0 ]]
        then
            missinglist+=("${pkgname}")
        else
            skippedlist+=("${pkgname}")
        fi

    done

    if [[ "${#missinglist[@]}" -gt 0 ]]
    then
        msgfail "[missing ${missinglist[*]}]"
        return 1
    fi

    if [[ "${#installlist[@]}" -eq 0 ]]
    then
        if [[ "${#skippedlist[@]}" -eq 0 ]]
        then
            msginfo '[installed]'
            return 0
        else
            msgwarn "[missing ${skippedlist[*]}]"
        fi
    else
        for (( i = 0; i < 2; i++ ))
        do
            export DEBIAN_FRONTEND=noninteractive
            export DEBIAN_PRIORITY=critical

            DEBIAN_FRONTEND=noninteractive apt install "${installlist[@]}" \
                -o "Dpkg::Options::=--force-confdef" \
                -o "Dpkg::Options::=--force-confold" \
                --yes --force-yes --no-install-recommends >/dev/null 2>&1

            if [[ $? -eq 0 ]]
            then
                if [[ "${#skippedlist[@]}" -eq 0 ]]
                then
                    msgdone
                else
                    msgwarn "[missing ${skippedlist[*]}]"
                fi

                return 0
            fi
        done

        msgfail
        return 1
    fi
}

function apptmpinstall()
{
    local appname="$1"
    local applist="$2"

    local -a installlist

    local -a missinglist
    local -a skippedlist

    title "Installing $appname (tmp)"

    for app in ${applist}
    do
        if [[ "$app" == "["*"]" ]]
        then
            local pkgname=${app:1:-1}
            local required=0
        else
            local pkgname=$app
            local required=1
        fi

        if ispkginstalled "${pkgname}"
        then
            continue
        fi

        if ispkgavailable "${pkgname}"
        then
            installlist+=("${pkgname}")
        #
        elif [[ $required -gt 0 ]]
        then
            missinglist+=("${pkgname}")
        else
            skippedlist+=("${pkgname}")
        fi

    done

    if [[ "${#missinglist[@]}" -gt 0 ]]
    then
        msgfail "[missing ${missinglist[*]}]"
        return 1
    fi

    if [[ "${#installlist[@]}" -eq 0 ]]
    then
        if [[ "${#skippedlist[@]}" -eq 0 ]]
        then
            msginfo '[installed]'
            return 0
        else
            msgwarn "[missing ${skippedlist[*]}]"
        fi
    else
        for (( i = 0; i < 2; i++ ))
        do
            export DEBIAN_FRONTEND=noninteractive
            export DEBIAN_PRIORITY=critical

            DEBIAN_FRONTEND=noninteractive apt install "${installlist[@]}" \
                -o "Dpkg::Options::=--force-confdef" \
                -o "Dpkg::Options::=--force-confold" \
                --yes --force-yes --no-install-recommends \
                --mark-auto >/dev/null 2>&1

            if [[ $? -eq 0 ]]
            then
                if [[ "${#skippedlist[@]}" -eq 0 ]]
                then
                    msgdone
                else
                    msgwarn "[missing ${skippedlist[*]}]"
                fi

                return 0
            fi
        done

        msgfail
        return 1
    fi
}

function appremove()
{
    appname="$1"
    applist="$2"
    title "Removing $appname"

    remlist=""

    for app in ${applist}
    do
        if ispkginstalled "${app}"
        then
            remlist="${remlist} ${app}"
        fi
    done

    if [[ -z "${remlist}" ]]
    then
        msginfo '[removed]'
        return 0
    else
        DEBIAN_FRONTEND=noninteractive apt purge ${remlist} \
            --yes --force-yes --purge >/dev/null 2>&1

        if [[ $? -eq 0 ]]
        then
            msgdone
            return 0
        else
            msgfail
            return 1
        fi
    fi
}

function appupdate()
{
    title 'Updating package list'

    DEBIAN_FRONTEND=noninteractive apt update \
        -o "DPkg::Options::=--force-confold" --yes --force-yes \
        --allow-releaseinfo-change >/dev/null 2>&1

    if [[ $? -eq 0 ]]
    then
        msgdone
        return 0
    else
        msgfail
        return 1
    fi
}

function appupgrade()
{
    title 'Upgrading packages'

    DEBIAN_FRONTEND=noninteractive apt upgrade \
        -o "DPkg::Options::=--force-confold" \
        --yes --force-yes >/dev/null 2>&1

    if [[ $? -eq 0 ]]
    then
        msgdone
        return 0
    else
        msgfail

        title 'Retrying upgrading packages'

        DEBIAN_FRONTEND=noninteractive apt upgrade \
            -o "DPkg::Options::=--force-confold" \
            --yes --force-yes >/dev/null 2>&1

        if [[ $? -eq 0 ]]
        then
            msgdone
            return 0
        else
            msgfail
            return 1
        fi
    fi
}

function appdistupgrade()
{
    title 'Upgrading distributive'

    DEBIAN_FRONTEND=noninteractive apt dist-upgrade \
        -o "DPkg::Options::=--force-confold" \
        --yes --force-yes >/dev/null 2>&1

    if [[ $? -eq 0 ]]
    then
        msgdone
        return 0
    else
        msgfail
        return 1
    fi
}

### PPA functions ==============================================================

isppaavailable()
{
    local author="$1"
    local repo="$2"

    #### Set default repo name, if not set =====================================

    if [[ -z "${repo}" ]]
    then
        repo='ppa'
    fi

    #### Download PPA page =====================================================

    for i in $(seq 1 3)
    do
        local ppapage=$(wget -q -O - "https://launchpad.net/~${author}/+archive/ubuntu/${repo}")

        if [[ -n "${ppapage}" ]]
        then
            break
        fi

        sleep 1

    done

    if [[ -z "${ppapage}" ]]
    then
        return 2
    fi

    #### Get repo links ========================================================

    local links=$(echo "${ppapage}" | grep '<span id="series-deb' | grep '^deb' | sed 's/<\/a>.*//' | sed 's/<.*>//')

    if [[ -z "${links}" ]]
    then
        return 3
    fi

    #### Get versions ==========================================================

    local version_options=$(echo "${ppapage}" | grep '<option value="[^"]')

    local versions=( $(echo "${version_options}" | cut -d '"' -f 2) )

    local version_count=${#versions[@]}

    #### Find current release --------------------------------------------------

    if [[ -z "${version}" ]]
    then
        for (( index = 0; index < ${version_count}; index++ ))
        do
            if [[ "${versions[$index]}" == "$(lsb_release -cs)" ]]
            then
                return 0
            fi
        done
    fi

    #### =======================================================================

    return 1

}

repoadd()
{
    local reponame="$1"
    local repo="$2"
    local version="$3"
    local sections="$4"
    local keyfile="$5"
    local options="$6"

    title "Adding $reponame repository"

    if [[ -n "${keyfile}" ]]
    then
        cp -f "${ROOT_PATH}/keys/${keyfile}" "/etc/apt/trusted.gpg.d/${keyfile}" >/dev/null 2>&1
        local status=$?

        if [[ $status -ne 0 ]]
        then
            msgfail
            return $status
        fi
    fi

    if [[ -z "$(echo "${repo}" | grep '^[a-zA-Z]*://')" ]]
    then
        repo="http://${repo}"
    fi

    if [[ -n "${options}" ]]
    then
        repo="[${options}] ${repo}"
    fi

    local repofilename="$(echo "${reponame}-${version}" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -d '/.' | sed 's/-$//g')"

    local sourceslist="deb ${repo} ${version} ${sections}"

    echo "${sourceslist}" > "/etc/apt/sources.list.d/${repofilename}.list"
    status=$?

    if [[ $status -eq 0 ]]
    then
        msgdone
    else
        msgfail
    fi

    return $status
}

ppaadd()
{
    local reponame="$1"
    local author="$2"
    local repo="$3"
    local version="$4"
    local istrusted="$5"

    #### Set default repo name, if not set =====================================

    if [[ -z "${repo}" ]]
    then
        repo='ppa'
    fi

    #### Print information =====================================================

    if [[ -n "${istrusted}" ]]
    then
        title "Adding trusted $reponame repository"
    else
        title "Adding $reponame repository"
    fi

    #### Download PPA page =====================================================

    for i in $(seq 1 3)
    do
        local ppapage=$(wget -q -O - "https://launchpad.net/~${author}/+archive/ubuntu/${repo}")

        if [[ -n "${ppapage}" ]]
        then
            break
        fi

        sleep 1

    done

    if [[ -z "${ppapage}" ]]
    then
        msgfail '[download page]'
        return 1
    fi

    #### Get key ===============================================================

    local recvkey=$(echo "${ppapage}" | grep '<code>' | sed 's/.*<code>//' | sed 's/<\/code>.*//' | cut -d '/' -f 2)

    if [[ -z "${recvkey}" ]]
    then
        msgfail '[key]'
        return 2
    fi

    #### Get repo links ========================================================

    local links=$(echo "${ppapage}" | grep '<span id="series-deb' | grep '^deb' | sed 's/<\/a>.*//' | sed 's/<.*>//')

    if [[ -z "${links}" ]]
    then
        msgfail '[links]'
        return 3
    fi

    #### Set repo as trusted, if flag set ======================================

    if [[ -n "${istrusted}" ]]
    then
        links=$(echo "${links}" | sed 's/http:/[trusted=yes\] http:/g')
    fi

    #### Get versions ==========================================================

    local version_options=$(echo "${ppapage}" | grep '<option value="[^"]')

    local versions=( $(echo "${version_options}" | cut -d '"' -f 2) )
    local release_dates=( $(echo "${version_options}" | sed 's/[^(]*//' | sed 's/(//' | sed 's/).*//' | sed 's/^$/00.00/') )

    local version_count=${#versions[@]}

    #### Find current release --------------------------------------------------

    if [[ -z "${version}" ]]
    then
        for (( index = 0; index < ${version_count}; index++ ))
        do
            if [[ "${versions[$index]}" == "$(lsb_release -cs)" ]]
            then
                version="${versions[$index]}"
                break
            fi
        done
    fi

    #### Find most recent release ----------------------------------------------

    if [[ -z "${version}" ]]
    then
        for (( index=0; index<${version_count}; index++ ))
        do
            release_stamp=${release_dates[$index]/./}20

            if [[ $(date +%y%m%d) -gt ${release_stamp} ]]
            then
                version="${versions[$index]}"
                break
            fi
        done
    fi

    #### Use first release -----------------------------------------------------

    if [[ -z "${version}" ]]
    then
        version="${versions[0]}"
    fi

    #### Release not found -----------------------------------------------------

    if [[ -z "${version}" ]]
    then
        msgfail '[no release]'
        return 4
    fi

    #### Add key server ========================================================

    local keyserver=$(echo "${ppapage}" | grep -A2 'Signing key' | grep 'http' | cut -d '"' -f 2 | cut -d ':' -f 2 | cut -d '/' -f 3)

    apt-key adv --keyserver $keyserver --recv $recvkey >/dev/null 2>&1

    if [[ $? -ne 0 ]]
    then
        msgfail '[recv key]'
        return 5
    fi

    #### Add repo ==============================================================

    local sourceslist="$(echo "${links}" | sed "s/$/ ${version} main/" | sed 's/^\([[:space:]]*deb-src[[:space:]]\)/#\1/')"

    echo "${sourceslist}" > "/etc/apt/sources.list.d/${author}-${repo}-${version}.list"

    if [[ $? -ne 0 ]]
    then
        msgfail '[add repo]'
        return 6
    fi

    #### =======================================================================

    msgdone

    return 0
}

function changemirror()
{
    local mirror="$1"

    if [[ -z "${mirror}" ]]
    then
        title 'Change mirror'
        msgfail
        return 1
    fi

    silent "Change mirror to '${mirror}'" sed -i "s/http:\/\/[^\/]*/http:\/\/${mirror}/" /etc/apt/sources.list
}

function repoaddnonfree()
{
    if [[ "$(lsb_release -si)" == "Ubuntu" ]]
    then
        silent 'Clear sources.list'             sed -i 's/ restricted//g;s/ universe//g;s/ multiverse//g'   /etc/apt/sources.list
        silent 'Enabling universe/multiverse'   sed -i 's/main[  ]*$/main restricted universe multiverse/g' /etc/apt/sources.list

    elif [[ "$(lsb_release -si)" == "Debian" ]] && dpkg --compare-versions "$(lsb_release -sr)" ge 12
    then
        silent 'Clear sources.list'         sed -i 's/ non-free-firmware//g;s/ contrib//g;s/ non-free//g' /etc/apt/sources.list
        silent 'Enabling contrib/non-free'  sed -i 's/main[  ]*$/main contrib non-free non-free-firmware/g' /etc/apt/sources.list

    elif [[ "$(lsb_release -si)" == "Debian" ]]
    then
        silent 'Clear sources.list'         sed -i 's/ contrib//g;s/ non-free//g' /etc/apt/sources.list
        silent 'Enabling contrib/non-free'  sed -i 's/main[  ]*$/main contrib non-free/g' /etc/apt/sources.list

    fi
    
    silent 'Removing empty sources' sed -i '/^[  ]*#/d;/^deb[-src]* [ ]*[^ ]* [ ]*[^ ]*[ ]*$/d;/^[ ]*$/d'  /etc/apt/sources.list
}

### Gnome shell extensions functions ===========================================

function isgnomeshellextensioninstalled()
{
    ext="$1"

    test -d "/usr/share/gnome-shell/extensions/${ext}" || test -d "${HOME}/.local/share/gnome-shell/extensions/${ext}"
}

function gnomeshellextension()
{
    local extid="$1"
    local extdescription="$2"
    local condition="$3"
    local extpkg="$4"
    local extname="${extdescription:-#${extid}}"

    ### Check condition --------------------------------------------------------

    if [[ -n "$condition" ]] && ! dpkg --compare-versions "$(pkgversion gnome-shell)" ${condition}
    then
        return 0
    fi

    ### Check extension is available from repository ---------------------------

    if [[ -n "$extpkg" ]] && ispkgavailable "$extpkg"
    then
        appinstall "$extdescription" "$extpkg"
        return $?
    fi

    ### Install from Gnome Shell extensions website ----------------------------

    local shellver=$(dpkg-query -W -f='${Version}\n' gnome-shell | cut -d '.' -f 1-2 | cut -d '~' -f 1 | cut -d '-' -f 1 | cut -d '+' -f 1)
    local server='https://extensions.gnome.org'
    local installdir='/usr/share/gnome-shell/extensions'

    if dpkg --compare-versions "${shellver}" ge 40
    then
        local shellver="${shellver%%.*}"
    else
        local shellver="${shellver%%.*}.$(( ${shellver##*.} - ${shellver##*.} % 2 ))"
    fi

    if [[ -z "${shellver}" ]]
    then
        title "Downloading extension ${extname}"
        msgfail 'shell not installed'
        return 1
    fi

    local extinfo=$(wget "${server}/extension-info/?pk=${extid}&shell_version=${shellver}" -q -O -)

    if [[ $? -ne 0 ]]
    then
        title "Downloading extension ${extname}"
        msgfail
        return 1
    fi

    unset packages_to_remove
    local -a packages_to_remove

    if ! ispkginstalled jq
    then
        apptmpinstall 'JSON processor' jq || return 1
    fi

    local ext_name=$(echo "${extinfo}" | jq -r '.name')
    local ext_uuid=$(echo "${extinfo}" | jq -r '.uuid')
    local ext_durl=$(echo "${extinfo}" | jq -r '.download_url')

    title "Downloading ${ext_name:-${extname}}"

    if [[ -z "${ext_uuid}" || -z "${ext_durl}" ]]
    then
        msgfail
        return 1
    fi

    if ! wget -O /tmp/extension.zip "https://extensions.gnome.org/${ext_durl}" >/dev/null 2>&1
    then
        msgfail
        return 1
    fi

    if ! rm -rf "${installdir}/${ext_uuid}"
    then
        msgfail '[remove dir]'
        rm -f /tmp/extension.zip
        return 1
    fi


    if ! mkdir -p "${installdir}/${ext_uuid}"
    then
        msgfail '[create dir]'
        rm -f /tmp/extension.zip
        return 1
    fi


    if ! unzip /tmp/extension.zip -d "${installdir}/${ext_uuid}" >/dev/null 2>&1
    then
        msgfail '[unzip]'
        rm -f /tmp/extension.zip
        return 1
    fi

    rm -f /tmp/extension.zip

    if ! chmod -R a+r "${installdir}/${ext_uuid}" >/dev/null 2>&1
    then
        msgfail '[chmod]'
        return 1
    fi

    msgdone

    ### Fix missing GLib compiled schema =======================================

    if [[ -d "${installdir}/${ext_uuid}/schemas" && ! -f "${installdir}/${ext_uuid}/schemas/gschemas.compiled" ]]
    then
        silent 'Compile schema' glib-compile-schemas "${installdir}/${ext_uuid}/schemas"
    fi

    ### ========================================================================

    return 0
}

### Silent exec functions ======================================================

function silent()
{
    local cmdtitle="$1"
    shift

    [[ -n "${cmdtitle}" ]] && title "${cmdtitle}"

    "$@" >/dev/null 2>&1

    if [[ $? -eq 0 ]]
    then
        [[ -n "${cmdtitle}" ]] && msgdone
        return 0
    else
        [[ -n "${cmdtitle}" ]] && msgfail
        return 1
    fi
}

function silent_fail()
{
    local cmdtitle="$1"
    shift

    "$@" >/dev/null 2>&1

    if [[ $? -eq 0 ]]
    then
        return 0
    else
        [[ -n "${cmdtitle}" ]] && title "${cmdtitle}"
        [[ -n "${cmdtitle}" ]] && msgfail

        return 1
    fi
}

### Bundles ===================================================================

function bundle()
{
    local command="$1"

    shift

    case "${command}" in

    "repo")
        bash "${ROOT_PATH}/bundles/repo.sh" "$@"
        return $?
    ;;

    "install")
        bash "${ROOT_PATH}/bundles/install.sh" "$@"
        return $?
    ;;

    "prepare")
        bash "${ROOT_PATH}/bundles/prepare.sh" "${config}" "${rootfs_dir}" "$@"
        return $?
    ;;

    "config")
        bash "${ROOT_PATH}/bundles/config.sh" "$@"
        return $?
    ;;

    "firstboot")
        bash "${ROOT_PATH}/bundles/firstboot.sh" "$@"
        return $?
    ;;

    "firstbootuser")
        bash "${ROOT_PATH}/bundles/firstbootuser.sh"  "$@"
        return $?
    ;;

    "user")
        bash "${ROOT_PATH}/bundles/user.sh" "$@"
        return $?
    ;;

    *)
        msgfail '[unknown command]'
        return -1
    ;;

    esac

}

function bundlelist()
{
    echo
    title "Checking bundles:"

    action=install
    bundle_list=$(grep '^[ \t]*"[a-z0-9,/-]*")' "${ROOT_PATH}/bundles/${action}.sh" | cut -d '"' -f 2)

    ### Check all actions have same bundles ====================================

    for action in prepare config firstboot user
    do

        bundle_list_action=$(grep '^[ \t]*"[a-z0-9,/-]*")' "${ROOT_PATH}/bundles/${action}.sh" | cut -d '"' -f 2)

        if ! diff <(echo "${bundle_list}") <(echo "${bundle_list_action}")
        then
            msgfail "bundle ${action} differs from install"
            return 1
        fi

    done

    msgdone

    ### Print used bundles =====================================================

    echo "Used bundles:"

    bundle_used=$(cat "${ROOT_PATH}/custom/tools/${config}.bundle" | sed '/^[[:space:]]*$/d' | sed '/^[[:space:]]*\#$/d' )

    for bundle in ${bundle_list}
    do
        bundlelevel=$(echo "${bundle}" | grep -o '/' | wc -l)

        for i in $(seq 1 ${bundlelevel})
        do
            echo -n ' '
        done

        if [[ -n "$(echo "${bundle_used}" | grep "^${bundle}$")" ]]
        then
            msgdone " + ${bundle}"
        else

            if [[ ${bundlelevel} -gt 0 ]]
            then
                for i in $(seq 1 $((bundlelevel+1)) )
                do
                    if [[ ${i} -eq $((bundlelevel+1)) ]]
                    then
                        msgwarn " - ${bundle}"
                        break
                    fi

                    bundle_parent=$(echo ${bundle} | cut -d '/' -f 1-${i})

                    if [[ -n "$(echo "${bundle_used}" | grep "^${bundle_parent}$")" ]]
                    then
                        msgdone " + ${bundle}"
                        break;
                    fi
                done
            else
                msgwarn " - ${bundle}"
            fi
            
            
        fi
    done

    ## Check for wrong bundles =================================================

    for bundle in ${bundle_used}
    do
        if [[ -z "$(echo "${bundle_list}" | grep "^${bundle}$")" ]]
        then
            msgfail " ! ${bundle}"
        fi
    done

    #### =======================================================================

    return 0
}

### SystemD service functions ==================================================

function addservice()
{
    local srvdesc="$1"
    local srvname="$2"
    local srvpath="$3"

    if [[ -f "${ROOT_PATH}/files/${srvpath}/${srvname}.service" || ! -f "/etc/systemd/system/${srvname}.service" ]]
    then
        silent "Creating ${srvdesc} service"   cp -f "${ROOT_PATH}/files/${srvpath}/${srvname}.service" '/etc/systemd/system/' || return 1
    fi

    for target in $(grep '^WantedBy' "/etc/systemd/system/${srvname}.service" | cut -d '=' -f 2 | tr ' ' '\n')
    do
        silent " Creating ${target//.*} target" mkdir -p "/etc/systemd/system/${target}.wants"
        silent " Enabling ${srvdesc} for ${target//.target}" ln -s "/etc/systemd/system/${srvname}.service" "/etc/systemd/system/${target}.wants/${srvname}.service" || return 1
    done

    for target in $(grep '^RequiredBy' "/etc/systemd/system/${srvname}.service" | cut -d '=' -f 2 | tr ' ' '\n')
    do
        silent " Creating ${target//.*} target" mkdir -p "/etc/systemd/system/${target}.requires"
        silent " Enabling ${srvdesc} for ${target//.target}" ln -s "/etc/systemd/system/${srvname}.service" "/etc/systemd/system/${target}.requires/${srvname}.service" || return 1
    done

    return 0
}

function disableservice()
{
    local srvdesc="$1"
    local srvname="$2"

    if [[ -f "/etc/systemd/system/${srvname}.service" ]]
    then
        local location="/etc/systemd/system"

    elif [[ -f "/lib/systemd/system/${srvname}.service" ]]
    then
        local location="/lib/systemd/system"
    else
        return 1
    fi

    for target in $(grep '^WantedBy' "${location}/${srvname}.service" | cut -d '=' -f 2 | tr ' ' '\n')
    do
        silent "Disabling ${srvdesc} for ${target//.target}" unlink "/etc/systemd/system/${target}.wants/${srvname}.service"
    done

    for target in $(grep '^RequiredBy' "${location}/${srvname}.service" | cut -d '=' -f 2 | tr ' ' '\n')
    do
        silent "Disabling ${srvdesc} for ${target//.target}" unlink "/etc/systemd/system/${target}.requires/${srvname}.service"
    done

    return 0
}


### Desktop environment detection functions ====================================

function havegraphics()
{
    if ispkginstalled 'xserver-xorg'
    then
        return 0
    else
        return 1
    fi
}

function gnomebased()
{
    if ispkginstalled 'gnome-shell' || ispkginstalled 'cinnamon'
    then
        return 0
    else
        return 1
    fi
}

### DConf functions ============================================================

dconfclear()
{
    local category="$1"
    local setting="$2"

    dconf write "${category}/${setting}" '@as []'
}

dconfadd()
{
    local category="$1"
    local setting="$2"
    local value="$3"

    local valuelist=$(dconf read "${category}/${setting}" | sed "s/\['//g" | sed "s/'\]//g" | sed "s/'\, '/\n/g" | sed '/@as \[\]/d')

    if [[ -n "$(echo "${valuelist}" | grep ^${value}$)" ]]
    then
        return 0
    fi

    if [[ -n "${valuelist}" ]]
    then
        valuelist="${valuelist}
"
    fi

    valuelist="${valuelist}${value}"

    local newvalue="[$(echo "$valuelist" | sed "s/^/'/;s/$/'/" | tr '\n' '\t' | sed 's/\t$//' | sed 's/\t/, /g')]"

    dconf write "${category}/${setting}" "${newvalue}"
}

### Gsettings functions ========================================================

gsettingsclear()
{
    local category="$1"
    local setting="$2"

    gsettings set ${category} ${setting} '[]'
}

gsettingsadd()
{
    local category="$1"
    local setting="$2"
    local value="$3"

    local valuelist=$(gsettings get $category $setting | sed "s/\['//g" | sed "s/'\]//g" | sed "s/'\, '/\n/g" | sed '/@as \[\]/d')

    if [[ -n "$(echo "${valuelist}" | grep ^${value}$)" ]]
    then
        return 0
    fi

    if [[ -n "${valuelist}" ]]
    then
        valuelist="${valuelist}
"
    fi

    valuelist="${valuelist}${value}"

    local newvalue="[$(echo "$valuelist" | sed "s/^/'/;s/$/'/" | tr '\n' '\t' | sed 's/\t$//' | sed 's/\t/, /g')]"

    gsettings set $category $setting "${newvalue}"
}

### Application menu functions =================================================

function hideapp()
{
    local app="$1"
    local localapppath="${HOME}/.local/share/applications/${app}.desktop"
    local apppath=""

    if [[ -f "${HOME}/.local/share/applications/${app}.desktop" ]]
    then
        apppath="${HOME}/.local/share/applications"

    elif [[ -f "/usr/local/share/applications/${app}.desktop" ]]
    then
        apppath='/usr/local/share/applications'

    elif [[ -f "/usr/share/applications/${app}.desktop" ]]
    then
        apppath='/usr/share/applications'

    else
        return 0
    fi

    if [[ -z "$(getconfigline 'MimeType' 'Desktop Entry' "$localapppath")" ]] && [[ "$(getconfigline 'NoDisplay' 'Desktop Entry' "$localapppath")" == 'true' ]]
    then
        return 0
    fi

    mkdir -p "${HOME}/.local/share/applications/"

    if [[ "${apppath}" != "${HOME}/.local/share/applications" ]]
    then
        cp -f "${apppath}/${app}.desktop" "$localapppath"
    fi

    addconfigline 'NoDisplay' 'true' 'Desktop Entry' "$localapppath"

    if [[ -n "$(getconfigline 'MimeType' 'Desktop Entry' "$localapppath")" ]]
    then
        addconfigline 'MimeType' '' 'Desktop Entry' "$localapppath"
    fi

    if which update-desktop-database >/dev/null 2>/dev/null
    then
        update-desktop-database "${HOME}/.local/share/applications/"
    fi

    return 0
}

ishidden()
{
    local app="$1"
    local apppath=""

    if [[ -f "${HOME}/.local/share/applications/${app}.desktop" ]]
    then
        apppath="${HOME}/.local/share/applications"

    elif [[ -f "/usr/local/share/applications/${app}.desktop" ]]
    then
        apppath='/usr/local/share/applications'

    elif [[ -f "/usr/share/applications/${app}.desktop" ]]
    then
        apppath='/usr/share/applications'

    else
        return 0
    fi

    grep '^[[:space:]]*NoDisplay[[:space:]]*=[[:space:]]*true[[:space:]]*$' "${apppath}/${app}.desktop" >/dev/null 2>/dev/null
}

### Launcher functions =========================================================

function launcherclear()
{
    if ispkginstalled gnome-shell
    then
        gsettings set org.gnome.shell favorite-apps '[]'
    fi

    if ispkginstalled cinnamon
    then
        gsettings set org.cinnamon favorite-apps '[]'
    fi

}

function launcheradd_var()
{
    application="$1"
    launcher="$2"
    favname="$3"

    applist=$(gsettings get $launcher $favname | sed "s/\['//g" | sed "s/'\]//g" | sed "s/'\, '/\n/g" | sed '/unity:/d' | sed "s/.*:\/\///g" | sed "s/.desktop//g")

    if [[ -z "$(echo "$applist" | grep "^${application}.desktop$")" ]]
    then
        applist="${applist}
${application}"

        newlauncher="["

        let isfirst=1

        for app in $applist
        do
            if [[ ${isfirst} -gt 0 ]]
            then
                let isfirst=0
            else
                newlauncher="${newlauncher}, "
            fi

            newlauncher="$newlauncher'${app}.desktop'"
        done

        newlauncher="${newlauncher}]"

        gsettings set $launcher $favname "${newlauncher}"

    fi
}

launcheradd()
{
    local application="$1"

    if ishidden "$application" && [[ "$2" != '--force' ]]
    then
        return 0
    fi

    if ispkginstalled gnome-shell
    then
        launcheradd_var "$application" 'org.gnome.shell' 'favorite-apps'
    fi

    if ispkginstalled cinnamon
    then
        launcheradd_var "$application" 'org.cinnamon' 'favorite-apps'
    fi

}

### Custom keybindings =========================================================

function addkeybinding()
{
    local name="$1"
    local command="$2"
    local binding="$3"


    if ispkginstalled gnome-shell
    then
        cmd="$(echo "${command}" | md5sum | cut -d ' ' -f 1)"
        path="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/${cmd}/"

        gsettings set "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:${path}" name    "${name}"
        gsettings set "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:${path}" command "${command}"
        gsettings set "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:${path}" binding "${binding}"

        gsettingsadd org.gnome.settings-daemon.plugins.media-keys custom-keybindings "${path}"
    fi

    if ispkginstalled cinnamon
    then
        cmd="$(echo "${command}" | md5sum | cut -d ' ' -f 1)"
        path="/org/cinnamon/desktop/keybindings/custom-keybindings/${cmd}/"

        gsettings set "org.cinnamon.desktop.keybindings.custom-keybinding:${path}" name    "${name}"
        gsettings set "org.cinnamon.desktop.keybindings.custom-keybinding:${path}" command "${command}"
        gsettings set "org.cinnamon.desktop.keybindings.custom-keybinding:${path}" binding "['${binding}']"

        gsettingsadd org.cinnamon.desktop.keybindings custom-list "${cmd}"
    fi
}

function addscenario()
{
    local name="$1"
    local binding="$2"
    local command="$3"
    local fixpwd="$4"

    if ispkginstalled 'nautilus'
    then
        mkdir -p "${HOME}/.local/share/nautilus/scripts"
        mkdir -p "${HOME}/.config/nautilus"
        touch    "${HOME}/.config/nautilus/scripts-accels"

        echo -e '#!/bin/bash\n' >  "${HOME}/.local/share/nautilus/scripts/${name}.sh"

        if [[ -n "${fixpwd}" ]]
        then
            echo -e 'cd "$(echo "$NAUTILUS_SCRIPT_CURRENT_URI" | sed "s@+@ @g;s@%@\\\\\\\\x@g" | xargs -0 printf "%b" | sed "s/^file:\/\///")"\n' >> "${HOME}/.local/share/nautilus/scripts/${name}.sh"
        fi

        echo -e "${command}\n"  >> "${HOME}/.local/share/nautilus/scripts/${name}.sh"
        chmod +x                   "${HOME}/.local/share/nautilus/scripts/${name}.sh"

        sed -i "/^${binding} /d"        "${HOME}/.config/nautilus/scripts-accels"
        echo "${binding} ${name}.sh" >> "${HOME}/.config/nautilus/scripts-accels"
    fi

    if ispkginstalled 'nemo'
    then
        mkdir -p "${HOME}/.local/share/nemo/scripts"
        mkdir -p "${HOME}/.config/nemo"
        touch    "${HOME}/.config/nemo/scripts-accels"

        echo -e '#!/bin/bash\n' >  "${HOME}/.local/share/nemo/scripts/${name}.sh"

        if [[ -n "${fixpwd}" ]]
        then
            echo -e 'cd "$(echo "$NEMO_SCRIPT_CURRENT_URI" | sed "s@+@ @g;s@%@\\\\\\\\x@g" | xargs -0 printf "%b" | sed "s/^file:\/\///")"\n' >> "${HOME}/.local/share/nemo/scripts/${name}.sh"
        fi

        echo -e "${command}\n"  >> "${HOME}/.local/share/nemo/scripts/${name}.sh"
        chmod +x                   "${HOME}/.local/share/nemo/scripts/${name}.sh"

        sed -i "/^${binding} /d"        "${HOME}/.config/nemo/scripts-accels"
        echo "${binding} ${name}.sh" >> "${HOME}/.config/nemo/scripts-accels"
    fi
}

### Register MIME types ========================================================

getconfigline()
{
    local key="$1"
    local section="$2"
    local file="$3"

    if [[ -r "$file" ]]
    then
        sed -n "/^[ \t]*\[$(safestring "${section}")\]/,/^[ \t]*\[/s/^[ \t]*$(safestring "${key}")[ \t]*=[ \t]*//p" "${file}"
    fi
}

addconfigline()
{
    local key="$1"
    local value="$2"
    local section="$3"
    local file="$4"

    if ! grep -F "[${section}]" "$file" 1>/dev/null 2>/dev/null
    then
        mkdir -p "$(dirname "$file")"

        echo >> "$file"

        echo "[${section}]" >> "$file"
    fi

    sed -i "/^[[:space:]]*\[${section}\][[:space:]]*$/,/^[[:space:]]*\[.*/{/^[[:space:]]*$(safestring "${key}")[[:space:]]*=/d}" "$file"

    sed -i "/\[${section}\]/a $(safestring "${key}=${value}")" "$file"

    if [[ -n "$(tail -c1 "${file}")" ]]
    then
        echo >> "${file}"
    fi
}

prependconfigline()
{
    local key="$1"
    local value="$2"
    local section="$3"
    local file="$4"

    local newvalue="$value;$(getconfigline "$key" "$section" "$file" | tr ';' '\n' | grep -v "^${value}$" | grep -v '^$' | tr '\n' ';')"

    if [[ "${newvalue: -1}" != ';' ]]
    then
        newvalue="${newvalue};"
    fi

    addconfigline "$key" "$newvalue" "$section" "$file"

}

appendconfigline()
{
    local key="$1"
    local value="$2"
    local section="$3"
    local file="$4"

    local newvalue="$(getconfigline "$key" "$section" "$file" | tr ';' '\n' | grep -v "^${value}$" | grep -v '^$' | tr '\n' ';' | sed 's/;$//');${value};"

    if [[ "${newvalue:0:1}" == ';' ]]
    then
        newvalue="${newvalue:1}"
    fi

    addconfigline "$key" "$newvalue" "$section" "$file"
}

mimeregister()
{
    local mime="$1"
    local app="$2"

    prependconfigline "${mime}" "${app}" 'Added Associations' "${HOME}/.config/mimeapps.list"
}

setdefaultapp()
{
    local mime="$1"
    local app="$2"

    addconfigline "${mime}" "${app}" 'Default Applications' "${HOME}/.config/mimeapps.list"
}

getmimelist()
{
    local app="$1"

    for location in "${HOME}/.local/share/applications/" "/usr/local/share/applications/" "/usr/share/applications/"
    do
        local file="${location}/${app}.desktop"

        if [[ -f "$file" ]]
        then
            getconfigline 'MimeType' 'Desktop Entry' "$file"
            break
        fi
    done
}

mimedefault()
{
    local app="$1"
    local type="$2"

    shift
    shift

    for mime in $(getmimelist "${app}" | tr ';' ' ')
    do
        if [[ -n "${type}" && "${type}" != "${mime%%/*}" ]]
        then
            continue
        fi

        mimeregister  "$mime" "${app}.desktop"

        for ignore
        do
            if [[ "${mime}" == "${ignore}" ]]
            then
                continue 2
            fi
        done

        setdefaultapp "$mime" "${app}.desktop"
    done
}

### Add bookmark ===============================================================

function addbookmark()
{
    path="$1"
    name="$2"

    mkdir -p "${HOME}/.config/gtk-3.0/"

    touch "${HOME}/.config/gtk-3.0/bookmarks"

    sed -i "/$(safestring "${path} ")/d" "${HOME}/.config/gtk-3.0/bookmarks"

    echo "${path} ${name}" >> "${HOME}/.config/gtk-3.0/bookmarks"
}

### File system ================================================================

fixpermissions()
{
    local dir="$1"
    local newuid="$2"
    local newgid="$3"

    if [[ -z "$newgid" ]]
    then
        newgid="$newuid"
    fi

    olduid="$(stat --printf="%u" "$dir")"
    oldgid="$(stat --printf="%g" "$dir")"

    if [[ $newuid -ne $olduid ]]
    then
        find "$dir" -uid "$olduid" -exec chown "$newuid" {} \;
    fi

    if [[ $newgid -ne $oldgid ]]
    then
        find "$dir" -gid "$oldgid" -exec chown ":$newgid" {} \;
    fi
}

### Kernel version =============================================================

kernellist()
{
    local kerneltype=any

    for var in "$@"
    do
        case "$var" in
        '--with-headers')
            kerneltype=with-headers
            ;;
        '--dkms')
            kerneltype=dkms
            ;;
        *)
            echo "Unknown option ${var}" >&2
            ;;
        esac
    done


    local kernelpackages="$(dpkg -l | grep 'ii[[:space:]]\+linux-image-' | \
                                awk '{print $2}' | \
                                cut -d '-' -f 3- | \
                                grep -v '^generic$')"

    local -a result

    for kernel in $kernelpackages
    do

        case "$kerneltype" in
        'with-headers')
            test -d "/usr/src/linux-headers-$kernel"
            ;;
        'dkms')
            test -f "/usr/src/linux-headers-$kernel/.config"
            ;;
        *)
            true
            ;;
        esac

        if [[ $? -eq 0 ]]
        then
            result+=( "$kernel" )
        fi

    done

    echo ${result[*]}
}

dkmsinstall()
{
    local -a modules=( $(find /var/lib/dkms -mindepth 1 -maxdepth 1 -type d -exec basename {} \;) )
    local modules_count=${#modules[@]}

    local -a kernels=( $(kernellist --dkms) )
    local kernels_count=${#kernels[@]}

    for (( m = 0; m < modules_count; m++))
    do
        for (( k = 0; k < kernels_count; k++ ))
        do
            local -a versions=( $(find "/var/lib/dkms/${modules[$m]}" -mindepth 2 -maxdepth 2 -name 'source' -exec dirname {} \;  | xargs basename -a) )
            local versions_count=${#versions[@]}

            for (( v = 0; v < versions_count; v++))
            do
                if [[ -z "$(dkms status "${modules[$m]}/${versions[$v]}" -k "${kernels[$k]}" | grep ': installed$')" ]]
                then
                    silent "Build ${modules[$m]} v${versions[$v]} for ${kernels[$k]}" dkms build "${modules[$m]}/${versions[$v]}" -k "${kernels[$k]}"
                    silent "Install ${modules[$m]} v${versions[$v]} for ${kernels[$k]}" dkms install "${modules[$m]}/${versions[$v]}" -k "${kernels[$k]}"
                fi
            done
        done
    done
}
