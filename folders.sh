#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"



### Директория, в которой находятся каталоги с документами
readonly target_disk='/media/documents'


### Имена целевых директорий
target_dir=( "Downloads" "Documents" "Music" "Images" "Video" "Templates" "Projects" )

### Имена исходных директорий
source_dir=( "" "" "" "" "" "" "${HOME}/Projects" )

### Имена исходных директорий, берущихся из файла XDG user dirs
source_xdg=( "DOWNLOAD" "DOCUMENTS" "MUSIC" "PICTURES" "VIDEOS" "TEMPLATES" "" )

### Количество директорий
let DIR_COUNT=${#target_dir[@]}


### Проверка директории

title "Checking destination folder"


if [[ -d "${target_disk}" ]]
then
    msgdone
else
    msgfail
    exit 1
fi

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
        msgwarn '[missing]'

        title "creating ${name_dir} destination folder"

        mkdir -p "${dst_dir}"

        if test -d "${dst_dir}"
        then
            msgdone
        else
            msgfail
            exit 1
        fi
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
