#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

mkdir -p logs
rm -f logs/*.txt

iso=''
config=''

while IFS= read line
do
    [[ -z "${line}" ]] && continue

    [[ "${line}" =~ ^[\ ]*'#' ]] && continue

    if [[ "${line}" == " "* ]]
    then
        config="$(echo "${line:1}" | cut -d ' ' -f 1)"
        parameters="$(echo "${line:1}" | cut -s -d ' ' -f 2-)"

        /usr/bin/yes | /bin/bash build.sh "/media/documents/Distrib/OS/$iso" "$config" --noram --quiet --no-progress --notify $parameters "$@" | tee "logs/${config}-${iso}.txt"
    else
        if [ -z "${line##*\=*}" ]
	then
	    link="${line##*=}"
            linkext="${link##*.}"
            iso="${line%%=*}"

            if [[ "${linkext}" == 'zsync' ]]
            then
	        zsync "${link}" -o "/media/documents/Distrib/OS/$iso"
            else
                wget -q "${link}" -O "/media/documents/Distrib/OS/$iso"
            fi
	else
            iso="${line}"
	fi
    fi

done < configs
