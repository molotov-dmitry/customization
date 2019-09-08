#!/bin/bash

### constants ==================================================================

readonly CL_RED='\e[91m'
readonly CL_YELLOW='\e[93m'
readonly CL_GREEN='\e[92m'
readonly CL_BLUE='\e[94m'

readonly TITLE_LENGTH=50
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
    echo -n "$title"
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
    [[ -n "$1" ]] && msg="$1" || msg='[done]'

    message "$msg" "$CL_GREEN"

    return 0
}

function msginfo()
{
    [[ -n "$1" ]] && msg="$1" || msg='[info]'

    message "$msg" "$CL_BLUE"

    return 0
}

function msgwarn()
{
    [[ -n "$1" ]] && msg="$1" || msg='[warn]'

    message "$msg" "$CL_YELLOW"

    return 0
}

function msgfail()
{
    [[ -n "$1" ]] && msg="$1" || msg='[fail]'

    message "$msg" "$CL_RED"

    return 0
}

### Strings ====================================================================

function safestring()
{
    inputstr="$1"

    echo "${inputstr}" | sed 's/\//\\\//g'
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

### Packages ===================================================================

function debconfselect()
{
    package="$1"
    selection="$2"
    value="$3"

    sh -c "echo ${package} ${selection} select ${value} | debconf-set-selections"
}

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

function debprepare()
{
    appname="$1"
    debname="$2"
    debversion="$3"
    debarch="$4"

    debpath="${ROOT_PATH}/packages/${debname}_${debversion}_${debarch}.deb"

    mkdir -p "${rootfs_dir}/tools/packages"

    silent "Copy ${appname} package" cp -f "${debpath}" "${rootfs_dir}/tools/packages/"
}

function debinstall()
{
    appname="$1"
    debname="$2"
    debversion="$3"
    debarch="$4"

    if [[ -z "${debversion}" ]]
    then
        pushd "${ROOT_PATH}/packages" > /dev/null

        debversion=$(ls ${debname}_*_${debarch}.deb | sort | tail -n 1 | cut -d '_' -f 2)

        popd > /dev/null
    fi

    debpath="${ROOT_PATH}/packages/${debname}_${debversion}_${debarch}.deb"

    title "Installing $appname"

    if ! ispkginstalled "${debname}"
    then
        dpkg -i "${debpath}" >/dev/null 2>&1

        if [[ $? -eq 0 ]]
        then
            msgdone
            return 0
        else
            DEBIAN_FRONTEND=noninteractive apt-get install -f --yes --force-yes >/dev/null 2>&1

            if [[ $? -eq 0 ]] && ispkginstalled "${debname}"
            then
                msgdone
                return 0
            else
                msgfail
                return 1
            fi
        fi
    else
        msgwarn '[already installed]'
        return 0
    fi
}

function appinstall()
{
    appname="$1"
    applist="$2"
    title "Installing $appname"

    installlist=""

    missinglist=""
    skippedlist=""

    for app in ${applist}
    do
        if [[ "$app" == "["*"]" ]]
        then
            appname=${app:1:-1}
            let required=0
        else
            appname=$app
            let required=1
        fi

        if ispkginstalled "${appname}"
        then
            continue
            #
        fi

        if ispkgavailable "${appname}"
        then
            installlist="${installlist} ${appname}"
        #
        elif [[ $required -gt 0 ]]
        then
            missinglist="${missinglist} ${appname}"
        #
        else
            skippedlist="${skippedlist} ${appname}"
        #
        fi

    done

    if [[ -n "${missinglist}" ]]
    then
        msgfail "[missing ${missinglist}]"
        return 1
    fi

    if [[ -z "${installlist}" ]]
    then
        msgwarn '[installed]'
        return 0
    else
        export DEBIAN_FRONTEND=noninteractive
        export DEBIAN_PRIORITY=critical

        DEBIAN_FRONTEND=noninteractive apt-get install $installlist -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold" --yes --force-yes --no-install-recommends >/dev/null 2>&1

        if [[ $? -eq 0 ]]
        then
            if [[ -z "${skippedlist}" ]]
            then
                msgdone
            else
                msgwarn "[missing ${skippedlist}]"
            fi

            return 0
        else
            msgfail
            title "Retrying installing $appname"

            DEBIAN_FRONTEND=noninteractive apt-get install $installlist -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold" --yes --force-yes --no-install-recommends >/dev/null 2>&1

            if [[ $? -eq 0 ]]
            then
                if [[ -z "${skippedlist}" ]]
                then
                    msgdone
                else
                    msgwarn "[missing ${skippedlist}]"
                fi

                return 0
            else
                msgfail
                return 1
            fi
        fi
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
        msgwarn '[removed]'
        return 0
    else
        apt-get purge ${remlist} --yes --force-yes --purge >/dev/null 2>&1

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

    apt-get update >/dev/null 2>&1

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

    DEBIAN_FRONTEND=noninteractive apt-get upgrade --yes --force-yes >/dev/null 2>&1

    if [[ $? -eq 0 ]]
    then
        msgdone
        return 0
    else
        msgfail

        title 'Retrying upgrading packages'

        DEBIAN_FRONTEND=noninteractive apt-get upgrade --yes --force-yes >/dev/null 2>&1

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

    DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade --yes --force-yes >/dev/null 2>&1

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

function isppaadded()
{
    author="$1"
    repo="$2"

    count=$(grep -h ^ /etc/apt/sources.list /etc/apt/sources.list.d/* 2> /dev/null | grep -v list.save | grep -v deb-src | grep -v '#deb' | grep deb | grep "/${author}/${repo}" | wc -l)

    if [[ count -gt 0 ]]
    then
        return 0
    else
        return 1
    fi

    return 0
}

function repoadd()
{
    reponame="$1"
    repo="$2"
    version="$3"
    sections="$4"
    keyfile="$5"
    options="$6"

    title "Adding $reponame repository"

    apt-key add "${ROOT_PATH}/files/${keyfile}" >/dev/null 2>&1
    status=$?

    if [[ $status -ne 0 ]]
    then
        msgfail
        return $status
    fi

    if [[ -z "${sections}" ]]
    then
        sections='main'
    fi

    if [[ -z "$(echo "${repo}" | grep '^[a-zA-Z]*://')" ]]
    then
        repo="http://${repo}"
    fi

    if [[ -n "${options}" ]]
    then
        repo="[${options}] ${repo}"
    fi

    repofilename="$(echo "${reponame}" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')"

    sourceslist="deb ${repo} ${version} ${sections}"

    echo "${sourceslist}" > "/etc/apt/sources.list.d/${repofilename}-${version}.list"
    status=$?

    if [[ $status -eq 0 ]]
    then
        msgdone
    else
        msgfail
    fi

    return $status
}

function ppaadd()
{
    reponame="$1"
    author="$2"
    repo="$3"
    version="$4"
    istrusted="$5"

    ### Set default repo name, if not set ======================================

    if [[ -z "${repo}" ]]
    then
        repo='ppa'
    fi

    ### Print information ======================================================

    if [[ -n "${istrusted}" ]]
    then
        title "Adding trusted $reponame repository"
    else
        title "Adding $reponame repository"
    fi

    ### Download PPA page ======================================================

    for i in $(seq 1 3)
    do
        ppapage=$(wget -q -O - "https://launchpad.net/~${author}/+archive/ubuntu/${repo}")

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

    ### Get key ================================================================

    recvkey=$(echo "${ppapage}" | grep '<code>' | sed 's/.*<code>//' | sed 's/<\/code>.*//' | cut -d '/' -f 2)

    if [[ -z "${recvkey}" ]]
    then
        msgfail '[key]'
        return 2
    fi

    ### Get repo links =========================================================

    links=$(echo "${ppapage}" | grep '<span id="series-deb' | grep '^deb' | sed 's/<\/a>.*//' | sed 's/<.*>//')

    if [[ -z "${links}" ]]
    then
        msgfail '[links]'
        return 3
    fi

    ### Set repo as trusted, if flag set =======================================

    if [[ -n "${istrusted}" ]]
    then
        links=$(echo "${links}" | sed 's/http:/[trusted=yes\] http:/g')
    fi

    ### Get versions ===========================================================

    version_options=$(echo "${ppapage}" | grep '<option value="[^"]')

    versions=( $(echo "${version_options}" | cut -d '"' -f 2) )
    release_dates=( $(echo "${version_options}" | sed 's/[^(]*//' | sed 's/(//' | sed 's/).*//' | sed 's/^$/00.00/') )

    version_count=${#versions[@]}

    ### Find current release ---------------------------------------------------

    if [[ -z "${version}" ]]
    then
        for (( index=0; index<${version_count}; index++ ))
        do
            if [[ "${versions[$index]}" == "$(lsb_release -cs)" ]]
            then
                version="${versions[$index]}"
                break
            fi
        done
    fi

    ### Find most recent release -----------------------------------------------

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

    ### Use first release ------------------------------------------------------

    if [[ -z "${version}" ]]
    then
        version="${versions[0]}"
    fi

    ### Release not found ------------------------------------------------------

    if [[ -z "${version}" ]]
    then
        msgfail '[no release]'
        return 4
    fi

    ### Add key server =========================================================

    keyserver=$(echo "${ppapage}" | grep -A2 'Signing key' | grep 'http' | cut -d '"' -f 2 | cut -d ':' -f 2 | cut -d '/' -f 3)

    apt-key adv --keyserver $keyserver --recv $recvkey >/dev/null 2>&1

    if [[ $? -ne 0 ]]
    then
        msgfail '[recv key]'
        return 5
    fi

    ### Add repo ===============================================================

    sourceslist="$(echo "${links}" | sed "s/$/ ${version} main/")"

    echo "${sourceslist}" > "/etc/apt/sources.list.d/${author}-${repo}-${version}.list"

    if [[ $? -ne 0 ]]
    then
        msgfail '[add repo]'
        return 6
    fi

    ### ========================================================================

    msgdone

    return 0
}

function changemirror()
{
    mirror="$1"

    if [[ -z "${mirror}" ]]
    then
        title 'Changing mirror'
        msgfail
        return 1
    fi

    if [[ "$(lsb_release -si)" == "Ubuntu" ]]
    then
        current_mirror=$(cat /etc/apt/sources.list | grep '^deb' | grep -v updates | grep -v 'backports' | sed -r 's/[[:blank:]]*deb(\-src)?[[:blank:]]*//' | cut -d ' ' -f 1 | sed 's/.*:\/\///' | cut -d '/' -f 1 | head -n1)

        if [[ -z "${current_mirror}" ]]
        then
            title 'Changing mirror'
            msgfail
            return 2
        fi

        silent "Changing mirror '${current_mirror}' to '${mirror}'" sed -i "s/${current_mirror}/${mirror}/g" /etc/apt/sources.list

        return $?

    elif [[ "$(lsb_release -si)" == "LinuxMint" ]]
    then
        mirror_mint=$(grep '^deb' /etc/apt/sources.list.d/official-package-repositories.list | grep 'id:linuxmint_main' | sed -r 's/[[:blank:]]*deb(\-src)?[[:blank:]]*//' | cut -d ' ' -f 1 | sed 's/.*:\/\///' | cut -d '/' -f 1 | head -n1)

        if [[ -z "${mirror_mint}" ]]
        then
            title 'Changing mirror'
            msgfail
            return 2
        fi

        silent "Changing mirror '${mirror_mint}' to '${mirror}'" sed -i "s/${mirror_mint}/${mirror}\/linuxmint-packages/g" /etc/apt/sources.list.d/official-package-repositories.list



        mirrors_ubuntu=$(grep '^deb' /etc/apt/sources.list.d/official-package-repositories.list | grep -v 'id:linuxmint_main' | grep -v 'partner' | sed -r 's/[[:blank:]]*deb(\-src)?[[:blank:]]*//' | cut -d ' ' -f 1 | sed 's/.*:\/\///' | cut -d '/' -f 1 | uniq)

        for mirror_ubuntu in ${mirrors_ubuntu}
        do
            silent "Changing mirror '${mirror_ubuntu}' to '${mirror}'" sed -i "s/${mirror_ubuntu}/${mirror}/g" /etc/apt/sources.list.d/official-package-repositories.list
        done

        return $?

    fi

}

function changerelease()
{
    release="$1"
    current_release=$(cat /etc/apt/sources.list | grep '^deb' | cut -d ' ' -f 3 | grep -v updates | grep -v 'backports' | grep -v 'security' | head -n1)

    if [[ -z "${release}" ]]
    then
        title 'Changing release'
        msgfail
        return 1
    fi

    if [[ -z "${current_release}" ]]
    then
        title 'Changing release'
        msgfail
        return 2
    fi

    silent "Changing release '${current_release}' to '${release}'" sed -i "s/${current_release}/${release}/g" /etc/apt/sources.list

    return $?
}

function repoaddnonfree()
{
    if [[ "$(lsb_release -si)" == "Ubuntu" ]]
    then
        silent 'Clear sources.list'             sed -i 's/ restricted//g;s/ universe//g;s/ multiverse//g'   /etc/apt/sources.list
        silent 'Enabling universe/multiverse'   sed -i 's/main[  ]*$/main restricted universe multiverse/g' /etc/apt/sources.list

    elif [[ "$(lsb_release -si)" == "Debian" ]]
    then
        silent 'Clear sources.list'         sed -i 's/ contrib//g;s/ non-free//g' /etc/apt/sources.list
        silent 'Enabling contrib/non-free'  sed -i 's/main[  ]*$/main contrib non-free/g' /etc/apt/sources.list

    fi
}

### Gnome shell extensions functions ===========================================

function gnomeshellextension()
{
    extid="$1"
    shellver=$(dpkg-query -W -f='${Version}\n' gnome-shell | cut -d '.' -f 1-2)
    shellver="${shellver%%.*}.$(( ${shellver##*.} - ${shellver##*.} % 2 ))"

    if [[ -z "${shellver}" ]]
    then
        title "Downloading extension #${extid}"
        msgfail 'shell not installed'
        return 1
    fi

    extinfo=$(wget "https://extensions.gnome.org/extension-info/?pk=${extid}&shell_version=${shellver}" -q -O - | tr '{' '\n' | tail -n1 | sed 's/.*}}//')

    if [[ $? -ne 0 ]]
    then
        title "Downloading extension #${extid}"
        msgfail
        return 1
    fi

    ext_name=$(echo "${extinfo}" | sed 's/.*"name":[ ]*//' | cut -d '"' -f 2)
    ext_uuid=$(echo "${extinfo}" | sed 's/.*"uuid":[ ]*//' | cut -d '"' -f 2)
    ext_durl=$(echo "${extinfo}" | sed 's/.*"download_url":[ ]*//' | cut -d '"' -f 2)

    title "Downloading ${ext_name}"

    if [[ -z "${ext_uuid}" || -z "${ext_durl}" ]]
    then
        msgfail
        return 1
    fi

    wget -O /tmp/extension.zip "https://extensions.gnome.org/${ext_durl}" >/dev/null 2>&1
    if [[ $? -ne 0 ]]
    then
        msgfail
        return 1
    fi

    rm -rf "/usr/share/gnome-shell/extensions/${ext_uuid}"
    if [[ $? -ne 0 ]]
    then
        msgfail '[remove dir]'
        return 1
    fi

    mkdir -p "/usr/share/gnome-shell/extensions/${ext_uuid}"
    if [[ $? -ne 0 ]]
    then
        msgfail '[create dir]'
        return 1
    fi

    unzip /tmp/extension.zip -d "/usr/share/gnome-shell/extensions/${ext_uuid}" >/dev/null 2>&1
    if [[ $? -ne 0 ]]
    then
        msgfail '[unzip]'
        return 1
    fi

    chmod -R a+r "/usr/share/gnome-shell/extensions/${ext_uuid}" >/dev/null 2>&1
    if [[ $? -ne 0 ]]
    then
        msgfail '[chmod]'
        return 1
    fi

    rm -f /tmp/extension.zip

    msgdone
    return 0
}

### Silent exec functions ======================================================

function silent()
{
    cmdtitle="$1"
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

function silentsudo()
{
    cmdtitle="$1"
    shift

    [[ -n "${cmdtitle}" ]] && title "${cmdtitle}"

    sudo "$@" >/dev/null 2>&1

    if [[ $? -eq 0 ]]
    then
        [[ -n "${cmdtitle}" ]] && msgdone
        return 0
    else
        [[ -n "${cmdtitle}" ]] && msgfail
        return 1
    fi
}

### Bundles ===================================================================

function bundle()
{
    command="$1"

    shift

    case "${command}" in

    "repo")
        bash "${ROOT_PATH}/bundles/repo.sh" $@
        return $?
    ;;

    "install")
        bash "${ROOT_PATH}/bundles/install.sh" $@
        return $?
    ;;

    "prepare")
        bash "${ROOT_PATH}/bundles/prepare.sh" "${config}" "${rootfs_dir}" $@
        return $?
    ;;

    "config")
        bash "${ROOT_PATH}/bundles/config.sh" $@
        return $?
    ;;

    "firstboot")
        bash "${ROOT_PATH}/bundles/firstboot.sh" $@
        return $?
    ;;

    "user")
        bash "${ROOT_PATH}/bundles/user.sh" $@
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

