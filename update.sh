#!/bin/bash

# Vars
# Full path of this file without filename
pathProject=`dirname $(realpath $0)`
# Flag ti know if the install.sh file has changed (0: not changed - 1: changed)
flag=0
# Cd folder that contain project
cd $pathProject

# Load log4bash (only is was not loaded)
if [ "$(type -t log)" != 'function' ]; then
        source log4bash.sh
fi

# Load checkInternet (only is was not loaded)
if [ "$(type -t checkInternet)" != 'function' ]; then
        source checkInternet.sh
fi

log "Check for updates..."

# Check internet
checkInternet

# Get Latest remote commit of branch head/master
latestCommitRemote=`git ls-remote origin -h refs/heads/master | awk '{print $1}'`
latestCommitLocal=`git log -n1 | awk '{print $2}' | head -n 1`

if [ -z "$latestCommitRemote" ]; then
   log_error "Error when getting remote commit"
   exit 1
fi

if [ -z "$latestCommitLocal" ]; then
   log_error "Error when getting local commit"
   exit 1
fi

if [ "$latestCommitRemote" != "$latestCommitLocal" ]; then
   # Danger: Git force pull to overwrite local files 
   log "Copy install.sh to ./install.sh_BAK"
   cp ./install.sh ./install.sh_BAK

   log "Start with the update."
   git fetch --all
   git reset --hard origin/master
   git pull origin master
   log "Updated Software!"
   
   log "Add execution permissions to all files with extension .sh"
   chmod +x *.sh
   
   log "Check if install.sh has modified"
   diff -q ./install.sh ./install.sh_BAK > /dev/null
   if [ $? -eq 1 ]; then
      log "install.sh has changed"
      flag=1
      log "Delete ./install.sh_BAK"
      rm -f ./install.sh_BAK
   else
      log "install.sh it has not changed"
   fi


   if [ $flag -eq 1 ]; then
      log "Run install.sh"
      sudo bash ./install.sh
      exit 0
   else
      log "Reboot System"
      sudo shutdown -r now
      exit 0
   fi

else
   log "No updates are required."
fi

exit 0



