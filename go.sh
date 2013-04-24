# create a goenv function that will export GOPATH to the current directory
# or the passed in directory, and then it will set a file in temp that will
# contain the exported GOPATH, so every shell that is booted up will 
# check that file and load the path if it exists, something like /tmp/gopath.sh
# and this script will just source it if it exists :)

#? goenv <path> -> set the GOPATH to <path> or $PWD if <path> not present
# this requires util.sh to work
function goenv(){
  if [[ $# -eq 0 ]]; then
    exportglobal GOPATH="\"$PWD\""
  else
    exportglobal GOPATH="\"$1\""
  fi
}

