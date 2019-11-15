#!/bin/bash

# rd: roll dice
# takes in an input of dice in standard DnD format (2d6)
    # and returns numbers simulating a roll of those dice

# TODO
    # add plus notation for bonuses ((3d5+1) -> 2, 6, 4)

function rd
{
    # Check parameters
    if [ $# -lt 1 ]
    then
        echo "Please provide dice information"
        return 1
    fi 

    if [ $# -gt 1 ]
    then
        echo "Too many inputs"
        return 1
    fi 


    # retrieve the dice information
    DICEINFO=$1


    # check the input to ensure it is of proper format: [uint]d[unit]
    if ! [[ $DICEINFO =~ ^[1-9][0-9]*[d][1-9][0-9]*$ ]]
    then
        echo "Incorrect dice format. Format should follow standard DnD notation: 2d6, 5d4, etc"
        return 2
    fi


    # parse the information

    # save the original IFS
    OIFS=$IFS
    IFS='d'
    read -ra INFO <<< "$DICEINFO"

    DQTY="${INFO[0]}"
    SIDES="${INFO[1]}"


    # roll for each die
    for ((i=1;i<=$DQTY;i++))
    do
        # roll the die
        ROLL=$((1 + RANDOM % $SIDES))

        # print to console (-n prevents printing newline)
        echo -n "$ROLL "
    done; echo

    # restore the original IFS
    IFS=$OIFS

    return 0
}
