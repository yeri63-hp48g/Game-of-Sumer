#!/bin/ksh

# Program: sumer.sh
# Version: 1.00
#    Date: 17-May-2023
#  Author: gerry.walterscheid@gmail.com
 
# Description:
#
# Sumer civilization game from DEC PDP-8 FOCAL code.

# ------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
 
# Initialize global variables.
 
p=95            # Population
s=2800          # Stored Bushels
h=3000		# Harvested Bushels
e=200           # Bushels Eaten by rats.
y=3		# Yield; Trading Rate in Bushels per Acre.
a=1000		# Acres of land.
i=5		# Immigrants to the city.
q=1		# User queried input.
d=0		# Deaths from starvation; Acres to plant.
c=0             # Hamurabi's patience counter.

# ------- --------- --------- --------- --------- --------- --------- --------- --------- ---------

# Functions to reduce length of program.

inform () { # Address the ruler of Sumer.

    echo
    echo
    echo "Hamurabi:"
    echo
}

invalid () { # Unable to comply with request. Explain why.

    # Did Hamurabi run out of patience?
    if [ $c -lt 0 ]; then
        echo
        echo "Hamurabi has gone on strike! You will have to stop"
        echo "and find yourself another steward!"
        echo
        echo "Goodbye!"
        echo

        exit
    else
        (( c = c - 1 ))                         # Hamurabi is losing patience.        
    fi

    inform                                      # Address ruler of Sumer.

    echo -n "Please think again. You have only "

    case $1 in
        "acres" )
        echo "$a acres."
        ;;

        "bushels" )
        echo "$s bushels in store."
        ;;

        "people" )
        echo "$p people."
        ;;
    esac
}

# ------- --------- --------- --------- --------- --------- --------- --------- --------- ---------

# Program starts here.

while true; do
    inform                                      # Address ruler of Sumer.

    echo "I beg to report that last year $d died of starvation,"
    echo "$i people came into the city,"

    (( p = p + i ))                             # People = People + Immigrants

    # No bushels of grain were distributed as food?
    if [ $q -le 0 ]; then
        echo "half the people died from a plague epidemic," 
        (( p = p / 2 ))
    fi

    echo "and the population is now $p."
    echo
    echo "The city now owns $a acres of land."
    echo

    # Was there a harvest last year?
    if [ $h -gt 0 ]; then
        echo "We harvested $y bushels per acre; the harvest was $h bushels."
    fi

    echo "$e bushels of grain were destroyed by rats and you now have"
    echo "$s bushels in store."

    inform                                      # Address ruler of Sumer.

    (( y = RANDOM % 5 + 18 ))                   # This year's trading rate.

    echo "This year, land may be traded for $y bushels per acre."
    (( c = 0 ))                                 # Reset patience counter.

    while true; do
        echo -n "How many acres do you wish to buy? " 
        read q

        # Do you want to buy any?
        if [ $q -gt 0 ]; then

            # Is the Trading Rate x Qty less than Stored Bushels?
            if [ $(( y * q )) -le $s ]; then
                (( a = a + q ))                 # Acres = Acres + Qty Purchased
                (( s = s - y * q ))             # Store = Store - Rate x Qty
                (( c = 0 ))                     # Reset patience counter.

                # Did you run out of Stored Bushels?
                if [ $s -eq 0 ]; then
                    echo "You now have no grain left in store, so you have none left to use as seed this year."
                    (( d = 0 ))                 # Deaths = 0
                fi

                break 1         
            fi

            invalid bushels

        else
            echo -n "To sell? " 
            read q

            # Is the Qty less than the Acres you own?
            if [ $q -le $a ]; then
                (( a = a - q ))                 # Acres = Acres - Qty Sold
                (( s = s + y * q ))             # Store = Store + Rate x Qty
                (( c = 0 ))                     # Reset patience counter.

                # Did you sell all your Acres of land?
                if [ $a -eq 0 ]; then
                    echo "You now have no acres left to plant this year."
                    (( d = 0 ))                 # Deaths = 0
                fi

                break 1
            fi

            invalid acres
        fi
    done

    echo

    # Skip if there is no grain in store.
    while [ $s ]; do
        echo -n "How many bushels of grain do you wish to distribute as food? " 
        read q

        # Is there enough bushels in the store house?
        if [ $q -le $s ]; then
            (( s = s - q ))                     # Store = Store - Qty as Food
            (( c = 1 ))                         # Reset patience counter.

            # Is the store house empty?
            if [ $s -eq 0 ]; then
                echo "You now have no grain left in store, so you have none left to use as seed this year."
                (( d = 0 ))                     # Deaths = 0
            fi

            break 1
        fi
 
        invalid bushels
    done

    # Skip if you're out of grain or acres to plant on.
    while [ $(( a && s )) ]; do
        echo -n "How many acres of land do you wish to plant with seed? " 
        read d

        # Do you want to plant more acres than you own?
        if [ $d -gt $a ]; then
            invalid acres
            continue
        fi
   
        # Are there enough bushels in store to plant these acres?
        if [ $(( d/2 )) -gt $s ]; then
            invalid bushels
            continue
        fi

        # Do you have enough people to plant these acres? 
        if [ $d -lt $(( 10*p )) ]; then
            break 1
        fi

        invalid people
   done         

   (( s = s - d/2 ))                            # Stored Grain = Stored - Planted
   (( c = RANDOM % 5 + 1 ))                     # Generate random number.
   (( y = c ))                                  # Update Bushel Yield and Trading Rate.
   (( h = d * y ))                              # Harvested = Planted x Trading Rate
   (( c = RANDOM % 5 + 1 ))                     # Generate random number.
 
   # Roll 5 sided dice and check for even number to determine number of Bushels destroyed.
   if [ $(( c/2.0 - c/2 )) -eq 0 ]; then 
       (( e = s/c ))                            # Bushels destroyed = Stored Grain / Random Number
   else
       (( e = 0 ))                              # Eaten by Rats = 0
   fi

   (( s = s - e + h ))                          # Stored Grain = Stored - Eaten + Harvested

   (( c = RANDOM % 5 + 1 ))                     # Generate random number.
   (( i = c*(20*a + s)/p/100 + 1 ))             # Update Immigrants.
   (( c = q/20 ))                               # Chance = Query / 20
   (( q = RANDOM % 10 ))                        # 1 in 10 chance of Plague.

   # Is Acres Planted is less than Random Number?   
   if [ $p -lt $c ]; then
       (( d = 0 ))                              # Deaths = 0
   else
       (( d = p - c ))                          # Deaths = Population - Random Number
   fi

   (( p = c ))                                  # Population = Random Number
done

