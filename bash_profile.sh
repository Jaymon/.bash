#!/bin/bash
###############################################################################
# bash_profile.sh
#
# if you only want certain functionality, you can source a file individually, if you
# want everything, then you source this file and it will worry about sourcing all the
# other files. So, for example, if you just want the prompt:
#   . env.sh
#
# but to get everything:
#
#   . bash_profile.sh
###############################################################################

#set -x

#set +x

#set -x
# source all the shell files in the directory that aren't this one
#sra=$(python -c "import time; print(time.time())")


# autodiscover the directory if it isn't already set
if [[ -z "$DOTBASH_DIR" ]]; then

    # http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in
    function getBashDir(){
        src="${BASH_SOURCE[0]}"
        while [ -h "$src" ]; do # resolve $source until the file is no longer a symlink
            dir="$( cd -P "$( dirname "$src" )" && pwd )"
            src="$(readlink "$src")"
            # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
            [[ $src != /* ]] && src="$dir/$src" 
        done
        dir="$( cd -P "$( dirname "$src" )" && pwd )"
        echo "$dir"
    }

    export DOTBASH_DIR=getBashDir
fi

export DOTBASH_INCLUDE_DIR=$DOTBASH_DIR/include
export DOTBASH_PROFILE_DIR=$DOTBASH_DIR/profile
export DOTBASH_BIN_DIR=$DOTBASH_DIR/bin


# add our bin file to the end of path
export PATH="$PATH:$DOTBASH_BIN_DIR"
export PATH="$PATH:$DOTBASH_BIN_DIR/search"
export PATH="$PATH:$DOTBASH_BIN_DIR/ssh"


if [[ $DOTBASH_PROFILE_LOAD != "0" ]]; then

    #echo "Loading $DOTBASH_PROFILE_DIR"

    # source all the environment files
    for fi in $(find "$DOTBASH_PROFILE_DIR" -name "*.sh"); do
        #echo "$fi"
        #sr=$(python -c "import time; print(time.time())")
        source "$fi"
        #echo "Took $(python -c "import time; print(time.time() - $sr)") to load $fi"
    done

fi


###############################################################################
# readline - configure readline using the inputrc file and the ~/.inputrc file if available
###############################################################################

# http://www.softpanorama.org/Scripting/Shellorama/inputrc.shtml
# http://unix.stackexchange.com/questions/27471/setting-readline-variables-in-the-shell

#base_dot_bash_dir=$(dirname "${BASH_SOURCE[0]}")
base_dot_bash_dir=$DOTBASH_DIR

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







#src_d=$(getBashDir)
#src_f="${BASH_SOURCE[0]}"
#src_fs=($(ls $(getBashDir)/profile/*.sh))
#for src_f in "${src_fs[@]}"; do
#  #sr=$(python -c "import time; print(time.time())")
#  if [[ -f $src_f ]]; then
#    # filter out "private" shell files in the directory
#    if [[ $(basename $src_f) != _* ]]; then
#      source $src_f
#    fi
#  fi
#  #echo "Took $(python -c "import time; print(time.time() - $sr)") to load $src_f"
#done
#set +x


#echo "Took $(python -c "import time; print(time.time() - $sra)") to load all.sh"

