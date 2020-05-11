#!/bin/bash

set -e

LOG_DIR="/var/log/nginx/"
STATUS="Response:200"
METHOD="VERIFY"
echo -e "The date format must be like YYMMDD.\nFor Example : 20200125\nDO NOT USE ANY DELIMITER"
read -p "Please Enter Start Date:" START_DATE
read -p "Please Enter End Date:" END_DATE

let DIFF=(`date +%s -d $END_DATE`-`date +%s -d $START_DATE`)/86400+1

for COUNTER in $(seq $DIFF);do
	let	PLUS_DAY=`date +%s -d $START_DATE`-1+$COUNTER*86400
	DATE=`date '+%Y%m%d' -d  @$PLUS_DAY`
	INPUT=`sudo find $LOG_DIR -name "access*$DATE.gz"`
	if [ -z "$INPUT" ]
	then
		echo -e "\nThere is nothing on $DATE\n"
	else
		echo -e "\033[0;31mOn $DATE :\033[0m"
		echo "Success $METHOD : `sudo zcat $INPUT \
			| grep  "$METHOD" | grep -i "$STATUS" \
			| wc -l` "
		echo "Unsuccess $METHOD : `sudo zcat $INPUT \
			| grep  "$METHOD" | grep -vi "$STATUS" \
			| wc -l` "
	fi
done
