#!/bin/bash
###############################################################################
# third_party.sh
#
# a collection of functions that are written by other people
###############################################################################

##
# I've disabled this because it doesn't play nice with cd -P which I need in the all script
# I could fix this at some future time, but I'm not bothering right now since I don't use
# it all that often
##
# http://stackoverflow.com/a/69087/5006
# do ". acd_func.sh"
# acd_func 1.0.5, 10-nov-2004
# petar marinov, http:/geocities.com/h2428, this is public domain
function cd_func ()
{
  local x2 the_new_dir adir index
  local -i cnt

  if [[ $1 ==  "--" ]]; then
    dirs -v
    return 0
  fi

  the_new_dir=$1
  [[ -z $1 ]] && the_new_dir=$HOME

  if [[ ${the_new_dir:0:1} == '-' ]]; then
    #
    # Extract dir N from dirs
    index=${the_new_dir:1}
    [[ -z $index ]] && index=1
    adir=$(dirs +$index)
    [[ -z $adir ]] && return 1
    the_new_dir=$adir
  fi

  #
  # '~' has to be substituted by ${HOME}
  [[ ${the_new_dir:0:1} == '~' ]] && the_new_dir="${HOME}${the_new_dir:1}"

  #
  # Now change to the new dir and add to the top of the stack
  pushd "${the_new_dir}" > /dev/null
  [[ $? -ne 0 ]] && return 1
  the_new_dir=$(pwd)

  #
  # Trim down everything beyond 11th entry
  popd -n +11 2>/dev/null 1>/dev/null

  #
  # Remove any other occurence of this dir, skipping the top of the stack
  for ((cnt=1; cnt <= 10; cnt++)); do
    x2=$(dirs +${cnt} 2>/dev/null)
    [[ $? -ne 0 ]] && return 0
    [[ ${x2:0:1} == '~' ]] && x2="${HOME}${x2:1}"
    if [[ "${x2}" == "${the_new_dir}" ]]; then
      popd -n +$cnt 2>/dev/null 1>/dev/null
      cnt=cnt-1
    fi
  done

  return 0
}

# ? cd - -> go to the previous directory (similar to pop)
# ? cd -- -> list all dirs in history
# ? cd -N -> go to dir specified at N (N found via cd --)
#alias cd=cd_func

# http://www.linuxjournal.com/content/bash-regular-expressions
# http://tldp.org/LDP/Bash-Beginners-Guide/html/sect_04_01.html
# http://tldp.org/LDP/Bash-Beginners-Guide/html/sect_04_03.html
# man 7 regex to figure out how regex works in bash
#? regex <REGEX> <STR1> [...] -> compare strings against bash regexp
function regex() {
  if [[ $# -lt 2 ]]; then
      echo "Usage: $0 PATTERN STRINGS..."
      exit 1
  fi
  regex=$1
  shift
  echo "regex: $regex"
  echo

  while [[ $1 ]]
  do
      if [[ $1 =~ $regex ]]; then
          echo -e "\t\E[42;37m${1} - matches\E[33;0m"
          i=1
          n=${#BASH_REMATCH[*]}
          while [[ $i -lt $n ]]
          do
              echo -e "\t\t\E[43;37mcapture[$i]: ${BASH_REMATCH[$i]}\E[33;0m"
              let i++
          done
      else
          echo -e "\t\E[41;37m${1} - does not match\E[33;0m"
      fi
      shift
  done
}

#? sticker <delim> <vars...> -> joins <vars> by <delim>
# http://stackoverflow.com/a/12283900
function sticker() {
  delim=$1      # join delimiter
  shift
  oldIFS=$IFS   # save IFS, the field separator
  IFS=$delim
  result="$*"
  IFS=$oldIFS   # restore IFS
  echo $result
}


#? cleanhist -> cleans up the .bash_history file
# https://www.quora.com/What-are-some-time-saving-tips-that-every-Linux-user-should-know/answer/Chen-Bin-3
function cleanhist() {
  if [ -z "$1" ]; then
    echo "Usage: remove duplicated lines without sortdt"
    echo "  cleanfile ~/.bash_history"
  else
      local bkfile="$1.backup"
      # \+ does not work in OSX sed
      # delte short commands, delete git related commands
      sed 's/ *$//g;' $1 | sed '/^.\{1,4\}$/d' | sed '/^g[nlabcdusfp]\{1,5\} .*/d' | sed '/^git [nr] /d' | sed '/^rm /d' | sed '/^cgnb /d' | sed '/^touch /d' > $bkfile
      # @see Page on stack Overflow/questions/11532157/unix-removing-duplicate-lines-without-sorting
      cat $bkfile | awk ' !x[$0]++' > $1
      rm $bkfile
  fi
}

#? biggest -> Finding the biggest files in dir 
# https://www.quora.com/What-are-some-time-saving-tips-that-every-Linux-user-should-know/answer/Raghav-Yadav-2
alias biggest='ls -lSrh'

#? mostused -> lists the most used commands on the shell
# https://www.quora.com/What-are-some-time-saving-tips-that-every-Linux-user-should-know/answer/Abhiroop-Sarkar
alias mostused="history | awk '{a[$2]++}END{for(i in a){print a[i] \" \" i}}' | sort -rn | head"

