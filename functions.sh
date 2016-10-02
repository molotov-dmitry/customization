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

function debprepare()
{
    appname="$1"
    debname="$2"
    debversion="$3"
    debarch="$4"

    debpath="${ROOT_PATH}/packages/${debname}_${debversion}_${debarch}.deb"

    mkdir -p "${rootfs_dir}/packages"

    silentsudo "Copy ${appname} package" cp -f "${debpath}" "${rootfs_dir}/packages/"
}

function debinstall()
{
    appname="$1"
    debname="$2"
    debversion="$3"
    debarch="$4"

    debpath="${ROOT_PATH}/packages/${debname}_${debversion}_${debarch}.deb"

    title "Installing $appname"

    if ! ispkginstalled "${debname}"
    then
        sudo dpkg -i "${debpath}" >/dev/null 2>&1

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

### Gnome shell extensions functions ===========================================

function gnomeshellextension()
{
    extid="$1"
    shellver=$(dpkg-query -W -f='${Version}\n' gnome-shell | cut -d '.' -f 1-2)

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

    sudo wget -O /tmp/extension.zip "https://extensions.gnome.org/${ext_durl}" >/dev/null 2>&1
    if [[ $? -ne 0 ]]
    then
        msgfail
        return 1
    fi

    sudo rm -rf "/usr/share/gnome-shell/extensions/${ext_uuid}"
    if [[ $? -ne 0 ]]
    then
        msgfail '[remove dir]'
        return 1
    fi

    sudo mkdir -p "/usr/share/gnome-shell/extensions/${ext_uuid}"
    if [[ $? -ne 0 ]]
    then
        msgfail '[create dir]'
        return 1
    fi

    sudo unzip /tmp/extension.zip -d "/usr/share/gnome-shell/extensions/${ext_uuid}" >/dev/null 2>&1
    if [[ $? -ne 0 ]]
    then
        msgfail '[unzip]'
        return 1
    fi

    sudo chmod -R a+r "/usr/share/gnome-shell/extensions/${ext_uuid}" >/dev/null 2>&1
    if [[ $? -ne 0 ]]
    then
        msgfail '[chmod]'
        return 1
    fi

    sudo rm -f /tmp/extension.zip

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
    echo "Checking bundles:"

    for category in prepare install config user
    do

        custom_tool="${category}"
        [[ "${custom_tool}" == 'install' ]] && custom_tool='create'

        echo
        msginfo "${category}:"

        ## Check for unused bundles

        bundle_list=$(grep '^[ \t]*"[a-z,/-]*")' "${ROOT_PATH}/bundles/${category}.sh" | cut -d '"' -f 2)
        bundle_used=$(grep "^[ \t]*bundle[ \t]*${category}" "${ROOT_PATH}/custom/tools/${config}/${custom_tool}.sh" | sed "s/^[ \t]*bundle[ \t]*${category}[ \t]*//" | tr -d " '")

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

            #exit 1
        done

        ## Check for wrong bundles

        for bundle in ${bundle_used}
        do
            if [[ -z "$(echo "${bundle_list}" | grep "^${bundle}$")" ]]
            then
                msgfail " ! ${bundle}"
            fi
        done
    done

    echo
}

### SystemD service functions ==================================================

function addservice
{
    srvdesc="$1"
    srvname="$2"
    srvpath="$3"

    silentsudo "Creating ${srvdesc} service"   cp -f "${ROOT_PATH}/files/${srvpath}/${srvname}.service" '/etc/systemd/system/' || return 1

    for target in $(grep WantedBy "/etc/systemd/system/${srvname}.service" | cut -d '=' -f 2 | tr ' ' '\n')
    do
        silentsudo " Creating ${target//.*} target" mkdir -p "/etc/systemd/system/${target}.wants"
        silentsudo " Enabling ${srvdesc} for ${target//.target}" ln -s "/etc/systemd/system/${srvname}.service" "/etc/systemd/system/${target}.wants/${srvname}.service" || return 1
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

    valuelist=$(gsettings get $category $setting | sed "s/\['//g" | sed "s/'\]//g" | sed "s/'\, '/\n/g")

    if [[ -n "$(echo "${valuelist}" | grep ^${value}$)" ]]
    then
        return 0
    fi

    valuelist="${valuelist}
${value}"

    newvalue="[$(echo "$valuelist" | sed "s/^/'/;s/$/'/" | tr '\n' '\t' | sed 's/\t$//' | sed 's/\t/, /g')]"

    gsettings set $category $setting "${newvalue}"

    return $?
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

    if [[ "${XDG_CURRENT_DESKTOP}" == 'Unity' ]]
    then
        launcheradd_var "$application" 'com.canonical.Unity.Launcher' 'favorites'
    elif [[ "${XDG_CURRENT_DESKTOP}" == 'GNOME' ]]
    then
        launcheradd_var "$application" 'org.gnome.shell' 'favorite-apps'
    fi
}

### Wallpaper ==================================================================

function setwallpaper()
{
    wallpaper="$1"

    if [[ "${wallpaper:0:1}" == '#' && ${#wallpaper} -eq 7 ]]
    then
        if [[ "${XDG_CURRENT_DESKTOP}" == 'Unity' ]]
        then
            r=${wallpaper:1:2}
            g=${wallpaper:3:2}
            b=${wallpaper:5:2}

            gsettings set org.gnome.desktop.background primary-color    "#${r}${r}${g}${g}${b}${b}"
            gsettings set org.gnome.desktop.background picture-options  'none'
            gsettings set org.gnome.desktop.background picture-uri      ''

        elif [[ "${XDG_CURRENT_DESKTOP}" == 'GNOME' ]]
        then
            gsettings set org.gnome.desktop.background primary-color    "${wallpaper}"
            gsettings set org.gnome.desktop.background secondary-color  "${wallpaper}"
            gsettings set org.gnome.desktop.background color-shading-type 'solid'
            gsettings set org.gnome.desktop.background picture-options  'wallpaper'
            gsettings set org.gnome.desktop.background picture-uri      'file:////usr/share/gnome-control-center/pixmaps/noise-texture-light.png'
        fi

    elif test -f "${wallapper}"
    then
        gsettings set org.gnome.desktop.background picture-options      'zoom'
        gsettings set org.gnome.desktop.background picture-uri          "${wallapper}"
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

