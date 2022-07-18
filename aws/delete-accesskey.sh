#!/usr/bin/env bash

DATE_FORMAT='+%Y-%m-%dT%H:%M:%S'
DATE=$(date $DATE_FORMAT)
INACTIVE_DATE=$(gdate -d '5 days ago' $DATE_FORMAT)
DELETE_DATE=$(gdate -d '($INACTIVE_DATE +5 days)' $DATE_FORMAT)
AWS_PROFILE=''
AWS_OPTS="--no-cli-pager --output text"

echo "### Access key Inactive day = $INACTIVE_DATE"
echo "### Access key Delete day = $DELETE_DATE"

USERS=$(aws iam list-users --query 'Users[*].[UserName]' --no-cli-pager --output text)

list-access-keys() {
  # echo "### Access key IDs associated with the specified IAM user"
  aws iam list-access-keys $AWS_OPTS --user-name $1 --query 'AccessKeyMetadata[?Status==`Inactive`].AccessKeyId'
}

delete-access-keys() {
  echo "### Deletes the access key pair associated with the specified IAM usere"
  aws iam delete-access-key $AWS_OPTS --access-key-id $1 --user-name $2
}


for USER in $USERS; do
  if [ "$USER" == 'access-key-test' ]; then
    echo "### IAM user == $USER  "
    for ACCESS_KEY in $(list-access-keys $USER); do
      echo "Delete keys $ACCESS_KEY"
      delete-access-keys $ACCESS_KEY $USER
    done
    break
  fi
done