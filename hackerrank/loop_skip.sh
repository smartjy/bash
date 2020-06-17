#!/bin/bash

num1=1
num2=10

# num1 >= num2
while (( $num1 < $num2 ))
do
  echo $num1
#  (( num1=+2 ))
  ((num1 = num1 + 2))
done

