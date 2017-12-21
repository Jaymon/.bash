#!/bin/bash
###############################################################################
# colors.sh
#
# holds color variables and color related things, lots of the other files depend on these colors
# being defined in order to show colored output
###############################################################################

# colors
# use them in echo like this: echo -e "${RED}test${NONE}"
# in Mac, you can't use these, you have to put in the full \e...
YELLOW='\033[0;33m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
RED='\033[0;31m'
LIGHTRED="\033[1;31m"
GREEN="\033[0;32m"
BLACK='\033[0;30m'
BLUE='\033[0;34m'
NONE='\033[0m' # Text Reset
LIGHTGRAY="\033[37m"

# via: http://apple.stackexchange.com/questions/9821/can-i-make-my-mac-os-x-terminal-color-items-according-to-syntax-like-the-ubuntu
C_DEFAULT="\[\033[m\]"
C_WHITE="\[\033[1m\]"
C_BLACK="\[\033[30m\]"
C_RED="\[\033[31m\]"
C_GREEN="\[\033[32m\]"
C_YELLOW="\[\033[33m\]"
C_BLUE="\[\033[34m\]"
C_PURPLE="\[\033[35m\]"
C_CYAN="\[\033[36m\]"
C_LIGHTGRAY="\[\033[37m\]"
C_DARKGRAY="\[\033[1;30m\]"
C_LIGHTRED="\[\033[1;31m\]"
C_LIGHTGREEN="\[\033[1;32m\]"
C_LIGHTYELLOW="\[\033[1;33m\]"
C_LIGHTBLUE="\[\033[1;34m\]"
C_LIGHTPURPLE="\[\033[1;35m\]"
C_LIGHTCYAN="\[\033[1;36m\]"
C_BG_BLACK="\[\033[40m\]"
C_BG_RED="\[\033[41m\]"
C_BG_GREEN="\[\033[42m\]"
C_BG_YELLOW="\[\033[43m\]"
C_BG_BLUE="\[\033[44m\]"
C_BG_PURPLE="\[\033[45m\]"
C_BG_CYAN="\[\033[46m\]"
C_BG_LIGHTGRAY="\[\033[47m\]"


#   This file echoes a bunch of color codes to the 
#   terminal to demonstrate what's available.  Each 
#   line is the color code of one forground color,
#   out of 17 (default + 16 escapes), followed by a 
#   test use of that color on all nine background 
#   colors (default + 8 escapes).
#   via: http://tldp.org/HOWTO/Bash-Prompt-HOWTO/x329.html
#? colors -> print available colors
function colors(){

  T='gYw'   # The test text

  echo -e "\n                 40m     41m     42m     43m\
       44m     45m     46m     47m";

  for FGs in '    m' '   1m' '  30m' '1;30m' '  31m' '1;31m' '  32m' \
             '1;32m' '  33m' '1;33m' '  34m' '1;34m' '  35m' '1;35m' \
             '  36m' '1;36m' '  37m' '1;37m';
    do FG=${FGs// /}
    echo -en " $FGs \033[$FG  $T  "
    for BG in 40m 41m 42m 43m 44m 45m 46m 47m;
      do echo -en "$EINS \033[$FG\033[$BG  $T  \033[0m";
    done
    echo;
  done
  echo
}


#? bgcolor R G B -> set the bg color of the terminal, each color value from 1-255
# currently works only with iTerm2
# from https://gist.github.com/thomd/956095
# howto for linux: http://askubuntu.com/questions/558280/changing-colour-of-text-and-background-of-terminal
bgcolor () {
  local R=$1
  local G=$2
  local B=$3

  # http://apple.stackexchange.com/questions/118464
  if [[ $TERM_PROGRAM == "iTerm.app" ]]; then

    if [[ $TERM_PROGRAM_VERSION == 3* ]]; then

      # iTerm >= 3
      # found new syntax here: http://stackoverflow.com/a/28512260/5006
      /usr/bin/osascript <<EOF
tell application "iTerm"
  tell current session of current window
    set background color to {$(($R*65535/255)), $(($G*65535/255)), $(($B*65535/255))}
  end tell
end tell
EOF

    else

      # iTerm2 < 3
      /usr/bin/osascript <<EOF
tell application "iTerm"
  tell the current terminal
    tell the current session
      set background color to {$(($R*65535/255)), $(($G*65535/255)), $(($B*65535/255))}
    end tell
  end tell
end tell
EOF

    fi

  fi
}

# if we haven't specified a default bgcolor then go ahead and use my default
# TODO -- probably make this pull the default from iterm, but this will work for
# right now and I don't care enough to make it more portable
if [[ -z $BGCOLOR_DEFAULT ]]; then
  export BGCOLOR_DEFAULT="255 255 255"
fi

# this is run everytime a command is run, it will look for a .bgcolor file in the
# directory (and every parent directory) and when it finds it it will set the current
# shell's background color to the R G B color specified in the file
# you can activate this by doing: export PROMPT_COMMAND="$PROMPT_COMMAND;bgcolor_auto"
# in your bash_profile file or whatnot
function bgcolor_auto () {
  # if I ever want to try and only run this when moving directories
  # http://stackoverflow.com/questions/6109225/bash-echoing-the-last-command-run
  if [[ $PWD != $PWD_PREV ]]; then
    # NOTE: We can't use $OLDPWD for this because that is always different than $PWD
    found=0
    #path=$(pwd)
    path=$PWD
    while [[ $path != "/" ]]; do
      color_file="$path/.bgcolor"
      if [[ -e $color_file ]]; then
        bgcolor $(cat $color_file)
        found=1
        break
      fi
      path=$(dirname "$path")
    done

    if [[ found -eq 0 ]]; then
      bgcolor $BGCOLOR_DEFAULT
    fi

    export PWD_PREV=$PWD

  fi

#  curdir=$(pwd)
#  color_file="$curdir/.bgcolor"
#  if [[ -e $color_file ]]; then
#    echo "here"
#    bgcolor $(cat $color_file)
#  fi
}

