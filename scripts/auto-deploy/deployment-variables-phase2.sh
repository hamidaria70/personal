#!/bin/bash                                                                                           

set -e

# Define varibales as hardcode to use.                                         
# Phase 2                                                                      
                                                                               
NAME=dolphin                                                                
WHEEL_PATH="/home/hamid"                                                                             
APP_COMMAND="sudo -u maestro /usr/local/bin/$NAME -c /etc/maestro/$NAME.yml"   
HEAD=$($APP_COMMAND migrate heads)                                             
CURRENT=$(($APP_COMMAND migrate current) >&1)                                  
CURRENT_VERSION=$(curl -s localhost/apiv1/version | \
	grep -i version | cut -d ":" -f 2 | cut -d '"' -f 2)                      
                                                                               
WHEEL_NEW=$(find $WHEEL_PATH -maxdepth 1 -type f \
	\( ! -name "*$CURRENT_VERSION*.whl" ! -name "*.sh" ! -name ".*" \))        

WHEEL_CURRENT=$(find $WHEEL_PATH -name "$NAME-$CURRENT_VERSION*.whl")          
SERVICE="$NAME dolphin-worker dolphin-mule jaguar jaguar-websocket jaguar-router panda panda-worker"
PIP=/usr/local/bin/pip3.6                                                      
MIGRATION_COUNTER=0      
