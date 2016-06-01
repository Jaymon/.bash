#!/bin/bash
###############################################################################
# all.sh
#
# if you only want certain functionality, you can source a file individually, if you
# want everything, then you source this file and it will worry about sourcing all the
# other files. So, for example, if you just want the prompt:
#   . env.sh
#
# but to get everything:
#
#   . all.sh
###############################################################################

#set -x

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

#set +x

#set -x
# source all the shell files in the directory that aren't this one
src_file="${BASH_SOURCE[0]}"
src_files=($(ls $(getBashDir)/*.sh | grep -v "$src_file"))
for src_f in "${src_files[@]}"; do
  if [[ -f $src_f ]]; then
    # filter out "private" shell files in the directory
    if [[ $(basename $src_f) != _* ]]; then
      . $src_f
    fi
  fi
done
#set +x


