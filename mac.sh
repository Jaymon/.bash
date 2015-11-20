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

