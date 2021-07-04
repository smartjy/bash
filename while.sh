#!/bin/bash

while [ "$1" != '2' ]; do
  read -p "What Helm version do you want? [ 2 or 3 ] " num 
  [ "$num" == '2' ] && break
  sleep 2;
done