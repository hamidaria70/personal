#!/usr/bin/env bash

set -eu

# Define varibales as hardcode to use.
NAME=agama
WHEEL_PATH="/home/hamid"
APP_COMMAND="sudo -u mt /usr/local/bin/$NAME -c /etc/mobile-token/$NAME.yml"
HEAD=$($APP_COMMAND migrate heads)
CURRENT=$(($APP_COMMAND migrate current) >&1)
CURRENT_VERSION=$(curl -s localhost/apiv1/version \
	|grep -i version | cut -d ":" -f 2 | cut -d '"' -f 2) 
#FIXME from here to line 18
NEW_VERSION=
echo "new version is $NEW_VERSION"
WHEEL_NEW=$(find $WHEEL_PATH -name "$NAME-$NEW_VERSION*.whl") #fixing line 14 will FIXME ;)
echo "wheel new is $WHEEL_NEW"
#FIXME from line 13 to here
WHEEL_CURRENT=$(find $WHEEL_PATH -name "$NAME-$CURRENT_VERSION*.whl")
SERVICE="$NAME"
PIP=/usr/local/bin/pip3.6
MIGRATION_COUNTER=0

# Rollback function
db_downgrade () {
	for COUNTER in $(seq $DOWNGRADE_COUNTER);do
		$APP_COMMAND migrate downgrade $COUNTER
		$PIP install $WHEEL_CURRENT
	done
echo "Start services..."
for SERVICE_NAME in $SERVICE;do
	systemctl start $SERVICE_NAME
done
exit
}

echo "Checking if the user is root or not."
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
   else
        echo "Yes...Root Account"
fi

echo "Checking if there is .whl file or not."
if [ -f "$WHEEL_NEW" ] && [ -f "$WHEEL_CURRENT" ] ;then
        echo "whl files are here..."
	elif [ -f "$WHEEL_NEW" ];then
		echo "Make sure that you have current version wheel"
        exit 1
	elif [ -f "$WHEEL_CURRENT" ];then
		echo "Nothing to deploy"
		exit 1;
	else
        echo "Make sure that you have correct whl file in this directory."
		exit 1;
fi

echo "Stop services..."
for SERVICE_NAME in $SERVICE;do
	systemctl stop $SERVICE_NAME
done

echo "New deploy installation..."
$PIP install $WHEEL_NEW

echo "Checking migrations."
while [ "$CURRENT" != "$HEAD" ]
do
	DOWNGRADE_COUNTER=$[$MIGRATION_COUNTER-1]
	$APP_COMMAND migrate upgrade +1 || db_downgrade
	CURRENT=$($APP_COMMAND migrate current)
	MIGRATION_COUNTER=$[$MIGRATION_COUNTER+1] 
done

echo "Start services..."
for SERVICE_NAME in $SERVICE;do
	systemctl start $SERVICE_NAME
done

# Print stable version.
VERSION=$(curl -s localhost/apiv1/version | grep -i version | cut -d ":" -f 2)
echo "The last stable version is $VERSION"

