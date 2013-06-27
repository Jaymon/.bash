#!/bin/bash

# this function will be called everytime a bash terminal exits
# http://stackoverflow.com/questions/2129923/bash-run-command-before-a-script-exits
# http://stackoverflow.com/questions/5033354/run-script-before-bash-exits
function epwd_append {
  # move the current pwd to the bottom of the file and limit file to N lines
  f=~/.epwd_history
  n=50
  #tail -n $n "$f" | grep -v "$PWD" >> "$f"
  t=$(tail -n $n "$f" | grep -v "^$PWD$")
  if [[ -z $t ]]; then
    printf "$PWD\n" >> "$f"
  else
    printf "$t\n$PWD\n" > "$f"
  fi
}
trap epwd_append EXIT

#? epwd <NUM_LINES> -> print the last NUM_LINES exit working directories
function epwd() {
  f=~/.epwd_history
  if [[ $# -eq 0 ]]; then
    f=$(cat "$f")
  else
    f=$(tail -n $1 "$f")
  fi

  # split the string into an array
  IFS=$'\n'
  fs=( $f )
  unset IFS

  for index in "${!fs[@]}"; do
    i=$(expr $index + 1)
    echo -e "[$i]\t${fs[index]}"
  done
  echo -e "[n]\tNone"
  read -p "cd? " fn
  if [[ ! $fn =~ [nN] ]]; then
    file_index=$(expr $fn - 1)
    pushd "${fs[file_index]}"
  fi
  
}
