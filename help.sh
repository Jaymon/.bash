#!/bin/bash
###############################################################################
# help.sh
#
#`this has all the help commands that print help, it creates the ? command that # prints out all the helps stuff
#
###############################################################################


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

  # TODO -- create a HELP environment variable that will make it parse those files also
  # or make it parse the 3 files looking for sourced files?
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
  # https://www.quora.com/What-are-some-time-saving-tips-that-every-Linux-user-should-know/answer/Andrey-Tykhonov
  echo $'ctrl-/\t\tUndo the last change on this command line'
  echo ""
  echo $'ctrl-t\t\tSwaps last 2 typed characters'
  echo $'ctrl-r <text>\tsearch history for <text>'
  echo $'ctrl-L\t\tClears the Screen, similar to the clear command'
  echo ""
  # https://www.quora.com/What-are-some-time-saving-tips-that-every-Linux-user-should-know/answer/Anand-Babu-Periasamy
  echo $'Alt+.\tLast word of previous command. You can hit multiple times.'
  echo $'Alt+u|d|c\tUp case / Down case / Capitalize.'
  echo $'Ctrl+r\tReverse history search.'
  echo $'Alt+{\tAuto complete wild-card expr of current dir contents'
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
  printHelp "ll -t -> list entries sorted by modified date"

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
  # http://askubuntu.com/a/428778
  printHelp "apt-cache policy <NAME> -> list version of package NAME"
  # http://ubuntuforums.org/showthread.php?t=261366
  printHelp "dpkg --get-selections -> list all installed packages"
  # https://askubuntu.com/questions/44122/how-to-upgrade-a-single-package-using-apt-get
  printHelp "apt-get install --only-upgrade <NAME> -> upgrade just NAME package"
  printHelp "apt-get install --no-install-recommends <NAME> -> install the minimum for NAME"

  # http://www.debian-administration.org/articles/184
  printHelp "lsof -i :<PORT> -> see what is listening on that port"
  printHelp "pgrep <VALUE> -> process grep for VALUE"
  printHelp "shopt -> displays bash options settings"
  printHelp "stty sane -> Restore terminal settings when screwed up"
  # https://www.quora.com/What-are-some-time-saving-tips-that-every-Linux-user-should-know/answer/Sundeep-Agarwal-2
  printHelp "whatis <COMMAND> -> prints a single line description of command"

  # http://askubuntu.com/questions/178521/how-can-i-decode-a-base64-string-from-the-command-line
  printHelp "base64 --decode <<< BASE64-STR -> decode the base64 encoded string"

  # https://www.digitalocean.com/community/tutorials/how-to-use-ssh-keys-with-digitalocean-droplets
  printHelp "ssh-keygen -R IP-ADDRESS -> remove ip from ssh host"

  # from Topher, blows my mind
  printHelp "zless, zgrep -> same as regular versions but for gzipped files"

  # from https://github.com/yyuu/pyenv#basic-github-checkout
  printHelp "exec \$SHELL -> Restart your shell so the path changes take effect."
  printHelp "ps auxf -> Show process tree/hierarchy"

  # http://www.cyberciti.biz/faq/unix-creating-symbolic-link-ln-command/
  printHelp "ln -s EXISTING_FILEPATH SYMBOLIC_FILEPATH -> I can never remember the order"

}
# sadly, these don't work
#alias -h=help
#alias --help=help
alias ?=bashHelp

