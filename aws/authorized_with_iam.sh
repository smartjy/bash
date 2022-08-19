#!/bin/bash

AWS_OPTS="--output text"

[ -z "$1" ] && echo "[ERROR] At least one argument is required." && exit 1

list-ssh-public-keys() {
  aws iam list-ssh-public-keys $AWS_OPTS --user-name $1 --query "SSHPublicKeys[?Status=='Active'].[SSHPublicKeyId]"
}

list-groups-for-user() {
  aws iam list-groups-for-user $AWS_OPTS --user-name $1 --query "Groups[].[GroupName]"
}

get-ssh-public-key() {
  aws iam get-ssh-public-key $AWS_OPTS --user-name $1 --ssh-public-key-id $2 --encoding SSH --query "SSHPublicKey.SSHPublicKeyBody"
}

for KEYID in $(list-ssh-public-keys $1); do
  for GRP in $(list-groups-for-user $1); do
    if [ "$GRP" == "admin" ] || [ "$GRP" == "developers" ]; then
    get-ssh-public-key $1 $KEYID
    fi
  done
done