#!/bin/bash
# -*- mode: sh -*-
# vi: set ft=sh :
###############################################################################
# BRIEF DESCRIPTION
#
# LONGER DESCRIPTION
###############################################################################

# to use this template as a base for a new bin script
# cp _template.sh NAME 

# there is an enote "Bash syntax" that has a lot of little code snippets that
# are useful for remembering how to do things in bash

# this will run if no arguments or --help|-h are passed in
if [[ $1 == "--help" ]] || [[ $1 == "-h" ]] || [[ "$#" -eq 0 ]]; then
    echo "usage: $(basename $0) ARGS GO HERE"
    echo "HELP DESCRIPTION"
    exit 0

fi


# this will go through all passed in arguments letting the script support flags
# (eg --NAME=VALUE, --NAME VALUE, -N VALUE). You specify the flags you want in
# the case statement and set them accordingly
args=("${@}")
total_args=$#
index=0
while [[ $index -lt $total_args ]]; do
    arg="${args[$index]}"
    argval=""
    # support --NAME=VALUE syntax
    if [[ $arg =~ ^-{1,2}[a-zA-Z0-9_-]+= ]]; then
        argval="${arg#*=}"
        arg="${arg%%=*}"

    fi

    case $arg in
        --name | -n)
            if [[ -n $argval ]]; then
                # use $argval to set the value of a variable to use later
                #...=$argval

            else
                # increment index and then set the value to a variable to use
                # later
                #index=$(($index + 1))
                #...="${args[$index]}"

            fi
            ;;

        *)
            # this is a positional argument not a keyword argument
            ;;

    esac

    index=$(($index + 1))

done


# this statement will run if no arguments are passed in
if [[ "$#" -eq 0 ]]; then

fi


# this statement will run if at least one argument is passed in
if [[ "$#" -gt 0 ]]; then
    echo $1

fi


# only run this if we are in MacOS
if uname | grep -q "Darwin"; then
    >&2 echo "$(basename $0) only available on MacOS"
    exit 1

fi

