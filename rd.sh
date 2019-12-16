#!/bin/bash

# rd: roll dice
# takes in an input of dice in standard DnD format (2d6)
    # and returns numbers simulating a roll of those dice

# TODO
    # add plus notation for bonuses ((3d5+1) -> 2, 6, 4)

function rd
{
    # Check parameters
    if [ $# -lt 1 ]; then
        echo "Please provide dice information."
        return 1
    fi 

    if [ $# -gt 2 ]; then
        echo "Too many inputs."
        return 1
    fi 


    # retrieve the dice information
    DICEINFO=$1


    # print help information
    if [[ $DICEINFO == "-h" ]] ||	# accept multiple help formats
       [[ "$(echo $DICEINFO | tr '[:upper:]' '[:lower:]')" == "h" ]] ||
       [[ "$(echo $DICEINFO | tr '[:upper:]' '[:lower:]')" == "help" ]]; then
       	echo "Format for one set of dice: rd 4d6"
       	echo "Format for multiple sets of dice: rd 4d6 6"
       	return 0;
    fi


    # check the input to ensure it is of proper format: [uint]d[unit]
    if ! [[ $DICEINFO =~ ^[1-9][0-9]*[d][1-9][0-9]*$ ]]; then
        echo "Incorrect dice format. Format should follow standard DnD notation: 2d6, 5d4, etc."
        return 2
    fi


    # parse the information

    # save the original IFS
    OIFS=$IFS
    IFS='d'
    read -ra INFO <<< "$DICEINFO"

    ROLLS=0				# number of times the dice are rolled
    DQTY="${INFO[0]}"	# number of dice to roll
    SIDES="${INFO[1]}"	# number of sides per die

    # if only one input, roll dice once
    if [ $# -lt 1 ]; then
        ROLLS=1
    elif [ $# -eq 2 ]; then
    	# check the format of $2
    	if ! [[ $2 =~ ^[1-9][0-9]*$ ]]; then
    		echo "Incorrect amount of dice rolls"
    		return 3
    	fi

    	# if the format is correct, set ROLLS to $2
    	ROLLS=$2
    fi

    # roll all dice $ROLLS amount of times
    for ((i=1;i<=$ROLLS;i++)); do
	    # roll each die
	    for ((j=1;j<=$DQTY;j++)); do
	        # roll the die
	        ROLL=$((1 + RANDOM % $SIDES))

	        # print to console (-n prevents printing newline)
	        echo -n "$ROLL "
	    done; echo
	done;

    # restore the original IFS
    IFS=$OIFS

    return 0
}
