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
INACTIVE_DATE=$($DATE -d '90 days ago' $DATE_FORMAT)

# for AWS CLI 
AWS_OPTS="--no-cli-pager --output text"
AWS_PROFILE="$1"
[ -z $AWS_PROFILE ] && AWS_PROFILE='dev' # Default aws profile: dev

# for informations
echo -e ""
echo -e "### Current AWS Profile is (default: dev) [$AWS_PROFILE]"
echo -e "### 90 day ago date for inactive = [$INACTIVE_DATE]"

# Functions
slack-message() {
  # WEBHOOK_URL='' # dev-aws-state-change
  curl -X POST -H 'Content-type: application/json' --data \
  '{
    "icon_url": "https://a.slack-edge.com/80588/img/api/aws.png",
    "text": ":aws: *'"$AWS_PROFILE"'* @'"$1"' `'"$2"'` '"$3"'",
  }' $WEBHOOK_URL
}

list-users() {
  aws iam list-users $AWS_OPTS --profile $AWS_PROFILE --query 'Users[*].[UserName]'
}
list-access-keys() {
  aws iam list-access-keys $AWS_OPTS --profile $AWS_PROFILE --user-name $1 $2
}
update-access-keys() {
  aws iam update-access-key $AWS_OPTS --profile $AWS_PROFILE --user-name $1 --access-key-id $2 --status Inactive 
}
delete-access-keys() {
  aws iam delete-access-key $AWS_OPTS --profile $AWS_PROFILE --user-name $1 --access-key-id $2
}

# echo -e "Start inactive iam access key \n"
# for users in $(list-users); do
#   if [ $users != "superbai-phantomai" ] && [ $users != "circleci" ] && [ $users != "auto-label" ]; then
#     # echo "$users"
#     OLD_ACCESS_KEY_QL='AccessKeyMetadata[?CreateDate<=`'$INACTIVE_DATE'`].[AccessKeyId]'
#     for accesskey in $(list-access-keys $users "--query $OLD_ACCESS_KEY_QL"); do
#       # echo $accesskey
#       if update-access-keys $users $accesskey; then
#         echo "Change the state of the previous access key to inactive. $users $accesskey"
#         slack-message "$users" "$accesskey" ":warning: older than 90 days!! Status changed to :arrow_right: \`inactive\`"
#         echo ""
#         sleep 1
#       else
#         echo "$users $accesskey inactive failed"
#       fi
#     done
#   fi
# done

# echo -e "Start delete iam access key \n"
# for users in $(list-users); do
#   if [ $users != "superbai-phantomai" ] && [ $users != "circleci" ] && [ $users != "auto-label" ]; then    
#     # echo "$users"
#     OLD_ACCESS_KEY_QL='AccessKeyMetadata[?CreateDate<=`'$INACTIVE_DATE'`].[AccessKeyId]'
#     for accesskey in $(list-access-keys $users "--query $OLD_ACCESS_KEY_QL"); do
#       # echo $accesskey
#       if delete-access-keys $users $accesskey; then
#         echo "Delete the inactive access key. $users $accesskey"
#         slack-message "$users" "$accesskey" ":x: Inactive access keys have been \`deleted\`"
#         echo ""
#       else
#         echo "$users $accesskey delete failed"
#       fi
#     done
#   fi
# done

