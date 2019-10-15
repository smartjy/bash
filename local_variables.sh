#!/bin/bash

function print(){
  local name=$1
  echo "the name is $name : function inside"
}

name="Jay"

echo "The name is $name : Before"

print "SON"

echo "The name is $name : After"
