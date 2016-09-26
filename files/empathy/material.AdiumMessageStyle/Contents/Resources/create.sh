#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

name="$1"
color="$2"

mkdir -p 'Variants'
mkdir -p 'Demo'

cp -f "Template/Template.css" "Variants/${name}.css"
cp -f "Template/Template Alternating.css" "Variants/${name} Alternating.css"
cp -f "Template/Template No Names.css" "Variants/${name} No Names.css"
cp -f "Template/Template No Names Alt.css" "Variants/${name} No Names Alt.css"

cp -f "Template/Demo.html" "./Demo/${name}.html"
cp -f "Template/Demo Alternate.html" "./Demo/${name} Alternate.html"

for file in "Variants/${name}.css" "Variants/${name} Alternating.css" "Variants/${name} No Names.css" "Variants/${name} No Names Alt.css" "./Demo/${name}.html" "./Demo/${name} Alternate.html" 
do
    sed -i "s/<<<TEMPLATE>>>/${name}/" "${file}"
    sed -i "s/<<<IN_COLOR>>>/${color}/" "${file}"
done
