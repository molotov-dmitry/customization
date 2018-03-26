#!/bin/bash

function isdebian()
{
    if [[ "$(basename "${iso_src}")" == debian* ]]
    then
        return 0
    else
        return 1
    fi
}

function checkfilemime()
{
    filetitle="$1"
    filename="$2"
    mimetype="$3"
    filetype="$4"

    title "Checking ${filetitle}"

    if ! test -f "${filename}"
    then
        msgfail '[file not found]'
        exit 1
    fi

    filemime=$(file -b --mime-type "${filename}")

    if [[ "${filemime}" == "${mimetype}" ]]
    then
        msgdone
    else
        msgfail "[not an ${filetype}]"
        exit 1
    fi
}
