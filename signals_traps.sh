#!/bin/bash


trap "rm -f $somefile; exit" 0 2 15
#trap  "echo process id interrupt " SIGINT
#trap  "echo Exit command is detected " 0

echo "pid is $$"
while (( COUNT < 10 ))
do
  sleep 10
  (( COUNT ++ ))
  echo $COUNT
done
exit 0

