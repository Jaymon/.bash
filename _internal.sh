
# this is a helper function to allow easy testing of an int
# if you want to use this in an if: [ $(is_int <VALUE>; echo $?) -eq 0 ]
# or the simpler: [ $(is_int <value>) -eq 0 ]
# return 0 if input is an int, not zero otherwise
function is_int(){

  #set -x
  # canary, only one value is allowed
  if [ $# -gt 1 ]; then
    echo "1"
    return 1;
  fi

  # this will set the $? as either 0 or 1
  echo "$1" | grep -E "^[[:digit:]]+$" > /dev/null 2>&1
  retcode=$?
  echo $retcode
  #set +x
  return $retcode

}


# prompt [ONE[, TWO, ...]] -> prompt to choose one of those results, this will set
# userprompt_chosen after finishing executing
function userprompt() {

#  echo $@
#  for d in "${@}"; do
#    echo "$d"
#  done

  userprompt_chosen=""

  if [[ $# -eq 1 ]]; then

    userprompt_chosen=$@

  else

    # split the string into an array
    IFS=$'\n'; ds=( $@ ); unset IFS

    # print out all the found files to the user and let them choose which one to open
    # http://stackoverflow.com/a/10586169
    for index in "${!ds[@]}"; do
      i=$(expr $index + 1)
      echo -e "[$i]\t${ds[index]}"
    done

    echo -e "[n]\tNone"

    # http://stackoverflow.com/questions/226703/how-do-i-prompt-for-input-in-a-linux-shell-script
    read -p "Choice? " fns
    if [[ ! $fns =~ [nN] ]]; then
      for fn in ${fns[@]}; do
        i=$(expr $fn - 1)
        userprompt_chosen+="${ds[i]}\n"
      done
    fi

    # strip whitespace off the end of the string
    # http://stackoverflow.com/a/23332475/5006
    userprompt_chosen=$(echo -e $userprompt_chosen)
    if [[ "$userprompt_chosen" =~ ^(.*)[[:space:]]$ ]]; then 
      userprompt_chosen=${BASH_REMATCH[1]}
    fi

  fi

  #export userprompt_chosen

}


# build a prefix search path from an easier path, so fo/ba would become fo*/ba*$
function convert_to_prefix_search_path() {
  # let's build a prefix search string that find can use

  # eg, p/d/file -> p* / d* / file
  # ds would become [p*, d*], f would become file
  #directories="^.*"
  directories=".*"
  IFS=$'/'; ds=( $1 ); unset IFS
  dlast=${ds[-1]}
  ds=( ${ds[@]:0:${#ds[@]}-1} )
  for d in ${ds[@]}; do
    directories+="${d}[^/]*/"
  done
  directories+="${dlast}[^/]*"
  echo $directories
}

  