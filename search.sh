
#? typegrep TYPE PATTERN -> search only files with extension TYPE for PATTERN
function typegrep() {
  flags="-Rin"
  if [[ $2 =~ [A-Z] ]]; then
    flags="-Rn"
  fi

  # http://stackoverflow.com/a/8906229/5006
  if git -C . rev-parse  > /dev/null 2>&1; then
    # in order to filter the gitignored files we first just return the files that
    # have matches, then whittle those down and then print the matches to the screen
    grep $flags --include=*.$1 --files-with-matches "$2" "${@:3}" . | git check-ignore -vn --stdin | grep "^::" | cut -d$'\t' -f2 | xargs grep --color "$2"
  else
    grep $flags --color --include=*.$1 "$2" "${@:3}" .
  fi

}


function txtgrep() {
  typegrep txt "$@"
}
alias textgrep=txtgrep


function shgrep() {
  typegrep sh "$@"
}


function rbgrep() {
  typegrep rb "$@"
}
alias rubygrep=rbgrep 

function pygrep() {
  # http://stackoverflow.com/a/3816747/5006 "$@" is handled as a special case by the shell. 
  # That is, "$@" is equivalent to "$1" "$2" ...
  typegrep py "$@" --exclude=*.pyc

}


# find all the folders of passed in value
#? where <NAME> -> find all folders with NAME (supports * wildcard)
function where(){
  whered "$@"
  wheref "$@"
  #sudo find / -type d | grep $1
}


#? whered <NAME> -> find all directories matching <NAME>
function whered() {
  echo " = = = = Directories"
	echo "sudo find / -type d -iname $1"
	sudo find / -type d -iname $1
}


#? wheref <NAME> -> find all files matching <NAME>
function wheref() {
	echo " = = = = Files"
	echo "sudo find / -type f -iname $1"
  sudo find / -type f -iname $1
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

