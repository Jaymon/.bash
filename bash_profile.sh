#!/bin/bash
###############################################################################
# bash_profile.sh
#
# if you only want certain functionality, you can source a file individually, if you
# want everything, then you source this file and it will worry about sourcing all the
# other files. If you do source a file separately be warned it might have a dependency
# on something else that won't be in the environment, so the safest way is just to
# source this file and take everything
#
# but to get everything:
#
#   . bash_profile.sh
###############################################################################

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
export DOTBASH_PROFILE_DIR=$DOTBASH_DIR/profile.d
export DOTBASH_BIN_DIR=$DOTBASH_DIR/bin


# add our bin file to the end of path
for di in $(find "$DOTBASH_BIN_DIR" -type d); do
    #echo $di
    export PATH="$PATH:$di"
done

#export PATH="$PATH:$DOTBASH_BIN_DIR"
#export PATH="$PATH:$DOTBASH_BIN_DIR/search"
#export PATH="$PATH:$DOTBASH_BIN_DIR/ssh"


# source all the environment files
for fi in $(find "$DOTBASH_PROFILE_DIR" -name "*.sh"); do
    #echo "$fi"
    #sr=$(python -c "import time; print(time.time())")
    source "$fi"
    #echo "Took $(python -c "import time; print(time.time() - $sr)") to load $fi"
done


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

