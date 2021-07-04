#!/usr/bin/env bash
# set -x

check_cmd() {
  type "$1" &>/dev/null
  [ "$?" != '0' ] && echo -e "Command not found: $1, Please try again" && exit
}

if [ "$SHELL" != '/usr/local/bin/zsh' ]; then
  echo "SHELL is not zsh"
fi

check_cmd aws
check_cmd curl

PKG_NAME="AWSCLIV2.pkg"
PKG_URL="https://awscli.amazonaws.com/$PKG_NAME"

DOWNLOAD_LOC="$HOME/Downloads/AWS"
[ -z "$DOWNLOAD_LOC" ] && mkdir "$DOWNLOAD_LOC"
curl $PKG_URL -o "$DOWNLOAD_LOC/$PKG_NAME"
