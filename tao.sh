#!/bin/bash

# tao: touch and open
# creates a file and opens it in one command
# sample use: tao file.ext

function tao()
{
    # check for correct input
    if [ $# -gt 1 ]
    then
        echo "Too many file names entered, please enter just one"
        return 1
    fi

    if [ $# -lt 1 ]
    then
        echo "Please enter a file name"
        return 1
    fi


    # bind the input to a variable name
    FILE=$1


    # check for illegal characters (/)
    if [[ $FILE == *"/"* ]]
    then
        echo "File name contains illegal character: /"
        return 2
    fi


    # check if the name contains an extension
    # check if it contains "." at least once
    COUNT=0
    COUNT=$(echo "$1" | fgrep -o "." | uniq -c | tr -s "  " | cut -d ' ' -f2)

    if [[ $COUNT == "" ]]
    then
        echo "File must contain an extension"
        return 3
    fi

    # uncomment this block to allow only one "."
    # if [ $COUNT -gt 1 ]
    # then
    #     echo "Invalid extension format"
    #     return 3
    # fi


    # check if a file with the same name exists
    if [ -f "$FILE" ]
    then
        echo "$FILE already exists"
        return 2
    fi


    # create the file
    touch $FILE

    # open the file
    xdg-open $FILE
}
