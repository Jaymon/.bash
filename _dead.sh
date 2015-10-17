#? p PROJECT -> easily get into the ~/Projects/PROJECT/_PROJECT folder
# NOTE: even if there is more than one match for each search, it will choose the first matched array element
# which is usually what we want
function project() {

  # http://stackoverflow.com/questions/2264428/converting-string-to-lower-case-in-bash-shell-scripting
  # http://stackoverflow.com/questions/12487424/uppercase-first-character-in-a-variable-with-bash
  # bash >4 only
  # projectdir=${1^} # first letter capitalized
  # projectdir=$(find ~/Projects -type d -maxdepth 1 -iname "$1")
  # all the array stuff: http://www.thegeekstuff.com/2010/06/bash-array-tutorial/

  #set -x

  basedir=~/Projects
  if [[ "$#" -eq 0 ]]; then

    pushd $basedir > /dev/null 2>&1

  else

    projectdir=$(find $basedir -type d -maxdepth 1 -mindepth 1 | grep -ve "/\." | grep -ie "/$1[^/]*\$")
    #gitdir="_${1,,}" # all lowercase
    for f in "${@:2}"; do
      projectdir=$(find "$projectdir" -type d -mindepth 1 | grep -ve "/\." | grep -ie "/$f[^/]*\$")
      #gitdir="_${2,,}"
      IFS=$'\n'; projectdir=( $projectdir ); unset IFS

      # find the smallest path in the array
      pd=${projectdir[0]}
      for pdt in "${projectdir[@]:1}"; do
        # http://www.cyberciti.biz/faq/unix-linux-appleosx-bsd-bash-count-characters-variables/
        lpd="${pd//[^//]}"
        lpdt="${pdt//[^//]}"
        if [[ ${#lpdt} -lt ${#lpd} ]]; then
        #if [[ ${#pdt} -lt ${#pd} ]]; then
          pd=$pdt
        fi
      done

      projectdir=$pd

#      if [[ ${#projectdir[@]} -gt 1 ]]; then
#        projectdir=${projectdir[0]}
#      fi
    done

    # add a _dir if one is found
    # http://stackoverflow.com/questions/3294072/bash-get-last-dirname-filename-in-a-file-path-argument
    gitdir="_$(basename $projectdir)"
    if [[ -d "$projectdir/$gitdir" ]]; then
      projectdir=$projectdir/$gitdir
    fi

    pushd $projectdir > /dev/null 2>&1

  fi

  #set +x
}
alias p=project
alias pf='project first'


