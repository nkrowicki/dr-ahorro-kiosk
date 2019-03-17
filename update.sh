#!/bin/bash

# Vars
# Full path of this file without filename
pathProject=`dirname $(realpath $0)`

# Cd folder that contain project
cd $pathProject

# Load quickLog
source quickLog.sh

# Load checkInternet
source checkInternet.sh

# Load reloadKiosk
source reloadKiosk.sh

log "Check for updates..."

# Check internet
checkInternet

# Get Latest remote commit of branch head/master
latestCommitRemote=`git ls-remote origin -h refs/heads/master | awk '{print $1}'`
latestCommitLocal=`git log -n1 | awk '{print $2}' | head -n 1`

if [ -z "$latestCommitRemote" ]; then
   log "Error when getting remote commit"
   exit 1
fi

if [ -z "$latestCommitLocal" ]; then
   log "Error when getting local commit"
   exit 1
fi

if [ "$latestCommitRemote" != "$latestCommitLocal" ]; then
   git pull origin master
   log "Updated Software!"
   reloadKiosk
else
   log "No updates are required."
fi

exit 0



