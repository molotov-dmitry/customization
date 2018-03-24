#!/bin/bash

### Copy config files ==========================================================

## Application config files ----------------------------------------------------

bundle prepare 'gnome'

bundle prepare 'dev/qt'

bundle prepare 'office'

bundle prepare 'network/mail'
bundle prepare 'network/chat'

bundle prepare 'cli'