function addservice
{
    srvdesc="$1"
    srvname="$2"
    srvpath="$3"

    silent "Creating ${srvdesc} service"   cp -f "${ROOT_PATH}/files/${srvpath}/${srvname}.service" '/etc/systemd/system/' || return 1

    for target in $(grep WantedBy "/etc/systemd/system/${srvname}.service" | cut -d '=' -f 2 | tr ' ' '\n')
    do
        silent " Creating ${target//.*} target" mkdir -p "/etc/systemd/system/${target}.wants"
        silent " Enabling ${srvdesc} for ${target//.target}" ln -s "/etc/systemd/system/${srvname}.service" "/etc/systemd/system/${target}.wants/${srvname}.service" || return 1
    done

    return 0
}

### Desktop environment detection functions ====================================

function desktoptype()
{
    echo "${XDG_CURRENT_DESKTOP}"

    return 0;
}

function systemtype()
{
    if [[ "${XDG_CURRENT_DESKTOP}" == 'Unity' ]]
    then
        echo 'GNOME'
    elif [[ "${XDG_CURRENT_DESKTOP}" == 'GNOME' ]]
    then
        echo 'GNOME'
    elif [[ "${XDG_CURRENT_DESKTOP}" == 'ubuntu:GNOME' ]]
    then
        echo 'GNOME'
    elif [[ "${XDG_CURRENT_DESKTOP}" == 'X-Cinnamon' ]]
    then
        echo 'Cinnamon'
    elif [[ "${XDG_CURRENT_DESKTOP}" == 'KDE' ]]
    then
        echo 'KDE'
    fi

    return 0;
}

