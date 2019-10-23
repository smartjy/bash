#!/bin/sh

sub1=192
sub2=168
sub3=23
sub4=100

count=0
stop=5 
       
ipaddr=$sub1\.$sub2\.$sub3\.$sub4
       
echo "1111111111111111111111111111"
echo $ipaddr
       
while true; do
  sleep 1;
  echo "2222222222222222222222222222"
  echo $ipaddr 

  if [ $sub3 -eq $stop ]; then
    sub3=$(($sub3 + 1))

    echo "STOP"
    echo "3333333333333333333333333333"
    echo $ipaddr
  fi   
done   

