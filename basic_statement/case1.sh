#!/bin/bash

PTN=$1 #PATTERN

case $PTN in
  "bash" )
    echo "$PTN is my favolite language = bash"  ;;
  "java" )
    echo "$PTN is my favolite language = java" ;;
  "python" )
    echo "$PTN is my favolite language = python" ;;
  * )
    echo "Unknown favolit language" ;;
 
esac

 
