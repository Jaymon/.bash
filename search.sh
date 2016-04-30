
#? typegrep TYPE PATTERN -> search only files with extension TYPE for PATTERN
function typegrep() {
  flags="-Rin"
  if [[ $1 =~ [A-Z] ]]; then
    flags="-Rn"
  fi

  # http://stackoverflow.com/a/8906229/5006
  grep $flags --color --include=*.$1 "$2" ${@:3} .

}


function txtgrep() {
  typegrep txt $@
}


function shgrep() {
  typegrep sh $@
}


function rbgrep() {
  typegrep rb $@
}
alias rubygrep=rbgrep


function pygrep() {
  typegrep py $@ --exclude=*.pyc


#  flags="-Rin"
#  if [[ $1 =~ [A-Z] ]]; then
#    flags="-Rn"
#  fi
#
#  grep $flags --color --exclude=*.pyc --include=*.py "$1" .

}


# find all the folders of passed in value
#? where <NAME> -> find all folders with NAME (supports * wildcard)
function where(){
  whered $@
  wheref $@
  #sudo find / -type d | grep $1
}


#? whered <NAME> -> find all directories matching <NAME>
function whered(){
  echo " = = = = Directories"
	echo "sudo find / -type d -iname $1"
	sudo find / -type d -iname $1
}


#? wheref <NAME> -> find all files matching <NAME>
function wheref(){
	echo " = = = = Files"
	echo "sudo find / -type f -iname $1"
  sudo find / -type f -iname $1
}


