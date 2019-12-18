#!/bin/bash

# rd: roll dice
# takes in an input of dice in standard DnD format (2d6)
    # and returns numbers simulating a roll of those dice

# TODO
    # change echo to printf to align text better
    # add more functions to make program cleaner
   

function rd
(
    # prints the help message
    function rdhelpmessage()
    {
        printf "%s\n\n" "Example usage: rd 4d6 -r6 -b1 -B3"

        printf "%s\n"   "List of flags and meanings:"
        printf "%s\n"   "    -b  Bonus   Add (or subtract) a value from the roll's total value"
        printf "%s\n\n" "                Requires an integer as input"

        printf "%s\n"   "    -B  Best    Keep only the best X dice from the roll"
        printf "%s\n\n" "                Requires an integer greater than 0 and less than the total number of dice"

        printf "%s\n"   "    -h  Help    Displays this help message"

        printf "%s\n\n" "    -q  Quiet   Supresses the display of the Original, Best, and Worst labels"

        printf "%s\n"   "    -r  Rolls   How many sets of dice to roll"
        printf "%s\n\n" "                Requires an integer greater than 0"

        printf "%s\n"   "    -W  Worst   Keep only the worst # dice from the rolls"
        printf "%s\n\n" "                Requires an integer greater than 0 and less than the total number of dice"
    }

    # Check parameters
    if [ $# -lt 1 ]; then
        rdhelpmessage
        return 1
    fi 

    # retreive the dice info
    DICEINFO=$1

    # prints help information if requested
    if [[ $DICEINFO == "-h" ]] ||	# accept multiple help formats
       [[ "$(echo $DICEINFO | tr '[:upper:]' '[:lower:]')" == "h" ]] ||
       [[ "$(echo $DICEINFO | tr '[:upper:]' '[:lower:]')" == "help" ]]; then
       	rdhelpmessage
       	return 0;
    fi


    # check the input to ensure it is of proper format: [uint]d[unit]
    if ! [[ $DICEINFO =~ ^[1-9][0-9]*[d][1-9][0-9]*$ ]]; then
        echo "Incorrect dice format. Format should follow standard DnD notation: 2d6, 5d4, etc."
        return 2
    fi


    # save the original IFS
    OIFS=$IFS

    # read the info into an array
    IFS='d'
    read -ra INFO <<< "$DICEINFO"

    # restore the original IFS
    IFS=$OIFS

    # extraxt the dice info
    DQTY="${INFO[0]}"	# number of dice to roll
    SIDES="${INFO[1]}"	# number of sides per die

    # variables for options
    BONUS=0
    ROLLS=1
    NUMBEST=0
    NUMWORST=0
    QUIET=0

    # reset OPTIND (allows this to work multiple times per console session)
    OPTIND=1    

    # shift getopts arguments into the proper position
    shift   

    # parse the options and set values
    while getopts "b:B:hqr:W:" opt; do
        case "$opt" in
            b)  # Bonus to add total roll
                BONUS=$OPTARG
                if ! [[ $BONUS  =~ ^\-?[1-9][0-9]*$ ]]; then
                    echo "Invalid argument for flag b: $BONUS"
                    echo "Argument must be an integer"
                    return 1
                fi
                ;;

            B)  # display sum of best X dice
                NUMBEST=$OPTARG

                # check for positive integers
                if ! [[ $NUMBEST =~ ^[1-9][0-9]*$ ]]; then
                    echo "Invalid argument for flag B: $NUMBEST"
                    echo "Argument must be a positive integer greater than 0"
                    return 1
                fi

                # check for bounds
                if [[ $NUMBEST -gt $DQTY ]]; then
                    echo "Value for B may not exceed number of dice being rolled."
                    return 1
                fi
                ;;

            h)  # help message
                rdhelpmessage
                return 0
                ;;

            q)  # quiet (does not display total)
                QUIET=1
                ;;

            r)  # number of times to roll
                ROLLS=$OPTARG
                if ! [[ $OPTARG  =~ ^\-?[1-9][0-9]*$ ]]; then
                    echo "Invalid argument for flag r: $OPTARG"
                    return 1
                fi
                ;;

            W)  # display sum of worst X dice
                NUMWORST=$OPTARG

                # check for positive integers
                if ! [[ $NUMWORST =~ ^[1-9][0-9]*$ ]]; then
                    echo "Invalid argument for flag W: $NUMWORST"
                    echo "Argument must be a positive integer greater than 0"
                    return 1
                fi

                # check for bounds
                if [[ $NUMWORST -gt $DQTY ]]; then
                    echo "Value for W may not exceed number of dice being rolled."
                    return 1
                fi
                ;;

            ?)  # unknown flag
                echo "Unknown flag entered: "
                return 1
                ;;
        esac
    done


    # roll all dice $ROLLS amount of times
    for ((i=0;i<$ROLLS;i++)); do
        # create an array for the dice values
        ALLDICE=()
        TOTAL=0

	    # roll each die
	    for ((j=0;j<$DQTY;j++)); do
	        # roll the die
	        ROLL=$((1 + RANDOM % $SIDES))

	        # add the die to the array
	        ALLDICE+=($ROLL)

            # add the die value to TOTAL
            TOTAL=$((TOTAL+ROLL))
	    done

        # print the array
        for ((j=0;j<$DQTY;j++)); do echo -n "${ALLDICE[$j]} "; done


        # only show totals and bonuses if quiet was not used
        # print the grand total
        echo -n "= $TOTAL "

        # add the bonus (if being used) and label it (if not quiet)
        if [ $BONUS -ne 0 ]; then echo -n "+ $BONUS = $((TOTAL+BONUS))"; fi

        if [ $QUIET -eq 0 ]; then echo -ne "\t(Original)"; fi
        echo

        # create an array of the best X dice
        if [ $NUMBEST -ne 0 ]; then
            BESTDICE=("${ALLDICE[@]}")
            DIFF=$((DQTY-NUMBEST))

            for ((j=0;j<$DIFF;j++)); do
                # record the value an index of the worst die
                WORST=9223372036854775807   # int max for bash
                WORSTIND=0

                # find the worst die
                for ((k=0;k<${#BESTDICE[@]};k++)); do
                    if [ $((BESTDICE[$k])) -lt $WORST ] &&
                       [ $((BESTDICE[$k])) -ge 1 ];     then
                        WORSTIND=$k
                        WORST=$((BESTDICE[$k]))
                    fi
                done

                # remove the worst die
                BESTDICE[$WORSTIND]=0
            done

            # display the best dice
            BESTTOTAL=0
            for ((j=0;j<$DQTY;j++)); do
                echo -n "${BESTDICE[$j]} "
                BESTTOTAL=$((BESTTOTAL+BESTDICE[$j]))
            done

            # print the grand total
            echo -n "= $BESTTOTAL "

            # add the bonus (if being used) and label it (if not quiet)
            if [ $BONUS -ne 0 ]; then echo -n "+ $BONUS = $((BESTTOTAL+BONUS))"; fi
            if [ $QUIET -eq 0 ]; then echo -ne "\t(Best $NUMBEST)"; fi
            echo    # formatting
        fi  # best dice

        # create an array of the worst X dice
        if [ $NUMWORST -ne 0 ]; then
            WORSTDICE=("${ALLDICE[@]}")
            DIFF=$((DQTY-NUMWORST))

            for ((j=0;j<$DIFF;j++)); do
                # record the value an index of the best die
                BEST=0
                BESTIND=0

                # find the best die
                for ((k=0;k<${#WORSTDICE[@]};k++)); do
                    if [ $((WORSTDICE[$k])) -gt $BEST ]; then
                        BESTIND=$k
                        BEST=$((WORSTDICE[$k]))
                    fi
                done

                # remove the best die
                WORSTDICE[$BESTIND]=0
            done

            # display the worst dice
            WORSTTOTAL=0
            for ((j=0;j<$DQTY;j++)); do
                echo -n "${WORSTDICE[$j]} "
                WORSTTOTAL=$((WORSTTOTAL+WORSTDICE[$j]))
            done

            # print the grand total
            echo -n "= $WORSTTOTAL "

            # add the bonus (if being used) and label it (if not quiet)
            if [ $BONUS -ne 0 ]; then echo -n "+ $BONUS = $((WORSTTOTAL+BONUS))"; fi
            if [ $QUIET -eq 0 ]; then echo -ne "\t(Worst $NUMWORST)"; fi

            echo    # formatting
        fi  # worst dice

    echo    # formatting
	done

    # all the dice have been rolled
    return 0
)
