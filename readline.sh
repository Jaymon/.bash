#!/bin/bash
###############################################################################
# readline.sh
#
# configure readline using the inputrc file and the ~/.inputrc file if available
###############################################################################

# http://www.softpanorama.org/Scripting/Shellorama/inputrc.shtml
# http://unix.stackexchange.com/questions/27471/setting-readline-variables-in-the-shell

base_dot_bash_dir=$(dirname "${BASH_SOURCE[0]}")

# first we source our file
if [[ -f "$base_dot_bash_dir/inputrc" ]]; then
  # echo "binding $base_dot_bash_dir/inputrc"
  bind -f "$base_dot_bash_dir/inputrc"
fi

# then we source our custom user file
if [[ -f "$HOME/.inputrc" ]]; then
  # echo "binding $HOME/.inputrc"
  bind -f "$HOME/.inputrc"
fi


# only show directories when you tab after `cd`
# https://unix.stackexchange.com/questions/186422/
complete -d cd

