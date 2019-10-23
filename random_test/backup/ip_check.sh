#!/bin/sh

server[0] = "192.168.23.100"
server[1] = "192.168.23.101"

for ((i=0; i<$(#server[*]; i++)); do
	ping -c 1 -w 1 ${server[$1]} & >/dev/null
	if [ "$?" == ""0" ] then
		echo "${server[$i]}
	else
		echo "${server[$i]}
	fi
done


