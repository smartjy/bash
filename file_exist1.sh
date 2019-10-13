#! /bin/bash

echo -e "Enter the name of the file : \c"
read file_name

if [ -e $file_name ] # nomal file
#if [ -f $file_name ] # regular file
#if [ -d $file_name ]  # directory
then
  echo "$file_name found"
else
  echo "$file_name not found"
fi

if [ -s $file_name ]  
then
  echo "$file_name not empty "
else
  echo "$file_name empty"
fi
