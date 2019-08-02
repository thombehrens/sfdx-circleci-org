#! /bin/bash

# Set Audience - https://salesforce.stackexchange.com/a/253940
export SFDX_AUDIENCE_URL=https://test.salesforce.com
#Authorize target org
sfdx force:auth:jwt:grant --instanceurl $ENDPOINT  --clientid $CONSUMER_KEY --jwtkeyfile assets/server.key --username $USER_NAME --setalias UAT

#Deploy as sfdx source - this is a quicker deployment that should be used for non-production orgs
sfdx force:source:deploy -p force-app/main/default/ -u $USER_NAME

##Convert & deploy as mdapi - this is a longer deployment, should be used for prod deployments, as it is more stable. Can be tracked through "Deployment Status" in the target org.
#sudo sfdx force:source:convert -r force-app -d /deploy
#sfdx force:mdapi:deploy --wait 10 --deploydir /deploy --targetusername UAT --testlevel $TESTLEVEL
