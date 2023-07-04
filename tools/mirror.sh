#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

### Applications ===============================================================

## Enable all package sources --------------------------------------------------

repoaddnonfree

## Change download mirror to Yandex --------------------------------------------

changemirror 'mirror.yandex.ru'

## Removed source repositories -------------------------------------------------

silent 'Remove source repositories' sed -i '/^[ \t]*deb-src /d' /etc/apt/sources.list

## Update all packages ---------------------------------------------------------

appupdate
appupgrade
