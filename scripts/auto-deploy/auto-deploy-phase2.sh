#!/usr/bin/env bash


source /usr/local/packages/deployment-variables-phase2.sh

# Rollback function
db_downgrade () {
echo "Unistalling current version..."
echo -e 'y\n' | $PIP uninstall $NAME
$PIP install $WHEEL_CURRENT
	for COUNTER in $(seq $MIGRATION_COUNTER);do
		$APP_COMMAND migrate downgrade -1
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

echo "Unistalling current version..."
echo -e 'y\n' | $PIP uninstall $NAME

echo "New deploy installation..."
$PIP install $WHEEL_NEW

echo "Checking migrations."
while [ "$CURRENT" != "$HEAD" ]
do
	$APP_COMMAND migrate upgrade +1 || db_downgrade
	CURRENT=$($APP_COMMAND migrate current)
	MIGRATION_COUNTER=$[$MIGRATION_COUNTER+1] 
done

echo "Start services..."
for SERVICE_NAME in $SERVICE;do
	systemctl start $SERVICE_NAME
done

sleep 3s

# Print stable version.
VERSION=$(curl -s localhost/apiv1/version | grep -i version | cut -d ":" -f 2)
echo "The last stable version is $VERSION"

# Remove files
rm -rf /usr/local/packages/*
