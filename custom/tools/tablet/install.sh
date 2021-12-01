#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

### Drivers ====================================================================

## Audio -----------------------------------------------------------------------

appinstall 'Intel UCM files' 'ucm-intel'

### Compressed RAM =============================================================

appinstall 'ZRAM config' 'zram-config'

### IA32 EFI GRUB ==============================================================

appinstall 'IA32 EFI GRUB' 'grub-efi-ia32-bin'
