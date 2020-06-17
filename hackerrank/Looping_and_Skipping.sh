#!/bin/bash

num=1

while  [ $num -lt 10 ]
do
  echo $num
  num=$(($num+2))
done
