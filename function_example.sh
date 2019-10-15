#!/bin/bash

usage(){
  echo "You need to provide an argument :"
  echo "usage : $0 file name"
}
is_file_exist() {
  local file="$1"
  [[ -f "$file"  ]] && return 0 || return 1
} 

[[ $# -eq 0 ]] && usage 

echo "local variable $file"
echo "this first args $1"

if ( is_file_exist "$1" )
then
  echo "file found $1"
else
  echo "file not found $1"
fi

