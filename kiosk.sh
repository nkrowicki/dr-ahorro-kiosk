#!/bin/bash

# Vars
# Full path of this file without filename
pathProject=`dirname $(realpath $0)`

# Cd folder that contain project
cd $pathProject

# Load quickLog
source quickLog.sh

# Vars
fileConfig="/home/pi/Desktop/configKiosk.json"

preferencesChromiumFile="/home/pi/.config/chromium/Default/Preferences"


log "Enable SSH Server"
if [ ! $(systemctl -q is-active ssh) ]; then
    systemctl enable ssh
    systemctl start ssh
fi

# Hide the mouse from the display whenever it has been idle for longer then 0.5 seconds
unclutter -idle 0.5 -root &

# Disable scren saver
xset s noblank
xset s off
xset -dpms

# Use sed to search throught the Chromium preferences file and clear out any flags that would make the warning bar appear, a behavior you don't really want happening on yout Raspberry Pi Kiosk.
sed -i 's/"exited_cleanly":false/"exited_cleanly":true/' $preferencesChromiumFile
sed -i 's/"exit_type":"Crashed"/"exit_type":"Normal"/' $preferencesChromiumFile

# Get values from configuration file
url=`echo $(jq .url $fileConfig) | tr -d '"'` 
zoom=`echo $(jq .zoom $fileConfig) | tr -d '"'` 

#Execute Chromium 
/usr/bin/chromium-browser --noerrdialogs --disable-infobars --incognito --start-maximized --kiosk --force-device-scale-factor=$zoom $website &
