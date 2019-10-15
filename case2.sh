#!/bin/bash

echo -e "Enger some character: \c"
read value

case $value in
  [a-z] )
    echo "$value [a to z]"  ;;
  [A-Z] )
    echo "$value [A to Z]" ;;
  [0-9] )
    echo "$value [0 to 9]" ;;
  ? )
    echo "$value [special character]" ;;
  * )
    echo "Unknown character" ;;
 
esac

 
