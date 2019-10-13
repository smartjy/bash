#! /bin/bash

word1=abc
word2=a

if [ $word1 == 'abc' ]
then
  echo "condition is true"
fi

if [[ $word2 == 'b' ]]
then
  echo "condition b is true"
elif [[ $word2 == "a" ]]
then 
  echo "condition a is true"
else
  echo "condition b is false"
fi
