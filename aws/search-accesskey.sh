#!/usr/bin/env bash

PLATFORM="$(uname)"
# echo -e "### Platform is $PLATFORM"
DATE='date'

if [ "$PLATFORM" == 'Darwin' ];then
  DATE='gdate'
  ! [ -x "$(command -v $DATE)" ] && echo -e "### $DATE command not found if you need to install do this (brew install coreutils)" && exit
fi
# date environment variables
DATE_FORMAT='+%Y-%m-%dT%H:%M:%S'
# DATE_COMMON=$($DATE $DATE_FORMAT)
INACTIVE_DATE=$($DATE -d '90 days ago' $DATE_FORMAT)
DELETE_DATE=$($DATE -d '($INACTIVE_DATE +5 days)' $DATE_FORMAT)

# aws cli environment variables 
AWS_PROFILE="$1"
AWS_OPTS="--no-cli-pager --output text"

# if aws prifile was null default profile is suite-dev 
[ -z $AWS_PROFILE ] && AWS_PROFILE='suite-dev'

echo -e ""
echo -e "### Current AWS Profile is $AWS_PROFILE \n"
echo -e "### Access key Inactive day = $INACTIVE_DATE"
echo -e "### Access key Delete day = $DELETE_DATE \n"

slack-message() {
  # YOUR_WEBHOOK_URL='' # kr-team-rnd-dev
  YOUR_WEBHOOK_URL='' # github-actions
  curl -X POST -H 'Content-type: application/json' --data \
  '{
    "icon_url": "https://a.slack-edge.com/80588/img/api/aws.png",
    "text": "*'"$AWS_PROFILE"'* @'"$1"' `'"$2"'` '"$3"'",
  }' $YOUR_WEBHOOK_URL
}

list-users() {
  # echo "### Returns all users in the Amazon Web Services account"
  aws iam list-users $AWS_OPTS --query 'Users[*].[UserName]'
}

list-access-keys() {
  # echo "### Access key IDs associated with the specified IAM user"
  aws iam list-access-keys $AWS_OPTS --user-name $1 $2
}

update-access-keys() {
  # echo "### Changes the status of the specified access key from Active to Inactive"
  aws iam update-access-key $AWS_OPTS --user-name $1 --access-key-id $2 --status Inactive 
}

delete-access-keys() {
  # echo "### Deletes the access key pair associated with the specified IAM user"
  aws iam list-access-keys $AWS_OPTS --user-name $1 $2
}

for USER in $(list-users); do
  OLD_ACCESS_KEY_QL='AccessKeyMetadata[?CreateDate<=`'$INACTIVE_DATE'`].[AccessKeyId]'
  for ACCESS_KEY in $(list-access-keys $USER "--query $OLD_ACCESS_KEY_QL" ); do
    # update-access-keys $USER $ACCESS_KEY 
    slack-message "$USER" "$ACCESS_KEY" ":warning: Active access key is older than 90 days!! Status changed active :arrow_right: inactive"
  done
done

# for USER in $(list-users); do
#   INACTIVE_ACCESS_KEY_QL='AccessKeyMetadata[?Status<=`Inactive`].[AccessKeyId]'
#   for ACCESS_KEY in $(delete-access-key $USER "--query $INACTIVE_ACCESS_KEY_QL"); do
#     slack-message "$USER" "$ACCESS_KEY" ":point_left: Inactive access keys have been deleted"
#   done
# done



