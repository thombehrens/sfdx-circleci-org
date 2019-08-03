#!/bin/bash

echo Enter a random passphrase as a temporary password
read password

#Change to your company details
country="US"
state="Indiana"
locality="Indianapolis"
organization="Thom Behrens"
organizationalunit="IT"

#Generate a key
openssl genrsa -des3 -passout pass:$password -out server.key 2048 -noout

#Remove passphrase from the key. Comment the line out to keep the passphrase
echo "Removing passphrase from key"
openssl rsa -in server.key -passin pass:$password -out server.key

#Create the request
echo "Creating CSR"
openssl req -new -key server.key -out server.csr -passin pass:$password \
    -subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit"

#Create certificate
echo "Creating certificate"
openssl x509 -req -sha256 -days 365 -in server.csr -signkey server.key -out server.crt

#Create encryption key and iv
echo "Creating encryption key and iv"
values=$(openssl enc -aes-256-cbc -k $password -P -md sha1 -nosalt)
echo "$values" > "server_secrets.txt"
key_front_strip=${values#*=}
key=${key_front_strip%%i*}
iv=${values##*=}

#Create encrypted key
echo "Creating encrypted server key"
openssl enc -nosalt -aes-256-cbc -in server.key -out server.key.enc -base64 -K $key -iv $iv

echo "---------------------------"
echo "-----Below is your CSR-----"
echo "---------------------------"
echo
cat server.csr

echo
echo "---------------------------"
echo "-----Below is your Key-----"
echo "---------------------------"
echo
cat server.key

echo
echo "---------------------------"
echo "---Encryption key and iv---"
echo "---------------------------"
echo
echo key=$key
echo iv =$iv

echo
echo "---------------------------"
echo "-------Ecrypted Key--------"
echo "---------------------------"
echo
cat server.key.enc

echo 'now go create a connected app in Salesforce using the server.crt file in this directory, per these instructions:'
echo 'https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_auth_connected_app.htm'
echo 'Collect the Consumer Key file generated on the app, enter it here: '
read $consumer_key
echo 'name of the org?: '
read $org_name

echo "$org_name Consumer Key: $consumer_key" >> "server_secrets.txt"
echo 'login @ this URL to ensure the connected app is authenticated'
echo 'https://login.salesforce.com/services/oauth2/authorize?client_id=$consumer_key&redirect_uri=http://localhost:1717/OauthRedirect&response_type=code'
