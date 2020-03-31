
#? typegrep TYPE PATTERN -> search only files with extension TYPE for PATTERN
function typegrep() {
  #set -x
  flags="-Rin"
  if [[ $2 =~ [A-Z] ]]; then
    flags="-Rn"
  fi

  # http://stackoverflow.com/a/8906229/5006
  if git -C . rev-parse  > /dev/null 2>&1; then

    # in order to filter the gitignored files we first just return the files that
    # have matches, then whittle those down and then print the matches to the screen
    grep $flags --include=*.$1 --files-with-matches "$2" "${@:3}" . \
        | git check-ignore -vn --stdin \
        | grep "^::" \
        | cut -d$'\t' -f2 \
        | tr '\n' '\0' \
        | xargs -0 grep ${flags}H --line-number --color "$2"

  else

    grep $flags --color --line-number --include=*.$1 "$2" "${@:3}" .

  fi
  #set +x
}


#? txtgrep PATTERN -> search txt files for PATTERN
function txtgrep() {
  typegrep txt "$@"
  typegrep md "$@"
}
alias textgrep=txtgrep


#? shgrep PATTERN -> search shell/bash files for PATTERN
function shgrep() {
  typegrep sh "$@"
}


#? rbgrep PATTERN -> search ruby files for PATTERN
function rbgrep() {
  typegrep rb "$@"
}
alias rubygrep=rbgrep 


#? pygrep PATTERN -> search python files for PATTERN
function pygrep() {
  # http://stackoverflow.com/a/3816747/5006 "$@" is handled as a special case by the shell. 
  # That is, "$@" is equivalent to "$1" "$2" ...
  typegrep py "$@" --exclude=*.pyc --exclude-dir="python2*" --exclude-dir="python3*"

}


#? iosgrep PATTERN -> search obj-c and swift files for PATTERN
function iosgrep() {
  typegrep m "$@"
  typegrep h "$@"
  typegrep swift "$@"
}


# find all the folders of passed in value
#? where <NAME> -> find all folders with NAME (supports * wildcard)
function where(){
  >&2 echo " = = = = Directories"
  whered "$@"
  >&2 echo " = = = = Files"
  wheref "$@"
  #sudo find / -type d | grep $1
}


#? whered <NAME> -> find all directories matching <NAME>
function whered() {
  >&2 echo "sudo find / -type d -iname $1"
  sudo find / -type d -iname "$1"
}


#? wheref <NAME> -> find all files matching <NAME>
function wheref() {
  >&2 echo "sudo find / -type f -iname $1"
  sudo find / -type f -iname "$1"
}

#? f <VALUES> -> wildcard join values and search for matches from the current dir down
function f() {
    # set command: https://stackoverflow.com/a/2853811/5006 (bash display command)
    # find not part: https://askubuntu.com/a/318211 (find ignore dot directories)
    # wildcard joining: https://unix.stackexchange.com/a/528536/118750 (bash join passed in arguments with delimiter)
    v=$(printf "%s*" "$@")
    v="*${v}"
    set -x
    find . -not -path '*/\.*' -ipath "$v"
    set +x
}


#? biggest DIR LIMIT -> Finding the biggest files in DIR, showing LIMIT results
# https://www.quora.com/What-are-some-time-saving-tips-that-every-Linux-user-should-know/answer/Raghav-Yadav-2
# http://unix.stackexchange.com/questions/17812/how-to-list-all-directories-according-to-their-size-without-including-the-pare
#alias biggest='ls -lSrh'
function biggest() {
  path=$1
  if [[ -z $path ]]; then
    path=.
  fi

  size=$2
  if [[ -z $size ]]; then
    size="25"
  fi

  # http://stackoverflow.com/a/18496493/5006
  find "$path" -maxdepth 5 -exec du -s {} + | sort -n | tail -$size | cut -d$'\t' -f2 | xargs -I{} du -h -s "{}"
}

#? mostused -> lists the most used commands on the shell
# https://www.quora.com/What-are-some-time-saving-tips-that-every-Linux-user-should-know/answer/Abhiroop-Sarkar
alias mostused="history | awk '{a[$2]++}END{for(i in a){print a[i] \" \" i}}' | sort -rn | head"

