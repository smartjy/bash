#!/usr/bin/env bash

DATE_FORMAT='+%Y-%m-%dT%H:%M:%S'
DATE=$(date $DATE_FORMAT)
INACTIVE_DATE=$(gdate -d '5 days ago' $DATE_FORMAT)
# INACTIVE_DATE=$(gdate -d '1 mins ago' $DATE_FORMAT)
DELETE_DATE=
AWS_PROFILE=''
AWS_OPTS="--no-cli-pager --output text"

# USERS=$(aws --no-cli-pager --output text iam list-users  --query 'Users[*].[UserName]')
USERS=$(aws iam list-users --query 'Users[*].[UserName]' --no-cli-pager --output text)
list-access-keys() {
  # echo "### Access key IDs associated with the specified IAM user"
  aws iam list-access-keys $AWS_OPTS --user-name $1 --query 'AccessKeyMetadata[?CreateDate>=`'$2'`].[AccessKeyId]'
}

update-access-keys() {
  echo "### Changes the status of the specified access key from Active to Inactive"
  aws iam update-access-key $AWS_OPTS --access-key-id $1 --status Inactive --user-name $2
}


for USER in $USERS; do
  if [ "$USER" == 'access-key-test' ]; then
    echo "### IAM user == $USER  "
    # echo "### Get ACCESS-KEYS of $USER"
    # aws iam list-access-keys --user-name $USER --query 'AccessKeyMetadata[?CreateDate>=`'$DATE'`].[AccessKeyId]' --no-cli-pager --output text 
    # list-access-keys $USER $INACTIVE_DATE
    for ACCESS_KEY in $(list-access-keys $USER $INACTIVE_DATE); do
      echo "Inactive keys $ACCESS_KEY"
      update-access-keys $ACCESS_KEY $USER
    done
    # echo "Create ACCESS-KEYS of $USER"
    # aws iam create-access-key --user-name $USER --no-cli-pager --output text 
    break
  fi
done

# curl -X POST -H 'Content-type: application/json' --data '{"text":"Hello, World!"}' YOUR_WEBHOOK_URL