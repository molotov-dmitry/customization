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

function debinstall()
{
    appname="$1"
    package="$2"
    debpath="$3"

    title "Installing $appname"

    if ! ispkginstalled "${package}"
    then
        sudo dpkg -i "${debpath}"

        if [[ $? -eq 0 ]]
            then
                msgdone
                return 0
            else
                msgfail
                return 1
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

    for app in ${applist}
    do
        if ! ispkginstalled "${app}"
        then
            installlist="${installlist} ${app}"
        fi
    done

    if [[ -z "${installlist}" ]]
    then
        msgwarn '[already installed]'
        return 0
    else        
        sudo apt-get install $installlist --yes --force-yes >/dev/null 2>&1

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
        msgwarn '[already removed]'
        return 0
    else        
        sudo apt-get purge ${remlist} --yes --force-yes --purge >/dev/null 2>&1

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

    sudo apt-get update >/dev/null 2>&1

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

    sudo apt-get upgrade --yes --force-yes >/dev/null 2>&1

    if [[ $? -eq 0 ]]
    then
        msgdone
        return 0
    else
        msgfail
        return 1
    fi
}

function appdistupgrade()
{
    title 'Upgrading distributive'

    sudo apt-get dist-upgrade --yes --force-yes >/dev/null 2>&1

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

function debian_ppaadd()
{
    reponame="$1"
    author="$2"
    repo="$3"

    ppapage=$(wget -q -O - "https://launchpad.net/~${author}/+archive/ubuntu/${repo}")

    if [[ -z "${ppapage}" ]]
    then
        return 1
    fi

    recvkey=$(echo "${ppapage}" | grep '<code>' | sed 's/.*<code>//' | sed 's/<\/code>.*//' | cut -d '/' -f 2)

    if [[ -z "${recvkey}" ]]
    then
        return 2
    fi

    links=$(echo "${ppapage}" | grep -B1 'YOUR_UBUNTU_VERSION' | grep '^deb' | sed 's/<\/a>.*//' | sed 's/<.*>//')

    if [[ -z "${links}" ]]
    then
        return 3
    fi

    version=$(echo "${ppapage}" | grep '<option' | grep '(' | sed -n 2p | cut -d '"' -f 2)

    if [[ -z "${version}" ]]
    then
        return 4
    fi

    keyserver=$(echo "${ppapage}" | grep -A2 'Signing key' | grep 'http' | cut -d '"' -f 2 | cut -d ':' -f 2 | cut -d '/' -f 3)

    sudo apt-key adv --keyserver $keyserver --recv $recvkey >/dev/null 2>&1

    if [[ $? -ne 0 ]]
    then
        return 1
    fi

    sourceslist="$(echo "${links}" | sed "s/$/ ${version} main/")"

    echo "${sourceslist}" | sudo tee "/etc/apt/sources.list.d/${author}-${repo}-${version}.list" >/dev/null 2>&1

    return $?
}

function ppaadd()
{
    reponame="$1"
    author="$2"
    repo="$3"

    if [[ -z "${repo}" ]]
    then
        repo='ppa'
    fi

    title "Adding $reponame repository"

    if ! isppaadded "${author}" "${repo}"
    then

        if [[ "$(lsb_release -si)" == "Ubuntu" ]]
        then
            sudo add-apt-repository --yes ppa:${author}/${repo} >/dev/null 2>&1
		else
            debian_ppaadd "${reponame}" "${author}" "${repo}"
        fi

        if [[ $? -eq 0 ]]
        then
            msgdone
            return 0
        else
            msgfail
            return 1
        fi
    else
        msgwarn '[already added]'
        return 0
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

    silentsudo "Changing release '${current_release}' to '${release}'" sed -i "s/${current_release}/${release}/g" /etc/apt/sources.list

    return $?
}

function repoaddnonfree()
{
    if [[ "$(lsb_release -si)" == "Ubuntu" ]]
    then
        silentsudo 'Enabling universe source'   add-apt-repository universe
        silentsudo 'Enabling multiverse source' add-apt-repository multiverse

    elif [[ "$(lsb_release -si)" == "Debian" ]]
    then
        silentsudo 'Clear sources.list'         sed -i 's/ contrib//g;s/ non-free//g' /etc/apt/sources.list
        silentsudo 'Enabling contrib/non-free'  sed -i 's/main[  ]*$/main contrib non-free/g' /etc/apt/sources.list

    fi
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
    elif [[ "${XDG_CURRENT_DESKTOP}" == 'KDE' ]]
    then
        echo 'KDE'
    fi
    
    return 0;
}

### Launcher functions =========================================================

function launcherclear()
{
    if [[ "${XDG_CURRENT_DESKTOP}" == 'Unity' ]]
    then
        gsettings set com.canonical.Unity.Launcher favorites '[]'
    elif [[ "${XDG_CURRENT_DESKTOP}" == 'GNOME' ]]
    then
        gsettings set org.gnome.shell favorite-apps '[]'
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
$1"
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

    if [[ "${XDG_CURRENT_DESKTOP}" == 'Unity' ]]
    then
        launcheradd_var "$application" 'com.canonical.Unity.Launcher' 'favorites'
    elif [[ "${XDG_CURRENT_DESKTOP}" == 'GNOME' ]]
    then
        launcheradd_var "$application" 'org.gnome.shell' 'favorite-apps'
    fi
}

### File system ================================================================

function fixpermissions()
{
    mountpoint="$1"

    title "Fixing permissions for ${mountpoint}"

    mountpointsafe=$(safestring "${mountpoint}")

    fstype=$(grep "${mountpointsafe}" /etc/fstab | grep -v '^#' | sed "s/.*${mountpointsafe}[ \t]*//" | sed 's/[ \t].*//')

    userid=$(id -u)
    plugdevgroup=$(grep plugdev /etc/group | cut -d ':' -f 3)

    [[ -z "${plugdevgroup}" ]] && plugdevgroup=$(id -g)

    case "${fstype}" in
    "ntfs")
        silentsudo '' sed -i "s/${mountpointsafe}[ \t]*${fstype}[ \t]*defaults[^ \t]*/${mountpointsafe}\t${fstype}\tdefaults,umask=000,uid=${userid},gid=${plugdevgroup}/" /etc/fstab

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
        silentsudo '' chown -R ${USER}:${USER} "${mountpoint}"
        silentsudo '' chmod -R a=rwx "${mountpoint}"

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
