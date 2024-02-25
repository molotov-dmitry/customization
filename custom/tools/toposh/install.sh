#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

### Drivers ====================================================================

## Audio -----------------------------------------------------------------------

appinstall 'Trackpad fix'   'device-config-toposh-trackpad-fix'
appinstall 'Display fix'    'device-config-toposh-display-fix'
