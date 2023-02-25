#!/bin/bash


echo $1
echo $2

for file in $(ls $1)
do 

    echo $file
    # new_file = cut -d'.' -f1
    head -n-4 $1/$file | tail -n +6 > $2/$file
done