#!/usr/bin/env bash
# -*- mode: sh -*-
# vi: set ft=sh :

# to use this template as a base for a new bin script
# cp _template.sh <NAME>


usage () {
    echo "usage: $(basename $0) ARGS GO HERE"
    echo "HELP DESCRIPTION"

}


# print usage if no arguments are passed in
if [[ "$#" -eq 0 ]]; then
    usage
    exit 0

fi

# print usage if requested
if [[ $1 == "--help" ]] || [[ $1 == "-h" ]]; then
    usage
    exit 0

fi


# Flag/input parsing
args=("${@}")
index=0
while [[ $index -lt $# ]]; do
    arg="${args[$index]}"
    index=$(($index + 1))

    # ;; is stop, ;& is fallthrough to next rule
    case $arg in
        --name | -n)
            # --NAME VALUE syntax, use the $args[$index] value to set the
            # variable:
            #   <VARNAME>="${args[$index]}" # consume value
            #   index=$(($index + 1)) # move passed consumed value

            # --NAME boolean flag with no value, so set variable to true
            # value:
            #   <VARNAME>=1
            ;;

        --name=*)
            # --NAME=VALUE syntax, use the `$argval` value to set the
            # variable:
            #   <VARNAME>=$argval
            argname="${arg%%=*}"
            argval="${arg#*=}"

            # if you want to combine --name | --name=*
            regex="^-{1,2}[a-zA-Z0-9_-]+="
            if [[ $arg =~ $regex ]]; then
                # <VARNAME>=""${arg#*=}""

            else
                # <VARNAME>="${args[$index]}"

            fi
            ;;

        --help | -h)
            usage
            exit 0
            ;;

        *)
            # Catch-all to handle positional arguments

            # this is a positional argument not a keyword argument so do
            # something with $arg
            # <VARNAME>=$arg
            ;;

    esac

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

# print out all passed in arguments
#echo "${args[@]}"
echo "$@"

# run a string command
# bash -c "$cmd"

