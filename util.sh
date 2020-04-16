#!/bin/bash
###############################################################################
# util.sh
#
# functions/aliases that help me do things easier
#
# Things I always forget:
#   [[ ]] and [ ] syntax:
#     http://stackoverflow.com/questions/669452/is-preferable-over-in-bash-scripts
#     http://mywiki.wooledge.org/BashFAQ/031
#
# The IFS variable: http://en.wikipedia.org/wiki/Internal_field_separator
#
#
#
###############################################################################

###############################################################################
# Includes
###############################################################################
# http://stackoverflow.com/a/12694189/5006
SH_INCLUDE_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$SH_INCLUDE_DIR" ]]; then SH_INCLUDE_DIR="$PWD"; fi
. "$SH_INCLUDE_DIR/_internal.sh"


#? myhost -> return the hostname of the computer
# http://apple.stackexchange.com/a/53042
# http://superuser.com/a/430209
function myhost(){
  if [ $(is_os Darwin) -eq 0 ]; then
    scutil --get LocalHostName
  else
    echo $HOSTNAME
  fi
}


alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias igrep='grep -i'
# have grep ignore symlinks
# http://www.linuxquestions.org/questions/linux-newbie-8/can-grep-exclude-symlinks-838343/
function ggrep(){
  find . -type f -exec grep --color -Hn $1 {} \;
}


# have less, by default, give more information on the prompt
# 2-20-12 
# http://en.wikipedia.org/wiki/Less_%28Unix%29
alias less='less -M'


#? ncpu -> how many cpus and cores this machine has
# http://superuser.com/questions/49659/how-many-cores-i-am-using-on-a-linux-server
# 5-30-12
function ncpu(){

  if [ $(is_os Darwin) -eq 0 ]; then
    system_profiler SPHardwareDataType
  else
    num_cpus=$(grep "physical id" /proc/cpuinfo | sort -u | wc -l)
    if [ $num_cpus -eq 0 ]; then num_cpus=1; fi

    num_cores=$(grep -c ^processor /proc/cpuinfo)

    echo "number of cpus: $num_cpus"
    echo "number of cores: $num_cores"
    echo "number of cores per cpu: $(($num_cores / $num_cpus))"
  fi

}


#? mkcd DIR -> create DIR then change into it
# since 3-10-12
function mkcd(){
  mkdir -p "$@"
  cd "$@"
}


#? zombies -> list any found zombies
# since 3-12-12
# http://www.debian-administration.org/articles/261
function zombies(){
  ps -A -ostat,ppid,pid,args | grep -e '^[Zz]'
}


# http://stackoverflow.com/questions/941338/shell-script-how-to-pass-command-line-arguments-to-an-unix-alias
# quickly check what processes are running
#? running <NAME> -> return what processes matching NAME are currently running
function running(){
  # filter out the grep process
	ps aux | grep -v "grep" | grep $1
}
alias r=running


# get the running time of the process that match user passed in value
#? rtime <NAME> -> get running time of processes matching name'
function rtime(){
	ps -eo pid,etime,args | grep -v "grep" | grep $1
}


#? murder <NAME> -> run every process that matches NAME through sudo kill -9
# 2-20-12
# http://stackoverflow.com/questions/262597/how-to-kill-a-linux-process-by-stime-dangling-svnserve-processes
function murder(){
  echo -e "${RED}These will be killed:${NONE}"
  ps -eo pid,args | grep -v "grep" | grep $1
  # first 3 commands find the right running processes
  # sed - gets rid of any whitespace from the front of the command
  # cut - gets the first column (in this case, the pid)
  # xargs - runs each found pid through the kill command
  ps -eo pid,args | grep -v "grep" | grep "$1" | sed "s/^ *//" | cut -d' ' -f1 | xargs -i sudo kill -9 "{}"
}


# http://stackoverflow.com/a/68600/5006
#? bak <filepath> -> make a copy of filepath named filepath.bak
function bak(){
  if [ -w $1 ]; then
    cp $1{,.bak}
  else
    sudo cp $1{,.bak}
  fi
}
#? mbak <filepath> -> rename a file from filepath to filepath.bak
function mbak(){
  if [ -w $1 ]; then
    mv $1{,.bak}
  else
    sudo mv $1{,.bak}
  fi
}


#? ret -> returns the result code of the last run command
# http://stackoverflow.com/a/68397/500
alias ret='echo $?'


#? hist,h <cmd|n> -> get rows in history matching cmd, or last n rows
# since 3-14-12 this combined with histl (created 3-10-12)
function hist(){

  # set -x

  if [ "$#" -eq 0 ]; then

    history | tail -n 25

  elif [ $(is_int $1) -eq 0 ]; then
  
    history | tail -n $1
  
  else

    history | grep $1  
  
  fi
  
  # set +x

}
alias h=hist


#? dar DIR SEARCH CMD [CMD-PARAMS] -> find sub path n DIR and run CMD [CMD-PARAMS] found-path
function dar() {

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


#? explain <cmd> -> explain cmd, great with explain !!
function explain() {
  # https://news.ycombinator.com/item?id=6300735
  cmd="$(cut -d ' ' -f 1 <<< "$@" )";
  args="$(cut -d ' ' -f 2- <<< "$@" )";
  url="http://explainshell.com/explain/$cmd?args=$args"
  explanation="$(curl -s $url | grep '<pre' | sed -E 's/<\/?[a-z]+(\ [a-z]+=\"[a-z0-9]+\")*>//g' | sed -E 's/^\ +//g')"
  echo "$explanation"	
}




#? zipf -> To create a ZIP archive of a folder
function zipf () { zip -r "$1".zip "$1" ; }

# this is here because I can never remember how to untar and unzip a freaking .tar.gz file
#? untar FILE -> untar and unzip FILE (a .tar.gz file)
# 2-20-12
function untar(){
  echo tar -xzf $1
  tar -xzf $1
}

###############################################################################


#? incognito -> turn history off for this shell session
# http://unix.stackexchange.com/a/10923
function incognito () {
  #set +o history
  # I don't use "set +o" anymore because it makes it so I can't even hit arrow up
  # to get the last command run, I want to still have a working command history
  # I just don't want it to be persisted when the shell exits
  export HISTFILE="/dev/null"
  echo "You are now in incognito mode for the remainder of this shell session"

  # this is set to allow other scripts and things to respect incognito mode
  export INCOGNITO=1
  export TERM_TITLE="Incognito Mode"
}
alias incog=incognito

# ? unincognito -> turn history back on for this shell session
# TODO -- to make this work again, we would need to save the original HISTFILE
# value and then restore it, but I normally just close the shell, so I've decided
# to just remove this for now
#function unincognito () {
#  set -o history
#  echo "You are no longer in incognito mode"
#}


#? mans [MANPAGE] [Q] -> Search manpage given in agument '1' for term given in argument '2' (case insensitive)
# displays paginated result with colored search terms and two lines surrounding each hit.
# Example: mans mplayer codec
function mans () {
  man $1 | grep -iC2 --color=always $2 | less
}

#? mkdat [SIZE] -> Creates a file of SIZE mb in current directory (all zeros)
function mkdat () {
  mkfile "$1"m ./"$1"MB.dat
}


#? exif IMAGE_PATH -> Return all the information about an image
alias exif='identify -verbose'



