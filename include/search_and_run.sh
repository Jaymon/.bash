
#? dar DIR SEARCH CMD [CMD-PARAMS] -> find sub path n DIR and run CMD [CMD-PARAMS] found-path
function dar() {

  source $DOTBASH_INCLUDE_DIR/userprompt.sh
  source $DOTBASH_INCLUDE_DIR/convert_to_prefix_search_path.sh

  if [[ $# -eq 0 ]]; then
    >&2 echo "dar - find subdirectories using SEARCH in DIR and run CMD"
    >&2 echo "usage: dar DIR SEARCH CMD [CMD-PARAMS]"
    return 1
  fi

  # let's build a prefix search string that find can use
  echo "getting directories..."
  directories=$(convert_to_prefix_search_path $2)
  echo "searching $1 for $directories"

  #set -x

  # http://unix.stackexchange.com/questions/24557/how-do-i-stop-a-find-from-descending-into-found-directories
  if git -C . rev-parse  > /dev/null 2>&1; then
    # since we are in a git directory, run the found paths through gitignore
    ds=$(find "$1" -not -path "*/\.*" -type d -iregex "$directories" -prune | git check-ignore -vn --stdin | grep "^::" | cut -d$'\t' -f2)
  else
    ds=$(find "$1" -not -path "*/\.*" -type d -iregex "$directories" -prune)
  fi

  # set +x

  echo "prompting..."
  IFS=$'\n'; ds=( $ds ); unset IFS
  userprompt "${ds[@]}"
  #echo -e $userprompt_chosen
  #IFS=$'\n'; ds=( $(echo -e $prompt_choices) ); unset IFS
  echo "preparing chosen..."
  c=""
  IFS=$'\n'; ds=( $userprompt_chosen ); unset IFS
  for d in ${ds[@]}; do
    if [[ -n "$c" ]]; then
      c="$c;""${@:3} ${d}"
    else
      c="${@:3} ${d}"
    fi
  done
  #echo $ds

  if [[ -n "$c" ]]; then
    echo "running $3 with chosen directories..."
    echo $c
    eval $c
  fi

}


#? far DIR SEARCH CMD [PARAMS] -> run CMD [PARAMS] in DIR by prompting for what FILE if more than one FILE found in DIR/SEARCH
# find and run, ie, find FILE and run PROG [PARAMS] FILE
function far() {

  #set -x
  source $DOTBASH_INCLUDE_DIR/userprompt.sh
  source $DOTBASH_INCLUDE_DIR/convert_to_prefix_search_path.sh

  if [[ $# -eq 0 ]]; then
    >&2 echo "far - find subfiles using SEARCH in DIR and run CMD"
    >&2 echo "usage: far DIR SEARCH CMD [CMD-PARAMS]"
    return 1
  fi

  c=""
  if [[ -f $2 ]]; then

    # turns out there was a full path so don't even bother searching DIR

    c="${@:3} \"$2\""

  elif [[ -f $1/$2 ]]; then

    # so DIR/SEARCH is actually just a file path, so use that, no searching needed

    # http://stackoverflow.com/questions/2701400/remove-first-element-from-in-bash
    c="${@:3} \"$1/$2\""

  else

    files=$(convert_to_prefix_search_path $2)
    #fs=$(find "$1" -not -path "*/\.*" -type f -iregex "$files" -prune | grep -ive "pyc$")
    if git -C . rev-parse  > /dev/null 2>&1; then
      # since we are in a git directory, run the found paths through gitignore
      fs=$(find "$1" -not -path "*/\.*" -type f -iregex "$files" -prune | git check-ignore -vn --stdin | grep "^::" | cut -d$'\t' -f2)
    else
      fs=$(find "$1" -not -path "*/\.*" -type f -iregex "$files" -prune | grep -ive "pyc$")
    fi

    if [[ -z $fs ]]; then
      echo "No valid file matches for \"$2\" found"
      return 1
    fi

    IFS=$'\n'; fs=( $fs ); unset IFS
    userprompt "${fs[@]}"
    IFS=$'\n'; fs=( $userprompt_chosen ); unset IFS
    for f in ${fs[@]}; do
      if [[ -n "$c" ]]; then
        c="$c;""${@:3} ${f}"
      else
        c="${@:3} ${f}"
      fi
    done

  fi

  if [[ -n "$c" ]]; then
    echo $c
    eval $c

  fi
  #set +x
}

