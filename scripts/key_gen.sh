#!/bin/bash
rm server*
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
key_front_strip=${values#*=}
key=${key_front_strip%%i*}
iv=${values##*=}

echo "$DECRYPTION_KEY=${key}" >> "server_secrets.txt"
echo "$DECRYPTION_IV=${iv}" >> "server_secrets.txt"

#Create encrypted key
echo "Creating encrypted server key"
openssl enc -nosalt -aes-256-cbc -in server.key -out server.key.enc -base64 -K $key -iv $iv

#Output keys
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
echo
echo
echo 'certificate, key, and encrypted key added to this folder.'
echo 'CCI variables added to server_secrets.txt'



addOrg='y'
while [ "$addOrg" == "y" ]
do
echo
echo
echo 'now go create a connected app in the Salesforce org using the server.crt file in this directory.'
echo
echo 'follow these instructions for help: https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_auth_connected_app.htm'
echo
echo 'Collect the Consumer Key file generated on the app, enter it here: '
read consumer_key
echo
echo 'username for the org?: '
read user_name
echo
echo 'name of the corresponding branch?: '
read branch_name
echo 'saving Consumer Key & User Name to server_secrets.txt'
echo "${branch_name}_CONSUMER_KEY=${consumer_key}" >> "server_secrets.txt"
echo "${branch_name}_USER_NAME=${user_name}" >> "server_secrets.txt"
echo 'login @ this URL to ensure the connected app is authenticated (redirect will be invalid - thats ok'
echo 'https://login.salesforce.com/services/oauth2/authorize?client_id='$consumer_key'&redirect_uri=http://localhost:1717/OauthRedirect&response_type=code'
echo "After you've authenticated, press 'y' to add another org, or any other string to quit."
read addOrg
done
