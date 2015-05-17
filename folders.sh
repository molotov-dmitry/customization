#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

readonly target_disk='/media/documents'

target_dir=( "Downloads" "Documents" "Music" "Images" "Video" "Templates" "Projects" )
source_dir=( "" "" "" "" "" "" "${HOME}/Projects" )
source_xdg=( "DOWNLOAD" "DOCUMENTS" "MUSIC" "PICTURES" "VIDEOS" "TEMPLATES" "" )

let DIR_COUNT=${#target_dir[@]}
#let DIR_COUNT=6

for (( index=0; index<${DIR_COUNT}; index++ ))
do
    src_dir="${source_dir[$index]}"
    dst_dir="${target_disk}/${target_dir[$index]}"
    name_dir="${target_dir[$index]}"

    title "checking ${name_dir} destination folder"

    if test -d "${dst_dir}"
    then
        msgdone
    else
        msgfail
        exit 1
    fi
done

echo

for (( index=0; index<${DIR_COUNT}; index++ ))
do
    src_dir=""

    if [[ -n "${source_xdg[$index]}" ]]
    then
        src_dir=$(eval echo $(grep "XDG_${source_xdg[$index]}_DIR" ~/.config/user-dirs.dirs | cut -d '"' -f 2))
        if [[ -n "${src_dir}" ]]
        then    
            source_dir[$index]="${src_dir}"
        fi
    fi

    echo "${index}: ${source_dir[$index]} -> ${target_disk}/${target_dir[$index]}"
done

echo

for (( index=0; index<${DIR_COUNT}; index++ ))
do
    src_dir="${source_dir[$index]}"
    dst_dir="${target_disk}/${target_dir[$index]}"
    name_dir="${target_dir[$index]}"

    if test -L "${src_dir}"
    then
        silent "unlinking ${name_dir}" unlink "${src_dir}"
    fi

    if test -d "${src_dir}"
    then
        silent "moving ${name_dir} to destination" find "${src_dir}/" -mindepth 1 -maxdepth 1 -exec mv -b -f -t "${dst_dir}/" {} +
    fi

    if test -e "${src_dir}"
    then
        silent 'removing source folder' rm -rf "${src_dir}"
    fi

    silent "linking ${name_dir}" ln -s "${dst_dir}" "${src_dir}"
done
