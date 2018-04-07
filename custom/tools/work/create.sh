#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

### ============================================================================

appinstall 'RDP server' 'vino'
appinstall 'RDP client' 'remmina remmina-plugin-vnc remmina-plugin-rdp'
