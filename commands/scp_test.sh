#!/bin/bash

#echo -e "## EASY SCP SCRIPT ##"
#echo -e "## SCP START ## \\n"
#echo -e "##  ## \\n"
#echo -n "# Source Server: "  
#read SRC_SVR
#echo -e "# This is $SRC_SVR "

#echo -n "# Source File: "  
#read SRC_FILE
#echo -e "# This is $SRC_FILE "

#find() {
#}

#read -p "# Do you want to find a file? (yes or no) " ans
#if [ "$ans" == "yes" ]
#then
#  read -p "# Where is the file directory? " file_dir
#  read -p "# What is the file name? " file_name
#  find "$file_dir" -type f -name "$file_name"
#  find_rs=$?
##  if [ "find_rs" != "0" ]
#fi  
MYKEY=


input() {

#  read -p "# File path(Default: $HOME/Download): " file_dir
  read -p "# File to send (Absolute path) : " send_file
  [ ! -f "$send_file" ] && echo -e "# [ERROR] Can not found file!! "; exit
  read -p "# remote server hostname: " rmt_htn
  read -p "# remote server account: " rmt_acc
  read -p "# remote server Directory: " rmt_dir

}

confirm() {
  echo "# You are command is like this"
  echo "# SCP $send_file $rmt_acc@$rmt_htn:$rmt_dir "
  while true
  do
    read -p "# Send to file to Remote Server? (Yes or No)" yesno
    case $yesno in
      [Yy]* ) echo "# You answered Yes."; break ;;
      [Nn]* ) echo "# You answered No."; exit ;; 
      * ) echo "# Plase Answer Yes or No.";;
    esac
  done
}
input
confirm



#scp -i $MYKEY $send_file $rmt_acc@$rmt_htn:$rmt_dir

