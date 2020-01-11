#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

## Set any user as work account ================================================

mkdir -p "${HOME}/.config"
touch    "${HOME}/.config/is-work-account"

## Clear launcher ==============================================================

launcherclear
