#!/bin/bash

while read p
do
  echo "$p"
done < ipaddr_list1

echo "####################"

cat ipaddr_list2 |
while read p
do
  echo "$p"
done 

