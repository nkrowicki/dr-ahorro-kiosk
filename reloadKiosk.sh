#!/bin/bash

# Vars
# Full path of this file without filename
pathProject=`dirname $(realpath $0)`

# Cd folder that contain project
cd $pathProject

# Load log4bash (only is was not loaded)
if [ "$(type -t log)" != 'function' ]; then
        source log4bash.sh
fi

function reloadKiosk {
   log "Start reloadKiosk"
   pkill -f kiosk.sh
   pkill chromium
   bash kiosk.sh
   log "End reloadKiosk"
}