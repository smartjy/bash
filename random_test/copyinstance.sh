#!/bin/bash

DIR=$(pwd)
SOURCE=
TARGET=

if [ -z $SOURCE ]; then
  echo -n "## Input SOURCE instance: "
	read source;
  SOURCE=$source
  if [ -z $SOURCE ]; then
    echo "# [ERROR] please Input SOURCE instance!!"
    exit ;
	fi
else
  find $SOURCE >/dev/null;
  if [ $? != 0 ]; then
    echo "# [ERROR] $SOURCE name was wrong!!!"
  fi
fi

if [ -z $TARGET ]; then
  echo -n "## Input TARGET instance: "
	read target;
  TARGET=$target
  if [ -z $target ]; then
    echo "# [ERROR] please Input TARGET instance!!"
    exit ;
	fi
else
  cp -r $SOURCE $TARGET
  if [ $? != 0 ]; then
    echo "# [ERROR] Something wrong while copy from $SOURCE!!!"
    exit;
  fi
fi

