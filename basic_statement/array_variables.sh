#!/bin/bash

os=('ubuntu' 'windows' 'centos')
os[3]='mac' #os=('ubuntu' 'windows' 'centos' 'mac')

#unset os[0] # be excluded

echo "${os[@]}"
echo "${#os[@]}"
echo "${!os[@]}"

echo "${os[0]}"
echo "${os[1]}"
echo "${os[2]}"

