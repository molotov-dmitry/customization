#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

### Element.io =================================================================

repoadd 'Element.io' 'https://packages.element.io/debian/' 'default' 'main' 'element-io.gpg'
