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


# check for ssh-key
added_keys=$(ssh-add -L)
if [[ -z $added_keys ]]; then
  >&2 echo "AGENT FORWARDING DISABLED - to add key: ssh-add ~/.ssh/id_rsa"
fi


#? clipboard -> alias for pbcopy, use like: cmd | clipboard
alias clipboard=pbcopy


#? witch -> better which implementation that shows aliases also
alias witch='type -all'


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
#
# via: https://scriptingosx.com/2016/11/editing-property-lists/
# It looks like -extract is meant to get values from a property list, but there
# is caveat. -extract will not merely get the value of a key in the property list
# but will write it to a new file! And by default if you do not provide an new
# output file path with the -o option it will overwrite the current file with
# the extracted data.
alias pml='plutil -convert xml1 -o -'
alias plistxml=pml


#? pcat <path> -> cat plist file, this will convert to xml first
function pcat () {
  pml "$1"
  cat "$1"
}


function kindler () {
  epubs=$(find . -depth 1 -type f -iname "*.epub")
  while read -r f; do
    echo $f
    mobi=$(basename "$f" .epub)".mobi"
    if [[ ! -f "$mobi" ]]; then
      ebook-convert "$f" "$mobi"
    fi
  done <<< "$epubs"
}


#? pwds -> print all terminal workding directories and let you choose one
function pwds() {

  source $DOTBASH_INCLUDE_DIR/userprompt.sh

  pwd_path="${TMPDIR}pwds.txt"
  echo "" > "$pwd_path"
  # TODO -- check TERM_PROGRAM=iTerm.app

  #/usr/bin/osascript <<EOT
  #tell application "iTerm"
  #  set w to (current terminal)
  #  if w is not (current terminal) then
  #    tell w
  #      repeat with s in sessions
  #        tell s
  #          write text "pwd >> \"${pwd_path}\""
  #        end tell
  #      end repeat
  #    end tell
  #  end if
  #end tell
  #EOT

#  # iterm < 3
#  /usr/bin/osascript <<EOT
#  tell application "iTerm"
#    set w2 to (current terminal)
#    set id2 to the name of the first session of w2
#    repeat with w in terminals
#      if w is not w2 then
#        tell w
#          repeat with s in sessions
#            set id1 to the name of s
#            if id1 is not id2 then
#              tell s
#                write text "pwd >> \"${pwd_path}\""
#              end tell
#            end if
#          end repeat
#        end tell
#      end if
#    end repeat
#  end tell
#EOT

  # iterm >= 3
  # https://www.iterm2.com/documentation-scripting.html
  /usr/bin/osascript <<EOT
  tell application "iTerm"
    set id1 to unique id of current session of current tab of current window
    repeat with w in windows
      tell w
        repeat with t in tabs
          tell t
            repeat with s in sessions
              set id2 to unique id of s
              if id1 is not id2
                tell s
                  write text "pwd >> \"${pwd_path}\""
                end tell
              end if
            end repeat
          end tell
        end repeat
      end tell
    end repeat
  end tell
EOT

  #cat $pwd_path

  #userprompt "$(cat $pwd_path)"

  IFS=$'\n'; ds=( $(uniq $pwd_path) ); unset IFS
  userprompt "${ds[@]}"
  if [[ -d ${userprompt_chosen[0]} ]]; then
    pushd ${userprompt_chosen[0]} > /dev/null
  fi

}


# bunch of aliases for bin/neww (I can't decide which one I want to use)
alias nw=neww
alias new=neww
alias shell=neww
alias owd=neww
alias again=neww
alias another=neww


###############################################################################
# Bash completions
###############################################################################

if [[ -f /opt/homebrew/bin/brew ]]; then

  # https://github.com/Homebrew/brew/blob/master/share/doc/homebrew/Analytics.md#opting-out
  export HOMEBREW_NO_ANALYTICS=1

  eval "$(/opt/homebrew/bin/brew shellenv)"

fi


# if which brew > /dev/null; then
# 
#   # Move (or Add) /usr/local/bin to the front of the PATH, this is for brew
#   # via: http://vim.1045645.n5.nabble.com/instructions-for-installing-macvim-td5580175.html
#   [ -d /usr/local/bin ] && export PATH=$(echo /usr/local/bin:$PATH | sed -e 's;:/usr/local/bin;;')
# 
# 
#   # add the brew sbin directory
#   export PATH="$PATH:/usr/local/sbin"
# 
#   # add all the completions installed by homebrew
#   #completion_d=$(brew --prefix)/etc/bash_completion.d
#   completion_d=/usr/local/etc/bash_completion.d
#   for f in $completion_d/*; do
#     . "$f"
#   done
# 
#   # https://github.com/Homebrew/brew/blob/master/share/doc/homebrew/Analytics.md#opting-out
#   export HOMEBREW_NO_ANALYTICS=1
# 
# fi

