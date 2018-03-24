#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

## Optimizations ---------------------------------------------------------------

bundle firstboot 'optimize'

### Fix directory permissions ==================================================

fixpermissions '/media/documents'
fixpermissions '/media/windows'

