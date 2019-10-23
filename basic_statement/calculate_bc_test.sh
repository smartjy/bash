#!/bin/bash

read num1 num2 num3
#num1=20.5
#num2=10

echo "$num1 + $num2" | bc
echo "$num1 - $num2" | bc
echo "$num1 * $num2" | bc
echo "scale = 10; $num1 / $num2" | bc
echo "$num1 % $num2" | bc 

echo "scale=2; sqrt($num3)" | bc -l
echo "scale=2; $num3 ^ $num3 "| bc -l

