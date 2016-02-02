#!/bin/bash
###############################################################################
# mac.sh
#
# mac/apple specific commands
#
###############################################################################
# TODO -- steal a lot of commands from this file...
# I am currently in section 4: Searching
# http://natelandau.com/my-mac-osx-bash_profile/

# we only want to bother sourcing any of this if we are in MacOS
if ! uname | grep -q "Darwin"; then
  return 0
fi


#? which -> better which implementation that shows aliases also
alias which='type -all'


#? fopen <PATH> -> Opens PATH in MacOS Finder
#alias fopen='open -a Finder ./'
function fopen () {
  if [[ $# -gt 0 ]]; then
    open -a Finder "$@"
  else
    # open . also works
    open -a Finder .
  fi
}


if ! which trash > /dev/null 2>&1; then
  # this is blocked because there is a brew script that can be installed that adds
  # a trash command, which should take precedence
  #? trash -> Moves a file to the MacOS trash
  trash () { command mv "$@" ~/.Trash ; }
fi


#? preview -> Opens any file in MacOS Quicklook Preview
preview () {
  qlmanage -p "$*" >& /dev/null;
}


#? DT -> Pipe content to file on MacOS Desktop
alias DT='tee ~/Desktop/terminalOut.txt'


#? cdf -> 'Cd's to frontmost window of MacOS Finder
cdf () {
  currFolderPath=$( /usr/bin/osascript <<EOT
      tell application "Finder"
          try
      set currFolder to (folder of the front window as alias)
          on error
      set currFolder to (path to desktop folder as alias)
          end try
          POSIX path of currFolder
      end tell
EOT
  )
  echo "cd to \"$currFolderPath\""
  cd "$currFolderPath"
}


#? dsrm <PATH> -> remove all .DS_Store files at PATH, defaults to .
function dsrm(){
  if [ "$#" -eq 0 ]; then
    find . -name '.DS_Store' -delete
  else
    find $1 -name '.DS_Store' -delete
  fi
}
alias rmds=dsrm


#? pml <path> -> convert a binary plist to an xml plist you can read
# http://initwithfunk.com/blog/2013/05/31/breaking-bad-with-dtrace/
alias pml='plutil -convert xml1'
alias plistxml=pml


#? pcat <path> -> cat plist file, this will convert to xml first
function pcat () {
  pml "$1"
  cat "$1"
}

#? ebook-convert <SRC> <DEST> -> wrapper around calibre's built-in ebook converting CLI tool
# http://manual.calibre-ebook.com/cli/ebook-convert.html
# quick code for batch converting http://ubuntuforums.org/showthread.php?t=2085148
function ebook-convert () {
  if [[ -d /Applications/calibre.app/Contents/MacOS ]]; then
    /Applications/calibre.app/Contents/MacOS/ebook-convert "$@"
  else
    echo "You need Calibre installed to convert ebooks"
  fi
}


#? bgcolor R G B -> set the bg color of the terminal, each color value from 1-255
# from https://gist.github.com/thomd/956095
# howto for linux: http://askubuntu.com/questions/558280/changing-colour-of-text-and-background-of-terminal
bgcolor () {
  local R=$1
  local G=$2
  local B=$3
  /usr/bin/osascript <<EOF
tell application "iTerm"
  tell the current terminal
    tell the current session
      set background color to {$(($R*65535/255)), $(($G*65535/255)), $(($B*65535/255))}
    end tell
  end tell
end tell
EOF
}

# if we haven't specified a default bgcolor then go ahead and use my default
# TODO -- probably make this pull the default from iterm, but this will work for
# right now and I don't care enough to make it more portable
if [[ -z $BGCOLOR_DEFAULT ]]; then
  export BGCOLOR_DEFAULT="255 255 255"
fi

# this is run everytime a command is run, it will look for a .bgcolor file in the
# directory (and every parent directory) and when it finds it it will set the current
# shell's background color to the R G B color specified in the file
function bgcolor_auto () {
  # if I ever want to try and only run this when moving directories
  # http://stackoverflow.com/questions/6109225/bash-echoing-the-last-command-run
  if [[ $PWD != $PWD_PREV ]]; then
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

    if [[ found -eq 0 ]]; then
      bgcolor $BGCOLOR_DEFAULT
    fi

    export PWD_PREV=$PWD

  fi

#  curdir=$(pwd)
#  color_file="$curdir/.bgcolor"
#  if [[ -e $color_file ]]; then
#    echo "here"
#    bgcolor $(cat $color_file)
#  fi
}

export PROMPT_COMMAND="$PROMPT_COMMAND;bgcolor_auto"

