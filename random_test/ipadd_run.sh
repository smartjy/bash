#!/bin/sh

suba=192
subb=168
subc=23
subd=100

ipaddr=$suba\.$subb\.$subc\.$subd

#echo $ipaddr
echo "##########################"

#CMD=`sshpass -proot scp ./ip_get.sh root@$ipaddr:/tmp/`

#echo "This is deploy server $ipaddr "

while true
do

  subd=`expr $subd + 1`;
  ipaddr=$suba\.$subb\.$subc\.$subd
	echo "subd = $subd";
	echo "ipaddr = $ipaddr";
	sleep 1;
  PING="`ping -c 1 -w 1 $ipaddr`";

  if [ $? -eq 0 ]; then 
    ipaddr=$suba\.$subb\.$subc\.$subd
		echo "Prepared $ipaddr";
    CMD=`sshpass -proot scp ./ip_get.sh root@$ipaddr:/tmp/`;
    $CMD
		sleep 1;
		echo "deployed $ipaddr";
	else
		echo "stopped  $ipaddr";
		break
  fi

done



