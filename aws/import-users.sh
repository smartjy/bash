#!/bin/bash

# AWS_OPTS="--output text"
AWS_OPTS="--output text --no-cli-pager"
USER_GROUPS=('admin' 'developers')

list-users() {
  aws iam list-users $AWS_OPTS --query "Users[*].[UserName]"
}

list-groups() {
  aws iam list-groups $AWS_OPTS --query "Groups[*].[GroupName]"
}

# list-groups-for-user() {
#   aws iam list-groups-for-user $AWS_OPTS --user-name $1 --query "Groups[].[GroupName]"
# }

get-group() {
  aws iam get-group $AWS_OPTS --group-name $1 --query "Users[].[UserName]"
}
# list-users
# list-groups-for-user jyson
# get-group admin
# get-group developers

# CNT=1
# for USER in $(list-users); do
#   # ((CNT++))
#   for GRP in $(list-groups-for-user $USER); do
#     if [] || []; then
#     fi
#     groupadd $GRP
#     mkdir -p "/data/$GRP"
#   done
# done

# for GROUP in "${USER_GROUPS[@]}"; do
  # if getent group $GROUP > /dev/null; then
  #   echo "already exists"
  # else
  #   echo "$GROUP will be created"
  #   # groupadd "$GROUP"
  #   # mkdir -p "/data/$GROUP"
  # fi
# done


for GROUP in "${USER_GROUPS[@]}"; do
  for USER in $(get-group $GROUP); do
    if id -u $USER > /dev/null 2>&1; then
      echo "$USER already exists"
    else
      echo "$USER will be created"
    fi
  done
done