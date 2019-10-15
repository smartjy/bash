#!/bin/bash

#while [ condition ]
#do
#	command1
#	command2
#	command3
#done

num=1

#while [ $num -le 10 ]
while (( $num <= 10 ))
do
  echo "$num"
#	num=$(( num+1 ))
	(( num++ ))
done

