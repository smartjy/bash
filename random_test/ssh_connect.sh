#!/bin/sh
password=root

ssh -oStrictHostKeyChecking=no  root@192.168.15.100

stty -echo
read $password
stty echo
#print '\n'

#echo -n "Password: "
#stty -echo
#read password
#stty echo
# 
# echo ""         # force a carriage return to be output
# echo You entered $password


