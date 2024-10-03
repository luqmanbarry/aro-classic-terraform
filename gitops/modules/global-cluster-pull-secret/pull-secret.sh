#!/bin/bash

NEW_CLOUD_AUTH=$(cat secrets/pull-secret.json | jq -r '.auths."cloud.openshift.com"')
echo $NEW_CLOUD_AUTH
cat secrets/pull-secret-new.json | jq -r --argjson new_json "$NEW_CLOUD_AUTH" '.auths += {"cloud.openshift.com" : $new_json }' > secrets/pull-secret-add.json