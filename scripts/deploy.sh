#! /bin/bash

# Set Audience - https://salesforce.stackexchange.com/a/253940
export SFDX_AUDIENCE_URL=https://test.salesforce.com

#Authorize target org - This depends on the consumer key and username CCI environment variables being named after the branch associated with them, i.e.:
# if deploying from branch DEV_INT,
# Consumer Key variable must be named DEV_INT_CONSUMER_KEY and
# Username variable must be named DEV_INT_USER_NAME

CONSUMER_KEY=$CIRCLE_BRANCH\_CONSUMER_KEY
USER_NAME=$CIRCLE_BRANCH\_USER_NAME

# Authorize against the org
sfdx force:auth:jwt:grant --instanceurl $ENDPOINT  --clientid ${!CONSUMER_KEY} --jwtkeyfile assets/server.key --username ${!USER_NAME} --setalias DEPLOYMENT_ORG

#Listing out all branches which should use mdapi deployment. This should be a subset of the branches listed in .circlci/config.yml
#In most cases, this should only be one branch - prod - but keeping array syntax so it can scale easily
mdapi_branches=("thomTarget")

if [[ " ${mdapi_branches[@]} " =~ " ${CIRCLE_BRANCH} " ]]; then
  ##Convert & deploy as mdapi - this is a longer deployment, should be used for prod deployments, as it is more stable. Can be tracked through "Deployment Status" in the target org.
  sudo sfdx force:source:convert -r force-app -d /deploy
  sfdx force:mdapi:deploy --wait 10 --deploydir /deploy --targetusername DEPLOYMENT_ORG --testlevel $TESTLEVEL
else
  #Deploy as sfdx source - this is a quicker deployment that should be used for non-production orgs
  sfdx force:source:deploy -p force-app/main/default/ -u DEPLOYMENT_ORG
fi
