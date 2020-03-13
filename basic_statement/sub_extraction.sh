#!/bin/bash

str1=abc012
str2=abcd0123
str3=abcde01234
str4=abcABC123ABCabc

len="${#str1} ${#str2} ${#str3}"
echo var length is : $len
echo "##########"
# Substring start number 0
# Substring Extraction ${string:position}

# 2 to end
echo "${str1:1}"
echo "${str2:1}"
echo "${str3:1}"
echo "##########"

# start 3 and 3 length
echo "${str1:2:3}"
echo "${str2:2:3}"
echo "${str3:2:3}"
echo "##########"

# match regular expression
echo `expr "$str1" : '\([a-z]*[0-9][0-9]\)'`
echo "##########"
#echo `expr "$str4" : '\(.[b-c]*[A-Z]..[0-9]\)'`

# reverse 
#echo "${str1: (-2)}"
echo "${str1: (-2)}"
echo "${str2: (-3)}"
echo "${str3: (-4):2}"
echo "##########"

echo ${str1} | rev
echo ${str2} | rev
echo ${str3} | rev
echo "##########"

for (( i = ${#str1} -1; i >= 0; i--))
do
  rev1="$rev1${str1:$i:1}"
done
echo $rev1
