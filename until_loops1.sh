#!/bin/bash

#until [ condition ]
#do
#  command1
#  command2
#done

num=1

until [ $num -gt 10 ]
do
  echo $num
  num=$(( num + 1 ))
done


