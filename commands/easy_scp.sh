#!/bin/bash

MYKEY=

input() {
  read -p "# File to send (Absolute path) : " send_file
  if [ ! -f "$send_file" ]
  then
   echo -e "# [ERROR] Can not found file!! ";
   exit;
  fi
  read -p "# remote server hostname: " rmt_htn
  read -p "# remote server account: " rmt_acc
  read -p "# remote server Directory: " rmt_dir
  echo ""

}
run_scp() {
  if [ "$rmt_acc" == "ec2-user" ]
  then
    scp -i $MYKEY $send_file $rmt_acc@$rmt_htn:$rmt_dir
  else
    scp $send_file $rmt_acc@$rmt_htn:$rmt_dir
  fi

}

confirm() {
  echo "##############################"
  echo "# You are command is like this"
  echo "##############################"
  echo -e "# SCP $send_file $rmt_acc@$rmt_htn:$rmt_dir \\n"
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

# Run the function
input
confirm
run_scp



