#!/bin/bash
# -*- mode: sh -*-
# vi: set ft=sh :
###############################################################################
# BRIEF DESCRIPTION
#
# LONGER DESCRIPTION
###############################################################################

# to use this template as a base for a new bin script
# cp _template.sh <NAME>


# this will run if no arguments or --help|-h are passed in
if [[ $1 == "--help" ]] || [[ $1 == "-h" ]] || [[ "$#" -eq 0 ]]; then
    echo "usage: $(basename $0) ARGS GO HERE"
    echo "HELP DESCRIPTION"
    exit 0

fi


# Flag/input parsing
# this will go through all passed in keyword arguments letting the script
# support flags (eg --NAME=VALUE, --NAME VALUE, -N VALUE). You specify the
# flags you want in the case statement and set them accordingly.
# The `*` catch-all handles positional arguments
args=("${@}")
total_args=$#
index=0
while [[ $index -lt $total_args ]]; do
    argval="${args[$index]}"
    argname=$argval

    # support --NAME=VALUE syntax
    if [[ $argval =~ ^-{1,2}[a-zA-Z0-9_-]+= ]]; then
        argname="${argval%%=*}"
        argval="${argval#*=}"

    fi

    case $argval in
        --name | -n)
            if [[ -n $argval ]]; then
                # You can use $argval to set the value of a variable to use
                # later:
                # <VARNAME>=$argval

            else
                # This supports --NAME VALUE syntax, increment index and then
                # use the $args[$index] value to set the variable:
                # index=$(($index + 1))
                # <VARNAME>="${args[$index]}"

                # or, this could be a boolean --NAME flag with no value, so
                # set variable to true value
                # <VARNAME>=1

                # Remove this whole block if unneeded

            fi
            ;;

        *)
            # this is a positional argument not a keyword argument so do
            # something with $argval
            # <VARNAME>=$argval
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


# only run in MacOS
if uname | grep -q "Darwin"; then
    >&2 echo "$(basename $0) only available on MacOS"
    exit 1

fi

