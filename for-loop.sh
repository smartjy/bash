#!/bin/bash

#Declare a string array
topics=("a1.topic, a2.topic", "b.topics")
 
# Print array values in  lines
echo "Print every element in new line"
for val1 in ${topics[*]}; do
     echo $val1
done
 
echo ""
 
# Print array values in one line
echo "Print all elements in a single line"
for val2 in "${topics[*]}"; do
    echo $val2
done
echo ""