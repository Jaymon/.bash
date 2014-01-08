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
  if [ -f $src_f ]; then
    #echo $src_f
    . $src_f
  fi
done
#set +x


# this will print out the input string in the form of "cmd - desc"
function printHelp(){

  regex='[[:space:]]*(.+)[[:space:]]*->[[:space:]]*(.*)'
  if [[ "$1" =~ $regex ]]; then

    # figure out how much whitespace between cmd and desc should have
    len=${#BASH_REMATCH[1]}
    sep=$'\t\t'
    if [ $len -lt 8 ]; then
      sep=$'\t\t\t'
    elif [ $len -ge 16 ]; then
      sep=$'\t'
    fi

    echo "${BASH_REMATCH[1]}${sep}${BASH_REMATCH[2]}"

  fi

}

function printHelpFile(){

  if [ -f $1 ]; then

    #we want to run the command and only split the string on newlines, not all whitespace
    # the $'\n' makes it so the newline is interpretted correctly
    IFS=$'\n'
    helplines=(`cat "$1" | grep "#?"`)
    unset IFS

    if [ ${#helplines[@]} -ne 0 ]; then

      echo ""
      echo -e "${BLUE}= = = = = = $1${NONE}"


      # this will loop through each item in the array
      for line in "${helplines[@]}"; do

        if [ "${line:0:2}" == "#?" ]; then

          printHelp "${line:2}"

        fi

      done

    fi

  fi
}

#? ? -> print this help menu
function bashHelp(){

  # we self document these files
  bashfiles=($(ls $(getBashDir)/*.sh))
  for bashfile in "${bashfiles[@]}"; do
    printHelpFile $bashfile
  done

  bashfiles=(~/.bashrc ~/.bash_aliases ~/.bash_profile)
  for bashfile in "${bashfiles[@]}"; do
    printHelpFile $bashfile
  done

  # http://noopsi.com/item/11479/quick_reference_keyboard_shortcuts_cli_linux_learned/
  # http://stackoverflow.com/questions/68372/what-is-your-single-most-favorite-command-line-trick-using-bash
  # http://www.hypexr.org/bash_tutorial.php#emacs
  # http://www.catonmat.net/blog/the-definitive-guide-to-bash-command-line-history/
  echo ""
  echo -e "${BLUE}= = = = = = Bash shell keyboard shortcuts${NONE}"
  echo $'bind -p\t\tshow all keyboard shorcuts'
  echo $'ctrl-a\t\tMove cursor to the beginning of the input line.'
  echo $'ctrl-e\t\tMove cursor to the end of the input line.'
  echo $'alt-b\t\tMove cursor back one word'
  echo $'alt-f\t\tMove cursor forward one word'
  echo ""
  echo $'ctrl-p\t\tup arrow'
  echo $'ctrl-n\t\tdown arrow'
  echo ""
  echo $'ctrl-w\t\tCut the last word'
  # A combination of ctrl-u to cut the line combined with ctrl-y can be very helpful. 
  # If you are in middle of typing a command and need to return to the prompt to retrieve 
  # more information you can use ctrl-u to save what you have typed in and after you 
  # retrieve the needed information ctrl-y will recover what was cut.
  echo $'ctrl-u\t\tCut everything before the cursor'
  echo $'ctrl-d\t\tSame as [DEL] (this is the Emacs equivalent).'
  echo $'ctrl-k\t\tCut everything after the cursor'
  echo $'ctrl-l\t\tClear the terminal screen.'
  echo $'ctrl-y\t\tPaste, at the cursor, the last thing to be cut'
  echo $'ctrl-_\t\tUndo the last thing typed on this command line'
  echo ""
  echo $'ctrl-t\t\tSwaps last 2 typed characters'
  echo $'ctrl-r <text>\tsearch history for <text>'
  echo $'ctrl-L\t\tClears the Screen, similar to the clear command'
  echo ""
  echo $'set -o emacs\tSet emacs mode in Bash (default)'
  echo $'set -o vi\tSet vi mode in Bash (initially in insert mode)'
  echo ""
  echo -e "${BLUE}= = = = = = Tips${NONE}"
  # http://www.unix.com/ubuntu/81380-how-goto-end-file.html
  echo "less - shift-g to move to the end of a file" 

  echo ""
  echo -e "${BLUE}= = = = = = Useful Commands${NONE}"

  printHelp "cd - -> go to the previous directory (similar to pop)"
  # https://news.ycombinator.com/item?id=5565689
  printHelp "!N:p -> do not run, place history line N on the prompt"
  printHelp "!$, !N:$ -> last argument of last command, last argument of N command"
  printHelp "!vi:$ -> last argument of last vi command"

  # http://stackoverflow.com/a/68429/5006
  printHelp "sudo !! -> run the last command with sudo"
  # http://www.codecoffee.com/tipsforlinux/articles/22.html
  printHelp "du -sh -> get the total disk usage of folder"

  # http://stackoverflow.com/a/171938/5006
  printHelp "ls -d */ -> list only subdirectories of the current dir"

  # http://www.cyberciti.biz/faq/redirecting-stderr-to-stdout/
  # http://www.cyberciti.biz/faq/how-to-redirect-output-and-errors-to-devnull/
  printHelp "cmd &> file -> pipe the cmd stderr output to a file"
  printHelp "cmd > file 2>&1 -> pipe all cmd output to a file or /dev/null"
  printHelp ". file -> pull aliases and functions from file into shell"
  printHelp "set -x/set +x -> turn on/off bash shell debugging"
  
  # http://www.cyberciti.biz/tips/linux-debian-package-management-cheat-sheet.html
  printHelp "dpkg -L <NAME> -> list files owned by the installed package NAME"
  printHelp "dpkg -l <NAME> -> list packages related to NAME"
  printHelp "dpkg -S <FILE> -> what packages owns FILE"
  printHelp "dpkg -s <NAME> -> get info about installed package NAME"
  # http://askubuntu.com/questions/47856/how-to-get-to-know-the-information-about-a-package-before-installation-in-termin
  printHelp "apt-cache show <NAME> -> get info about package NAME pre-install"
  # http://www.howtogeek.com/howto/linux/show-the-list-of-installed-packages-on-ubuntu-or-debian/
  printHelp "dpkg --get-selections -> list all installed packages"
  printHelp "apt-cache search <NAME> -> search packages related to NAME"
  printHelp "apt-cache depends <NAME> -> list dependencies of package NAME"
  # http://www.debian-administration.org/articles/184
  printHelp "lsof -i :<PORT> -> see what is listening on that port"
  # http://ubuntuforums.org/showthread.php?t=261366
  printHelp "dpkg --get-selections -> list all installed packages"
  printHelp "pgrep <VALUE> -> process grep for VALUE"

}
# sadly, these don't work
#alias -h=help
#alias --help=help
alias ?=bashHelp

