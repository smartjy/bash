#!/bin/bash

JAVAC=`which javac`
#echo "JAVAC PATH = $JAVAC"

READLINK=`readlink -f $JAVAC`
#echo "READLINK PATH = $READLINK"

DIR_NAME1=`dirname $READLINK`
#echo "DIR_NAME1 PATH = $DIR_NAME1"

DIR_NAME2=`dirname $DIR_NAME1`
#echo "DIR_NAME2 PATH = $DIR_NAME2"

JAVA_HOME=$DIR_NAME2
echo "JAVA_HOME PATH = $JAVA_HOME"
