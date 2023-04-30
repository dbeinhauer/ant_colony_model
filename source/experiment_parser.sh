#!/bin/bash

echo $1
echo $2

for file in $(ls $1)
do 
    head -n-4 $1/$file > $2/$file
    echo $file
done