#!/bin/sh

suba=192
subb=168
subc=23
subd=100

ipaddr=$suba\.$subb\.$subc\.$subd

CMD=`sshpass -proot scp ./ip_get.sh root@$ipaddr:/tmp/`

echo $CMD

$CMD

