#!/usr/bin/env bash

DATE=$(date -u '+%Y-%m-%d')
AWS_PROFILE=''
AWS_OPTS="--no-cli-pager"

# USERS=$(aws --no-cli-pager --output text iam list-users  --query 'Users[*].[UserName]')
USERS=$(aws iam list-users --query 'Users[*].[UserName]' --no-cli-pager --output text)

for USER in $USERS; do
  if [ "$USER" == 'access-key-test' ]; then
    echo "iam user == $USER  "
    echo "Get ACCESS-KEYS of $USER"
    aws iam list-access-keys --user-name $USER --query 'AccessKeyMetadata[*].[AccessKeyId]' --no-cli-pager --output text 
    echo "Create ACCESS-KEYS of $USER"
    aws iam create-access-key --user-name $USER --no-cli-pager --output text 
  fi
done
