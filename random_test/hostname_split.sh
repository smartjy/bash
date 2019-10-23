#!/bin/bash

# ex hotel ols
#SERVERNAME=htolsa01
#SERVERNAME=arapsad02
while read list; do
SERVERNAME="$list"
echo "# SERVERNAME: ${SERVERNAME}"
echo "# SERVERNAME LENGTH: ${#SERVERNAME}"

SYSTEM=${SERVERNAME:0:2}
SYS_IDX=`expr index "${SERVERNAME}" "$SYSTEM"`
SERVICE=${SERVERNAME:($SYS_IDX+1):3}
TYPE=${SERVERNAME:(-3):1}
SEQUENCE=${SERVERNAME:(-2):2}


echo "# SYSTEM: $SYSTEM"
echo "# SERVICE: $SERVICE" 
echo "# TYPE: $TYPE" 
echo "# SEQUENCE: $SEQUENCE" 
sleep 2;

done < hostlist

#for list in hostlist; do
#  echo "$list"
#done

