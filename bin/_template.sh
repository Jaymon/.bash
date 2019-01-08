#!/bin/bash
# -*- mode: sh -*-
# vi: set ft=sh :
###############################################################################
# BRIEF DESCRIPTION
#
# LONGER DESCRIPTION
###############################################################################

if [[ $1 == "--help" ]] || [[ $1 == "-h" ]]; then

    echo "usage: $(basename $0) ARGS GO HERE"
    echo "HELP DESCRIPTION"
    exit 0

fi


# to use this template as a base for a new bin script
# cp _template.sh NAME 

# there is an enote "Bash syntax" that has a lot of little code snippets that are
# useful for remembering how to do things in bash

# this statement will run if no arguments are passed in
if [ "$#" -eq 0 ]; then
fi

# this statement will run if at least one argument is passed in
if [ "$#" -gt 0 ]; then
    echo $1
fi
