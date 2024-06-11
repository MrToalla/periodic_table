#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

ELEMENT_F() {
    # I check if the input is the atomic number, the symbol or the name
    if [[ $ELEMENT =~ ^([1-9]|10|1000)$ ]]
    then
        ATOMIC_NUMBER=$ELEMENT
        NAME=$($PSQL "SELECT name FROM elements WHERE atomic_number = $ATOMIC_NUMBER")
        SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE atomic_number = $ATOMIC_NUMBER")
    elif [[ $ELEMENT =~ ^[A-Z][a-z]?$ ]]
    then
        SYMBOL=$ELEMENT
        ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol = '$SYMBOL'")
        NAME=$($PSQL "SELECT name FROM elements WHERE symbol = '$SYMBOL'")
    elif [[ $ELEMENT =~ ^[A-Z][a-z]+$ ]]
    then
        NAME=$ELEMENT
        ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name = '$NAME'")
        SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE name = '$NAME'")
    fi
    if [[ -z $ATOMIC_NUMBER || -z $NAME || -z $SYMBOL ]]
    then
        echo "I could not find that element in the database."
    else
        TYPE_ID=$($PSQL "SELECT type_id FROM properties WHERE atomic_number = $ATOMIC_NUMBER")
        ATOMIC_MASS=$($PSQL "SELECT atomic_mass FROM properties WHERE atomic_number = $ATOMIC_NUMBER")
        MELTING_POINT=$($PSQL "SELECT melting_point_celsius FROM properties WHERE atomic_number = $ATOMIC_NUMBER")
        BOILING_POINT=$($PSQL "SELECT boiling_point_celsius FROM properties WHERE atomic_number = $ATOMIC_NUMBER")
        case $TYPE_ID in
        1) TYPE='nonmetal' ;;
        2) TYPE='metal' ;;
        3) TYPE='metalloid' ;;
        esac
        echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
    fi
}

if [[ $# -eq 0 ]]
then
    echo "Please provide an element as an argument."
elif [[ $# -eq 1 ]]
then
    ELEMENT=$1
    ELEMENT_F
else
    echo "Too many arguments."
fi
