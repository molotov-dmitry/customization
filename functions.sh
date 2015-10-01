### constants ==================================================================
readonly CL_RED='\E[31;35m'
readonly CL_YELLOW='\E[31;33m'
readonly CL_GREEN='\E[31;32m'

readonly TITLE_LENGTH=50
readonly SPACE_CHAR='.'

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

function conntest()
{
    if ping -w 5 -c 1 mirror.yandex.ru 1>/dev/null 2>&1
    then
        return 0
    else
        return 1
    fi
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

        sudo add-apt-repository --yes ppa:${author}/${repo} >/dev/null 2>&1

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
