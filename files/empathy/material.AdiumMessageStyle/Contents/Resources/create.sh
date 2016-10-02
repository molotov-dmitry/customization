#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

name="$1"
color="$2"

mkdir -p 'Variants'
mkdir -p 'Demo'

cp -f "Template/Template.css" "Variants/${name}.css"
cp -f "Template/Demo.html" "./Demo/${name}.html"

for file in "Variants/${name}.css" "./Demo/${name}.html"
do
    sed -i "s/<<<TEMPLATE>>>/${name}/" "${file}"
    sed -i "s/<<<IN_COLOR>>>/${color}/" "${file}"
done
