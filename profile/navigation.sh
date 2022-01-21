
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
  source $DOTBASH_INCLUDE_DIR/search_and_run.sh
  dar . $1 cd
}


if [[ ! -f $QCD_FILEPATH ]]; then

#  SH_INCLUDE_DIR="${BASH_SOURCE%/*}"
#  if [[ ! -d "$SH_INCLUDE_DIR" ]]; then SH_INCLUDE_DIR="$PWD"; fi
#  . "$SH_INCLUDE_DIR/env.sh"

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

  source $DOTBASH_INCLUDE_DIR/userprompt.sh

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


# some more ls aliases
# http://apple.stackexchange.com/questions/33677/
alias ls='ls -Gp'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias lt='ll -tr'
#? lr -> Full Recursive Directory Listing
alias lr='ls -R | grep ":$" | sed -e '\''s/:$//'\'' -e '\''s/[^-][^\/]*\//--/g'\'' -e '\''s/^/   /'\'' -e '\''s/-/|/'\'''


# count all the files in a directory
#? fcount -> count how many files in the current directory
alias fcount='ls -l | wc -l'


#? mkcd DIR -> create DIR then change into it
# since 3-10-12
function mkcd(){
  mkdir -p "$@"
  cd "$@"
}


###############################################################################
#? bgcolor R G B -> set the bg color of the terminal, each color value from 1-255
# currently works only with iTerm2
# from https://gist.github.com/thomd/956095
# howto for linux: http://askubuntu.com/questions/558280/changing-colour-of-text-and-background-of-terminal
#
# This is designed to be used in a shell prompt
###############################################################################
function bgcolor_auto () {

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

        if [[ $found -eq 0 ]]; then
            bgcolor $BGCOLOR_DEFAULT
        fi

        export PWD_PREV=$PWD

    fi

}

