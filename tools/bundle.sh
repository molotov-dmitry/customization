#!/bin/bash

action="$1"

#### Load functions ============================================================

if [[ "${action}" != "prepare" ]]
then

    ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
    cd "${ROOT_PATH}" || exit 1

    . "${ROOT_PATH}/functions.sh"

    config="$2"

fi

#### ===========================================================================

filename="${ROOT_PATH}/custom/tools/${config}.bundle"

if ! test -f "${filename}"
then
    msgfail "[no bundle list '${filename}']"
    exit 1
fi

while read -r bundle
do
    [[ -z "${bundle}" || "$bundle" == '#'* ]] && continue

    bundle ${action} ${bundle}

done < "$filename"

