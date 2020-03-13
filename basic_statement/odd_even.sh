#!/bin/bash

for ips in $(cat ipaddr_list1);
do
  subip="${ips: (-1):1}"

  if [ "$(($subip % 2))" != 0 ]
  then
    echo "$ips is odd"
  fi
  if [ "$(($subip % 2))" == 0 ]
  then
    echo "$ips is even"
  fi 
  
done
