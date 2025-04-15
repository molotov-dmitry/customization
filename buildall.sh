#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

#### Generate logs header ======================================================

mkdir -p logs
rm -f logs/*.txt

cat << _EOF > logs/build.html
<html>
<head>
<meta http-equiv="Content-Type" content="application/xml+xhtml; charset=UTF-8"/>
<title>Build $(date)</title>
<style>
body { background-color: #FAFAFA; color: #000000; }

.dimgray                { color: #000000; }
.highlighted.dimgray    { color: #9E9E9E; }
.red                    { color: #D50000; }
.highlighted.red        { color: #E57373; }
.green                  { color: #2E7D32; }
.highlighted.green      { color: #AED581; }
.yellow                 { color: #F9A825; }
.highlighted.yellow     { color: #FFEE58; }
.blue                   { color: #1565C0; }
.highlighted.blue       { color: #42A5F5; }
.purple                 { color: #8E24AA; }
.highlighted.purple     { color: #BA68C8; }
.cyan                   { color: #0097A7; }
.highlighted.cyan       { color: #4DD0E1; }
.white                  { color: #EEEEEE; }
.highlighted.white      { color: #FFFFFF; }

.bg-black               { color: #000000; }
.highlighted.bg-black   { color: #9E9E9E; }
.bg-red                 { color: #D50000; }
.highlighted.bg-red     { color: #E57373; }
.bg-green               { color: #2E7D32; }
.highlighted.bg-green   { color: #AED581; }
.bg-yellow              { color: #F9A825; }
.highlighted.bg-yellow  { color: #FFEE58; }
.bg-blue                { color: #1565C0; }
.highlighted.bg-blue    { color: #42A5F5; }
.bg-purple              { color: #8E24AA; }
.highlighted.bg-purple  { color: #BA68C8; }
.bg-cyan                { color: #0097A7; }
.highlighted.bg-cyan    { color: #4DD0E1; }
.bg-white               { color: #EEEEEE; }
.highlighted.bg-white   { color: #FFFFFF; }

@media (prefers-color-scheme: dark)
{
body { background-color: #000000; color: #FAFAFA; }

.yellow                 { color: #F57F17; }
.bg-yellow              { color: #F57F17; }

}
</style>
</head>
<body>
<pre>
_EOF

#### Clear base iso and config names variables =================================

iso=''
config=''

#### Build custom iso images ===================================================

while IFS= read line
do
    #### Skip empty lines ------------------------------------------------------

    [[ -z "${line}" ]] && continue

    [[ "${line}" =~ ^[\ ]*'#' ]] && continue

    if [[ "${line}" == " "* ]]
    then
        #### Build custom iso image --------------------------------------------

        config="$(echo "${line:1}" | cut -d ' ' -f 1)"
        parameters="$(echo "${line:1}" | cut -s -d ' ' -f 2-)"

        /bin/bash build.sh "/media/documents/Distrib/OS/$iso" \
                           "$config" \
                           --quiet \
                           --no-progress \
                           --notify \
                           --non-interactive \
                           $parameters \
                           "$@" | tee "logs/${config}-${iso}.txt" >(aha -s -n | sed -u 's/␏//g' >> logs/build.html)
    else
        if [ -z "${line##*\=*}" ]
        then
            #### Download and set base image -----------------------------------

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
            #### Set base image ------------------------------------------------

            iso="${line}"
        fi
    fi

done < configs

#### Generate logs footer ======================================================

cat << _EOF >> logs/build.html
</pre>
</body>
</html>
_EOF
