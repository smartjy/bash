#!/bin/bash

HOME=$PWD
FILES=$(ls $HOME)

echo "$FILES"

cp -r $FILES $HOME/tmp
