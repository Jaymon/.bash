#!/bin/bash
#
# (1) copy to: ~/bin/ssh-host-color 
# (2) set:     alias ssh=~/bin/ssh-host-color
#
# Inspired from http://talkfast.org/2011/01/10/ssh-host-color
# Fork from https://gist.github.com/773849
#
# https://gist.github.com/thomd/956095

set_term_bgcolor(){
  local R=$1
  local G=$2
  local B=$3
  /usr/bin/osascript <<EOF
tell application "iTerm"
  tell the current terminal
    tell the current session
      set background color to {$(($R*65535/255)), $(($G*65535/255)), $(($B*65535/255))}
    end tell
  end tell
end tell
EOF
}

#if [[ "$@" =~ thomd ]]; then
#  set_term_bgcolor 40 0 0
#elif [[ "$@" =~ git ]]; then
#  set_term_bgcolor 0 40 0
#fi
#
#ssh $@

#set_term_bgcolor 0 0 0
