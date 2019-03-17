#!/bin/bash

# Vars
# Full path of this file without filename
pathProject=`dirname $(realpath $0)`

# Cd folder that contain project
cd $pathProject

# Load quickLog
source quickLog.sh

# Vars
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
kioskScript="/home/pi/kiosk.sh"
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
apt-get clean
apt-get autoremove -y

echo "Update our installation of Raspbian."
apt-get update
apt-get upgrade


echo "Install xdtotool, unclutter and sed"
echo "xdotool: Allow our bash script to execute key presses withouth anyone being on the device"
echo "unclutter: Enable us to hide the mouse from the display"
apt-get install -y xdotool unclutter sed chromium-browser ttf-mscorefonts-installer x11-xserver-utils pv hdparm htop jq

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
echo $kioskScriptLine >> $autostartFile
echo "Line: $kioskScriptLine -> OK"

# Fist: BackupFile Preferences Chromium
echo "Backup file $preferencesChromiumFile to $preferencesChromiumFileBpk"
cp -f $preferencesChromiumFile $preferencesChromiumFileBpk
echo "Backup Preferences Chromium File -> OK"


echo 
echo "Create empty json config file on $fileConfig"
echo "{}" > $fileConfig
read -p 'Enter URL: ' url
zoom=1
jq '.url = $newVal' --arg newVal $url $fileConfig > tmp.$$.json && mv tmp.$$.json $fileConfig
jq '.zoom = $newVal' --arg newVal $zoom $fileConfig > tmp.$$.json && mv tmp.$$.json $fileConfig


echo "Add crontab line for run update each 30 minutes"
crontab -l > mycron
echo "*/30 * * * * sudo ${pathProject}/$scriptUpdate" >> mycron
crontab mycron
rm mycron

echo "Reboot System"
sudo shutdown -r now