### Gsettings functions ========================================================

function gsettingsclear()
{
    category="$1"
    setting="$2"

    gsettings set ${category} ${setting} '[]'
}

function gsettingsadd()
{
    category="$1"
    setting="$2"
    value="$3"

    valuelist=$(gsettings get $category $setting | sed "s/\['//g" | sed "s/'\]//g" | sed "s/'\, '/\n/g" | sed '/@as \[\]/d')

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

    newvalue="[$(echo "$valuelist" | sed "s/^/'/;s/$/'/" | tr '\n' '\t' | sed 's/\t$//' | sed 's/\t/, /g')]"

    gsettings set $category $setting "${newvalue}"

    return $?
}

### Application menu functions =================================================

function changeapp()
{
    app="$1"

    shift

    ### Copy application =======================================================

    mkdir -p "${HOME}/.local/share/applications/"

    cp -f "/usr/share/applications/${app}.desktop" "${HOME}/.local/share/applications/${app}.desktop"

    ### Update parameters ======================================================

    while [[ $# -ge 2 ]]
    do
        parameter="$1"
        value="$2"

        shift
        shift

        sed -i "/^${parameter}=/d" "${HOME}/.local/share/applications/${app}.desktop"
        echo "${parameter}=${value}" >> "${HOME}/.local/share/applications/${app}.desktop"
    done

    ### ========================================================================

    return 0
}

function hideapp()
{
    app="$1"

    if [[ ! -f "/usr/share/applications/${app}.desktop" ]]
    then
        return 0
    fi

    if grep '^NoDisplay=true$' "/usr/share/applications/${app}.desktop"
    then
        return 0
    fi

    mkdir -p "${HOME}/.local/share/applications/"

    cp -f "/usr/share/applications/${app}.desktop" "${HOME}/.local/share/applications/${app}.desktop"

    addconfigline 'NoDisplay' 'true' 'Desktop Entry' "${HOME}/.local/share/applications/${app}.desktop"

    return 0
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

function launcheradd()
{
    application="$1"

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
    name="$1"
    command="$2"
    binding="$3"

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
    name="$1"
    binding="$2"
    command="$3"
    fixpwd="$4"

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

function addconfigline()
{
    key="$1"
    value="$2"
    section="$3"
    file="$4"

    if ! grep -F "[${section}]" "$file" 1>/dev/null 2>/dev/null
    then
        mkdir -p "$(dirname "$file")"

        echo >> "$file"

        echo "[${section}]" >> "$file"
    fi

    sed -i "/^[[:space:]]*\[${section}\][[:space:]]*$/,/^[[:space:]]*\[.*/{/^[[:space:]]*$(safestring "${key}")[[:space:]]*=/d}" "$file"

    sed -i "/\[${section}\]/a $(safestring "${key}=${value}")" "$file"

    [[ -n "$(tail -c1 "${file}")" ]] && echo >> "${file}"
}

function mimeregister()
{
    mime="$1"
    app="$2"

    addconfigline "${mime}" "${app};" 'Added Associations' "${HOME}/.config/mimeapps.list"
}

function setdefaultapp()
{
    mime="$1"
    app="$2"

    addconfigline "${mime}" "${app}" 'Default Applications' "${HOME}/.config/mimeapps.list"
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

### Wallpaper ==================================================================

function setwallpaper()
{
    wallpaper="$1"

    if [[ "${wallpaper:0:1}" == '#' && ${#wallpaper} -eq 7 ]]
    then
        if ispkginstalled gnome-shell
        then
            gsettings set org.gnome.desktop.background primary-color        "${wallpaper}"
            gsettings set org.gnome.desktop.background secondary-color      "${wallpaper}"
            gsettings set org.gnome.desktop.background color-shading-type   'solid'
            gsettings set org.gnome.desktop.background picture-options      'wallpaper'
            gsettings set org.gnome.desktop.background picture-uri          'file:////usr/share/gnome-control-center/pixmaps/noise-texture-light.png'
        fi

    elif test -f "${wallpaper}"
    then
        if ispkginstalled gnome-shell
        then
            gsettings set org.gnome.desktop.background secondary-color  '#000000'
            gsettings set org.gnome.desktop.background primary-color    '#000000'
            gsettings set org.gnome.desktop.background picture-options  'zoom'
            gsettings set org.gnome.desktop.background picture-uri      "file://${wallpaper}"
        fi

        if ispkginstalled cinnamon
        then
            gsettings set org.cinnamon.desktop.background secondary-color   '#000000'
            gsettings set org.cinnamon.desktop.background primary-color     '#000000'
            gsettings set org.cinnamon.desktop.background picture-options   'zoom'
            gsettings set org.cinnamon.desktop.background picture-uri       "file://${wallpaper}"

        fi

    fi
}

function setlockscreen()
{
    wallpaper="$1"

    if [[ "${wallpaper:0:1}" == '#' && ${#wallpaper} -eq 7 ]]
    then
        if ispkginstalled gnome-shell
        then
            gsettings set org.gnome.desktop.screensaver primary-color       "${wallpaper}"
            gsettings set org.gnome.desktop.screensaver secondary-color     "${wallpaper}"
            gsettings set org.gnome.desktop.screensaver color-shading-type  'solid'
            gsettings set org.gnome.desktop.screensaver picture-options     'wallpaper'
            gsettings set org.gnome.desktop.screensaver picture-uri         'file:////usr/share/gnome-control-center/pixmaps/noise-texture-light.png'
        fi

    elif test -f "${wallpaper}"
    then
        if ispkginstalled gnome-shell
        then
            gsettings set org.gnome.desktop.screensaver secondary-color '#000000'
            gsettings set org.gnome.desktop.screensaver primary-color   '#000000'
            gsettings set org.gnome.desktop.screensaver picture-options 'zoom'
            gsettings set org.gnome.desktop.screensaver picture-uri     "file://${wallpaper}"
        fi

    fi
}

function bgdescr()
{
    local dm_installed=()

    ispkginstalled gnome-shell && dm_installed+=( 'gnome' )
    ispkginstalled cinnamon    && dm_installed+=( 'cinnamon' )
    ispkginstalled mate        && dm_installed+=( 'mate' )

    local root_bg_dir="$1"
    local root_bg_name="${root_bg_dir//\//-}"

    pushd "/usr/share/backgrounds/${root_bg_dir}/" > /dev/null

    for dm in "${dm_installed[@]}"
    do

        mkdir -p "/usr/share/${dm}-background-properties"

        cat > "/usr/share/${dm}-background-properties/${root_bg_name}.xml" << _EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE wallpapers SYSTEM "${dm}-wp-list.dtd">
<wallpapers>
_EOF

        for bg in *
        do

            local bg_name="${bg//_/\ }"
            local bg_name="$(echo "${bg_name%.*}" | tr "[A-Z]" "[a-z]" | sed "s/\( \|^\)\(.\)/\1\u\2/g" )"

            cat >> "/usr/share/${dm}-background-properties/${root_bg_name}.xml" << _EOF
 <wallpaper>
     <name>${bg_name}</name>
     <filename>/usr/share/backgrounds/${root_bg_dir}/${bg}</filename>
     <options>zoom</options>
     <pcolor>#000000</pcolor>
     <scolor>#000000</scolor>
     <shade_type>solid</shade_type>
 </wallpaper>
_EOF

        done

        cat >> "/usr/share/${dm}-background-properties/${root_bg_name}.xml" << _EOF
</wallpapers>
_EOF

    done

    popd > /dev/null
}

### File system ================================================================

function fixpermissions()
{
    mountpoint="$1"
    userid="$2"
    username="$3"

    title "Fixing permissions for ${mountpoint}"

    mountpointsafe=$(safestring "${mountpoint}")

    fstype=$(grep "${mountpointsafe}" /etc/fstab | grep -v '^#' | sed "s/.*${mountpointsafe}[ \t]*//" | sed 's/[ \t].*//')

    [[ -z "${userid}" ]] && userid=$(id -u)
    [[ -z "${username}" ]] && username=$(id -nu)

    plugdevgroup=$(grep plugdev /etc/group | cut -d ':' -f 3)
    [[ -z "${plugdevgroup}" ]] && plugdevgroup=$(id -g)

    case "${fstype}" in
    "ntfs")
        silent '' sed -i "s/${mountpointsafe}[ \t]*${fstype}[ \t]*defaults[^ \t]*/${mountpointsafe}\t${fstype}\tdefaults,umask=000,uid=${plugdevgroup},gid=${plugdevgroup}/" /etc/fstab

        if [[ $? -eq 0 ]]
        then
            msgdone
            return 0
        else
            msgfail
            return 1
        fi
    ;;
    "ext4")
        silent '' chown -R ${userid}:${userid} "${mountpoint}/${username}"
        silent '' chmod -R 0744 "${mountpoint}"

        if [[ $? -eq 0 ]]
        then
            msgdone
            return 0
        else
            msgfail
            return 1
        fi
    ;;
    * )
        msgwarn '[not fonund in fstab]'
        return 0
    ;;
    esac
}

### Live boot detection ========================================================

function islive()
{
    if [[ -n "$(grep ' / ' /etc/mtab | grep 'cow\|aufs')" ]]
    then
        return 0
    else
        return 1
    fi
}

### Kernel version =============================================================

function kernelversionlist()
{
    ls /lib/modules/
}

function kernelversion()
{
    dpkg-query -W -f='${binary:Package}\n' linux-image-* | head -n 1 | sed 's/linux-image-//'
    return 0;
}

