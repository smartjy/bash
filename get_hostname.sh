#https://www.snoopybox.co.kr/1811
#!/bin/bash

HOST=$(hostname)

A=${HOST: -2}
B=${HOST:1:2}

echo $A
echo $B

#echo "${PWD##*/}"
