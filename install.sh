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

log "Start Install.sh"

# Vars

fileLog="kiosk.log"

scriptUpdate="update.sh"
TODAY=$(date +%F)
autostartFile="/etc/xdg/lxsession/LXDE-pi/autostart"

xscreensaverLine="@xscreensaver -no-splash"
pointrpiLine="@point-rpi"

preferencesChromiumFile="/home/pi/.config/chromium/Default/Preferences"
preferencesChromiumFileBpk="$preferencesChromiumFile"
preferencesChromiumFileBpk+="_bkp_$TODAY"

# File config
fileConfig="/home/pi/Desktop/configKiosk.json"

# Kiosk Script Path
kioskScript="${pathProject}/kiosk.sh"
kioskScriptLine="@bash $kioskScript"

echo "This script install Kiosk to Dr Ahorro"
echo "--------------------------------------"
echo "Creator: Nahuel Krowicki"
echo "Contact: nahuelkrowicki@gmail.com"
echo
echo

echo "Remove packages that we don't need"
apt-get purge wolfram-engine scratch scratch2 nuscratch sonic-pi idle3 -y
apt-get purge smartsim java-common minecraft-pi libreoffice* -y

echo "Clean to remove any unnecessary packages"
apt-get clean -y
apt-get autoremove -y

echo "Update our installation of Raspbian."
apt-get update -y
apt-get upgrade -y

echo "Install xdtotool, unclutter and sed"
echo "xdotool: Allow our bash script to execute key presses withouth anyone being on the device"
echo "unclutter: Enable us to hide the mouse from the display"
apt-get install -y xdotool unclutter sed chromium-browser ttf-mscorefonts-installer x11-xserver-utils pv hdparm htop jq vim

echo "Set up autostart config"
echo "Set up auto login to our user-> Desktop autologin is the default behavior."
# if it is not by default follow the following instructions:
# sudo raspi-config
# Go to 3 Boot Options -> B1 Desktop/CLI -> B4 Desktop autologin

echo "On file $autostartFile..."
echo "Check if exist $xscreensaverLine or add"
if ! grep -q "$xscreensaverLine" "$autostartFile"
then
    # code if not found
	echo $xscreensaverLine >> $autostartFile
fi
echo "Line: $xscreensaverLine -> OK"

echo
echo "Check if exist $pointrpiLine or add"
if ! grep -q "$pointrpiLine" "$autostartFile" 
then
    # code if not found
	echo $pointrpiLine >> $autostartFile
fi
echo "Line: $pointrpiLine -> OK"

echo
echo "Add line to run kiosk script: $kioskScriptLine"
if ! grep -q "$kioskScriptLine" "$autostartFile" 
then
    # code if not found
    echo $kioskScriptLine >> $autostartFile
fi
echo "Line: $kioskScriptLine -> OK"

# Fist: BackupFile Preferences Chromium
echo "Backup file $preferencesChromiumFile to $preferencesChromiumFileBpk"
cp -f $preferencesChromiumFile $preferencesChromiumFileBpk
echo "Backup Preferences Chromium File -> OK"

# Check if $fileConfig file exist
if [ -f "$fileConfig" ]
then
        echo "$fileConfig found."
else
        echo "$fileConfig not found, we will not create a new config file."
        echo 
        echo "Create empty json config file on $fileConfig"
        echo "{}" > $fileConfig
        echo
        echo
fi

# url: Check if exist or assign new URL
# Obtain value from $fileConfig and delete first and last double quotes, then assign the result to url var
url=$(jq .url $fileConfig | sed -e 's/^"//' -e 's/"$//')
if [ -z "$url" ] || [ "$url" == "null" ] ; then
        # Url not exist
        echo
        echo "The URL was not found, please enter the URL"
        read -p 'Enter URL: ' url
else
        # Url exist
        echo
        echo "The URL was found"
        echo "url is: $url"
        echo
fi

# zoom: Check if exist or assign default value zoom
# Obtain value from $fileConfig and delete first and last double quotes, then assign the result to zoom var
zoom=$(jq .zoom $fileConfig | sed -e 's/^"//' -e 's/"$//')
if [ -z "$zoom" ] || [ "$zoom" == "null" ] ; then
        # zoom not exist
        zoom=1
else
        # zoom exist
        echo
        echo "The zoom was found."
        echo "zoom is: $zoom"
        echo
fi

jq '.url = $newVal' --arg newVal $url $fileConfig > tmp.$$.json && mv tmp.$$.json $fileConfig
jq '.zoom = $newVal' --arg newVal $zoom $fileConfig > tmp.$$.json && mv tmp.$$.json $fileConfig

echo
echo "Add write permissions to $fileConfig so that later a user can modify it."
echo
chmod o+w $fileConfig


echo
echo "Add crontab line for run update each 30 minutes"
echo
crontabLine="*/20 * * * * sudo ${pathProject}/$scriptUpdate"
crontabLineEscapeCharacters="${crontabLine//\*/\\*}"
echo "Escape: $crontabLineEscapeCharacters"
crontab -u pi -l > mycron
if ! grep -q "$crontabLineEscapeCharacters" mycron 
then
    # code if not found
    echo "$crontabLine" >> mycron
    crontab -u pi mycron
fi
rm mycron

# Create $fileLog only if not exist
echo "Create fileLog ($fileLog) only if not exist"
if [ ! -f $fileLog ]; then
    echo
    echo "fileLog not found!"
    echo "Create fileLog ($fileLog)"
    echo
    touch $fileLog
fi

echo "Add execution permissions"
chmod +x *.sh

echo "Change owner of files"
chown -R pi:pi .

# End install
log "End Install.sh ->  Reboot System"

echo "Reboot System"
sudo shutdown -r now