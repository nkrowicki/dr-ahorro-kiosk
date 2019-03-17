#!/bin/bash

# Full path of this file without filename
pathProject=`dirname $(realpath $0)`

# Cd folder that contain project
cd $pathProject

function reloadKiosk {
   pkill -f kiosk.sh
   pkill chromium
   bash kiosk.sh
}