#!/bin/bash
# This is a test script for mobile token project.

set -e

# In this section, variables are defined and valued.
SWAN_HOST="192.168.1.51:83"
AGAMA_HOST="192.168.1.51"
WOLF_HOST="192.168.1.51:82"
AGAMA_TOKEN="eyJhbGciOiJIUzI1NiIsImlhdCI6MTU4NzQ3Mjc3MCwiZXhwIjoxMDAwMDAwMDAwMTU4NzQ3Mjc2OX0.e30.OLWyLndboDIkCSFr4Y0CDgpxR_soqVsQEldoHlARKR4"
SWAN_TOKEN="eyJhbGciOiJIUzI1NiIsImlhdCI6MTU4NzgxNDcxMywiZXhwIjoxMDAwMDAwMDAxNTg3ODE0NzEyfQ.e30.FomDrjZnZbmIwQFq2rp-jDPpc_PrLC_dXrexM4O_ylY"
UDID="2b6f0cc904d137be2e1730235f5664094b831186"
BANK_ID=1
CRYPTO_MODULE_ID=1
PARTIALCARDNUMBER="6037991010145698"
EXPIRE_DATE=1699160200
PHONE="989122451075"
WOLF_CMD="sudo -u mt /usr/local/bin/wolf -c /etc/mobile-token/wolf.yml"
PASSWORD=1234

curl "$SWAN_HOST/apiv1/virtualdevices?" -X CLAIM -i \
	-H "Authorization: $SWAN_TOKEN" \
	-F "phone=$PHONE" \
	-F "bankId=$BANK_ID" 

ACTIVATION_CODE=$(curl $AGAMA_HOST | tail -1 | cut -d "," -f 2)

curl "$SWAN_HOST/apiv1/virtualdevices?" -X BIND -i \
	-H "Authorization: $SWAN_TOKEN" \
	-F "phone=$PHONE" \
	-F "activationCode=$ACTIVATION_CODE" \
	-F "bankId=$BANK_ID" \
	-F "password=$PASSWORD"


curl "http://$WOLF_HOST/apiv1/cardtokens" -X ENSURE -i \
	-F"cryptomoduleId=$CRYPTO_MODULE_ID" \
	-F"phone=$PHONE" \
	-F"expireDate=$EXPIRE_DATE" \
	-F"bankId=$BANK_ID" \
	-F"partialCardName=$PARTIALCARDNUMBER" | tee /tmp/token_id.txt \
	| tee /tmp/reprovision-token.txt

REPROVISION_TOKEN=`grep "reprovisionCode" /tmp/reprovision-token.txt  | cut -d ":" -f 2 | sed 's/,$//'`

curl "http://$SWAN_HOST/apiv1/tokens" -X ADD -i \
	-H "Authorization: $SWAN_TOKEN" \
	-F "reprovisionToken=$REPROVISION_TOKEN"

curl "http://$SWAN_HOST/apiv1/tokens?" -X LIST -i \
	-H "Authorization: $SWAN_TOKEN" \
	-F "phone=$PHONE"

curl "http://$SWAN_HOST/apiv1/onetimepasswords?" -X GENERATE -i \
	-H "Authorization: $SWAN_TOKEN" \
	-F "password=$PASSWORD" \
	-F "cryptoModuleId=$CRYPTO_MODULE_ID" \
	-F "phone=$PHONE" \
	-F "bankId=$BANK_ID" \
	-F "name=$PARTIALCARDNUMBER"
