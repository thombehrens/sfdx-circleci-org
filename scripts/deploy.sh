#! /bin/bash

echo ${CIRCLE_BRANCH}
sfdx force:source:deploy -p force-app/main/default/ -u $USER_NAME
