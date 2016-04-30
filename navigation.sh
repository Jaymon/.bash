
###############################################################################
# Includes
###############################################################################
# http://stackoverflow.com/a/12694189/5006
#SH_INCLUDE_DIR="${BASH_SOURCE%/*}"
#if [[ ! -d "$SH_INCLUDE_DIR" ]]; then SH_INCLUDE_DIR="$PWD"; fi
#. "$SH_INCLUDE_DIR/env.sh"


#? bd <NUM> -> how many directories to move back (eg, bd 2 = cd ../..)
function bd() {
  back_dir=""
  if [[ $# -eq 0 ]]; then
    back_dir="../"
  else
    for (( i=0; i<$1; i+=1 )); do 
      back_dir=$back_dir"../"
    done
  fi

  echo "cd $back_dir"
  pushd $back_dir
}
#? .. -> cd ..
alias ..='bd' 
#? ... -> cd ../..
alias ...='bd 2'
alias ....=...


#? up <folder> -> move back in the directory structure to this folder
# http://www.quora.com/Shell-Scripting/What-are-some-time-saving-tips-that-every-Linux-user-should-know
# https://www.quora.com/What-are-some-time-saving-tips-that-every-Linux-user-should-know/answer/Himanshu-Neema
function up() {
  cd $(expr "${PWD,,}" : "^\(.*${1,,}[^/]*\)")
}


#? fd PREFIX_PATH -> find directory specified by PREFIX_PATH
function fd() {
  dar . $1 cd
}


if [[ ! -f $QCD_FILEPATH ]]; then

  SH_INCLUDE_DIR="${BASH_SOURCE%/*}"
  if [[ ! -d "$SH_INCLUDE_DIR" ]]; then SH_INCLUDE_DIR="$PWD"; fi
  . "$SH_INCLUDE_DIR/env.sh"

  export QCD_FILEPATH=$(get_tmp).qcd

fi

#? qcd [NUM | PREFIX | . | .. ] -> quick directory change
# qcd . -> add current directory to the quick directory list
# qcd .. -> move through all parents looking for a quick directory
# qcd N -> move to the N directory in the directory list
# qcd PREFIX -> prefix search the directory list
# qcd -> choose one of the directories in the list
# qcd - -> edit the directory list
function qcd() {
  if [[ $# -eq 1 ]]; then

    if [[ $1 == "." ]]; then

      curdir=$(pwd)
      if ! grep "^${curdir}$" $QCD_FILEPATH > /dev/null 2>&1; then
        echo "Adding $curdir to quick directory list"
        echo $curdir >> $QCD_FILEPATH
        # http://stackoverflow.com/a/1670483/5006
        sorted=$(cat $QCD_FILEPATH | perl -e 'print sort { length $a<=>length $b || $a cmp $b } <>')
        echo -e "$sorted" > $QCD_FILEPATH
      fi

    elif [[ $1 == ".." ]]; then

      path=$(pwd)
      while [[ $path != "/" ]]; do
        #echo "checking if $path is in quick directory list"
        if grep "^${path}$" $QCD_FILEPATH > /dev/null 2>&1; then
          pushd $path
          break
        fi
        path=$(dirname "$path")
      done

    elif [[ $1 == "-" ]]; then
      vi $QCD_FILEPATH

    else

      if [[ $1 =~ ^[0-9]+$ ]]; then
        # we have a number, so just go to that number in the list
        #userprompt_chosen=$(head -$1 $QCD_FILEPATH | tail -1)
        # http://stackoverflow.com/a/23712058/5006
        mapfile -t -s $1 -n 1 userprompt_chosen < $QCD_FILEPATH

      else
        # we searched, so do a match against any line that has our search string
        # and let one be chosen
        IFS=$'\n'; ds=( $(grep -i "$1" $QCD_FILEPATH) ); unset IFS
        userprompt "${ds[@]}"
      fi

      if [[ -d ${userprompt_chosen[0]} ]]; then
        pushd ${userprompt_chosen[0]} > /dev/null
      fi

    fi

  else

    # list all the lines in our file so one can be chosen
    IFS=$'\n'; ds=( $(cat $QCD_FILEPATH) ); unset IFS
    userprompt "${ds[@]}"
    if [[ -d ${userprompt_chosen[0]} ]]; then
      pushd ${userprompt_chosen[0]} > /dev/null
    fi

  fi
}
alias qd=qcd
alias q=qcd
alias d=qcd
  
