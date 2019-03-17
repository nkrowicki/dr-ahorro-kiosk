#!/bin/bash

# Vars
# Full path of this file without filename
pathProject=`dirname $(realpath $0)`

# Cd folder that contain project
cd $pathProject

# Load log4bash
source log4bash.sh

function reloadKiosk {
   pkill -f kiosk.sh
   pkill chromium
   bash kiosk.sh
   log "Reload end"
}