#!/bin/bash

for command in ls pwd date
do
  echo "# $command #########################################"
  $command
done

for item in *
do
  if [ -d $item ]
  then
    echo "# DIRECTORY  #########################################"
    echo $item
  fi
done

