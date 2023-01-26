#!/usr/bin/env bash

# Environment Variables
AWS_OPTS="--no-cli-pager --output text"

PLATFORM="$(uname)"
case $PLATFORM in 
  "Darwin")
    DATE='gdate' ;;
  *)
    DATE='date' ;;
esac

DATE_FORMAT='+%Y-%m-%dT%H:%M:%S'
INACTIVE_DATE=$($DATE -d '95 days ago' $DATE_FORMAT)

# for AWS CLI 
AWS_OPTS="--no-cli-pager --output text"
AWS_PROFILE="$1"
# Default aws profile: suite-dev
[ -z $AWS_PROFILE ] && AWS_PROFILE='suite-dev'

# for informations
echo -e ""
echo -e "### Current AWS Profile is [$AWS_PROFILE]"
echo -e "### 90 day ago date for inactive = [$INACTIVE_DATE]"

# Functions
slack-message() {
  YOUR_WEBHOOK_URL='https://hooks.slack.com/services/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' # dev-aws-state-change
  curl -X POST -H 'Content-type: application/json' --data \
  '{
    "icon_url": "https://a.slack-edge.com/80588/img/api/aws.png",
    "text": ":aws: *'"$AWS_PROFILE"'* @'"$1"' `'"$2"'` '"$3"'",
  }' $YOUR_WEBHOOK_URL
}

list-users() {
  aws iam list-users $AWS_OPTS --query 'Users[*].[UserName]'
}
list-access-keys() {
  aws iam list-access-keys $AWS_OPTS --user-name $1 $2
}
update-access-keys() {
  aws iam update-access-key $AWS_OPTS --user-name $1 --access-key-id $2 --status Inactive 
}
delete-access-keys() {
  aws iam delete-access-key $AWS_OPTS --user-name $1 --access-key-id $2
}
# Start delete iam access key
for users in $(list-users); do
  if [[ $users == "test-rotate"* ]]; then
    # echo "$users"
    OLD_ACCESS_KEY_QL='AccessKeyMetadata[?CreateDate<=`'$INACTIVE_DATE'`].[AccessKeyId]'
    for accesskey in $(list-access-keys $users "--query $OLD_ACCESS_KEY_QL"); do
      # echo $accesskey
      if update-access-keys $users $accesskey; then
        echo "Change the state of the previous access key to inactive. $users $accesskey"
        slack-message "$users" "$accesskey" ":warning: Active access key is older than 90 days!! Status changed active :arrow_right: inactive"
        sleep 5
      else
        echo "$users $accesskey inactive failed"
      fi
      if delete-access-keys $users $accesskey; then
        delete-access-keys $users $accesskey
        echo "Delete the inactive access key. $users $accesskey"
        slack-message "$users" "$accesskey" ":bangbang: Inactive access keys have been deleted"
      else
        echo "$users $accesskey delete failed"
      fi
    done
  fi
done

