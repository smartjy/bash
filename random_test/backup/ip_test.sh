#!/bin/sh

suba=192
subb=168
subc=23
subd=100

#ipaddr=$suba\.$subb\.$subc\.$subd
#echo $ipaddr
echo "##########################"

#for $subc in 0 1 2 3 4 5
#do
#  echo $subc;
#  subc=`expr $subc + $i`;
#  sleep 1;
#  ipaddr=$suba.$subb.$subc.$subd
#  echo "$ipaddr"
#done

while true 
do
  subd=`expr $subd + 1`;
  sleep 1;
  ipaddr=$suba\.$subb\.$subc\.$subd
  echo "$ipaddr"
done
