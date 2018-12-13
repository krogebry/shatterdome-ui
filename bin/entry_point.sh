#!/usr/bin/env bash

## Grab private ssh key from s3
# aws --region us-gov-west-1 ssm get-parameter --name "/aerion/hpc/gcmgr/private_key" --with-decryption |jq -r '.Parameter.Value' > /root/.ssh/id_rsa
# chmod 400 /root/.ssh/id_rsa

./bin/gcmgr.rb
