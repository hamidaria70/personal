#!/bin/bash
# This is a test script for mobile token project.

set -e

# In this section, variables are defined and valued.

AGAMA_HOST="192.168.1.51"
WOLF_HOST="192.168.1.51:82"
AGAMA_TOKEN="eyJhbGciOiJIUzI1NiIsImlhdCI6MTU4NzQ3Mjc3MCwiZXhwIjoxMDAwMDAwMDAwMTU4NzQ3Mjc2OX0.e30.OLWyLndboDIkCSFr4Y0CDgpxR_soqVsQEldoHlARKR4"
UDID="2b6f0cc904d137be2e1730235f5664094b831186"
BANK_ID=1
CRYPTO_MODULE_ID=1
PARTIALCARDNUMBER="6037991010145698"
EXPIRE_DATE=1699160200
NAME="Hamid Aria"
PHONE=09399638524
WOLF_CMD="sudo -u mt /usr/local/bin/wolf -c /etc/mobile-token/wolf.yml"
HOST="hamid@192.168.1.51"

curl "http://$AGAMA_HOST/apiv1/devices" -X CLAIM -i \
	-H"Authorization: $AGAMA_TOKEN" \
	-F"udid=$UDID" \
	-F"phone=$PHONE" \
	-F"bankId=$BANK_ID" 

ACTIVATION_CODE=$(curl $AGAMA_HOST | tail -1 | cut -d "," -f 2)

curl "http://$AGAMA_HOST/apiv1/devices" -X BIND -i \
	-H"Authorization: $AGAMA_TOKEN" \
	-F"phone=$PHONE" \
	-F"name=$NAME" \
	-F"activationCode=$ACTIVATION_CODE" \
	-F"bankId=$BANK_ID" \
	-F"udid=$UDID" 


curl "http://$WOLF_HOST/apiv1/cardtokens" -X ENSURE -i \
	-F"cryptomoduleId=$CRYPTO_MODULE_ID" \
	-F"phone=$PHONE" \
	-F"expireDate=$EXPIRE_DATE" \
	-F"bankId=$BANK_ID" \
	-F"partialCardName=$PARTIALCARDNUMBER" | tee /tmp/token_id.txt

TOKEN_ID=`grep "id" /tmp/token_id.txt  | head -1 | cut -d ":" -f 2 | sed 's/,$//'`
GENERATE=`ssh $HOST $WOLF_CMD otp -t $TOKEN_ID generate`
PINBLOCK=`ssh $HOST $WOLF_CMD pinblock -t $TOKEN_ID encode $GENERATE`

curl "http://$WOLF_HOST/apiv1/tokens/$TOKEN_ID/codes/$PINBLOCK?primitive=yes" \
	-X VERIFY -i 

curl "http://$WOLF_HOST/apiv1/sendotp?" -X POST -i \
	-F "tokenId=$TOKEN_ID" \
	-F "trace=Sample-trace"

