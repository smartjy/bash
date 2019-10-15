#!/bin/bash

for VARIABLE in 1 2 3 4 5 .. N
do
  command1
  command2
  command3
done

for VARIABLE in file1 file2 file3
do
  command1 on $VARIABLE
  command2
  commandN
done

for OUTPUT in $(Linux-Or-Unix-Command-Here)
do
  command1 on $OUTPUT
  command2 on $OUTPUT
  commandN
done

for (( EXP1; EXP2; EXP3 ))
do
  command1
  command2
  command3
done


