# colors
# use them in echo like this: echo -e "${RED}test${NONE}"
# in Mac, you can't use these, you have to put in the full \e...
YELLOW='\033[0;33m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
RED='\033[0;31m'
GREEN="\033[0;32m"
BLACK='\033[0;30m'
BLUE='\033[0;34m'
NONE='\033[0m' # Text Reset

# via: http://apple.stackexchange.com/questions/9821/can-i-make-my-mac-os-x-terminal-color-items-according-to-syntax-like-the-ubuntu
C_DEFAULT="\[\033[m\]"
C_WHITE="\[\033[1m\]"
C_BLACK="\[\033[30m\]"
C_RED="\[\033[31m\]"
C_GREEN="\[\033[32m\]"
C_YELLOW="\[\033[33m\]"
C_BLUE="\[\033[34m\]"
C_PURPLE="\[\033[35m\]"
C_CYAN="\[\033[36m\]"
C_LIGHTGRAY="\[\033[37m\]"
C_DARKGRAY="\[\033[1;30m\]"
C_LIGHTRED="\[\033[1;31m\]"
C_LIGHTGREEN="\[\033[1;32m\]"
C_LIGHTYELLOW="\[\033[1;33m\]"
C_LIGHTBLUE="\[\033[1;34m\]"
C_LIGHTPURPLE="\[\033[1;35m\]"
C_LIGHTCYAN="\[\033[1;36m\]"
C_BG_BLACK="\[\033[40m\]"
C_BG_RED="\[\033[41m\]"
C_BG_GREEN="\[\033[42m\]"
C_BG_YELLOW="\[\033[43m\]"
C_BG_BLUE="\[\033[44m\]"
C_BG_PURPLE="\[\033[45m\]"
C_BG_CYAN="\[\033[46m\]"
C_BG_LIGHTGRAY="\[\033[47m\]"

# this is a helper function to allow easy testing of an int
# if you want to use this in an if: [ $(is_int <VALUE>; echo $?) -eq 0 ]
# return 0 if input is an int, not zero otherwise
function is_int(){

  # canary, only one value is allowed
  if [ $# -gt 1 ]; then return 1; fi

  # this will set the $? as either 0 or 1
  echo "$1" | grep -P "^\d+$" > /dev/null 2>&1
}

# http://noopsi.com/item/14345/find_linux_version_linux_learned/
#? version -> return linux version information
alias version='cat /etc/lsb-release'
alias v='version'

# have less, by default, give more information on the prompt
# 2-20-12 
# http://en.wikipedia.org/wiki/Less_%28Unix%29
alias less='less -M'

#? ncpu -> how many cpus and cores this machine has
# http://superuser.com/questions/49659/how-many-cores-i-am-using-on-a-linux-server
# 5-30-12
function ncpu(){

  num_cpus=$(grep "physical id" /proc/cpuinfo | sort -u | wc -l)
  if [ $num_cpus -eq 0 ]; then num_cpus=1; fi

  num_cores=$(grep -c ^processor /proc/cpuinfo)
  
  echo "number of cpus: $num_cpus"
  echo "number of cores: $num_cores"
  echo "number of cores per cpu: $(($num_cores / $num_cpus))"

}

# this is here because I can never remember how to untar and unzip a freaking .tar.gz file
#? untar FILE -> untar and unzip FILE (a .tar.gz file)
# 2-20-12
function untar(){
  echo tar -xzf $1
  tar -xzf $1
}

#? mkcd DIR -> create DIR then change into it
# since 3-10-12
function mkcd(){
  mkdir -p $1
  cd $1
}

#? zombies -> list any found zombies
# since 3-12-12
# http://www.debian-administration.org/articles/261
function zombies(){
  ps -A -ostat,ppid,pid,cmd | grep -e '^[Zz]'
}

# http://noopsi.com/item/12779/check_disk_space_linux_learned_linux_cmdline/
#? disk [PATH] [COUNT] -> return biggest [COUNT=25] file sizes in [PATH=/] 
function disk(){

  # defaults
  pth=/
  cnt=25
  
  # if there is only one argument it could be a path or a count
  # count or path can be interchangeable
  if [ $# -ge 1 ]; then
  
    if [ -d $1 ]; then
    
      pth=$1
      
      if [ $(is_int $2; echo $?) -eq 0 ]; then
      
        cnt=$2
      
      fi

    
    else
    
      if [ $(is_int $1; echo $?) -eq 0 ]; then
    
        cnt=$1
        
      fi
      
      if [ -d $2 ]; then
      
        pth=$2
      
      fi
    
    fi
  
  fi
  
  echo -e "${BLUE}= = = = = = Largest $cnt things in $pth${NONE}"
  # sudo du -h $pth | sort -n -r | head -n $cnt
  sudo du $pth | sort -n -r | head -n $cnt
  
  echo -e "${RED}= = = = = = Total disk usage${NONE}"
  df -h

}

# count all the files in a directory
#? fcount -> count how many files in the current directory
alias fcount='ls -l | wc -l'

# print out the computer's current ip address
# http://www.coderholic.com/invaluable-command-line-tools-for-web-developers/
#? myip -> print out current external ip address
#alias myip='curl ifconfig.me'
function myip(){

  if [ $(which curl &> /dev/null; echo $?) -eq 0 ]; then
    
    curl http://ifconfig.me/ip
  
  else
  
    wget -qO- http://ifconfig.me/ip
  
  fi

}
alias mip=myip

# http://stackoverflow.com/questions/941338/shell-script-how-to-pass-command-line-arguments-to-an-unix-alias
# quickly check what processes are running
#? running <NAME> -> return what processes matching NAME are currently running
function running(){
  # filter out the grep process
	ps aux | grep -v "grep" | grep $1
}
alias r=running

# get the running time of the process that match user passed in value
#? rtime <NAME> -> get running time of processes matching name'
function rtime(){
	ps -eo pid,etime,cmd | grep -v "grep" | grep $1
}

#? murder <NAME> -> run every process that matches NAME through sudo kill -9
# 2-20-12
# http://stackoverflow.com/questions/262597/how-to-kill-a-linux-process-by-stime-dangling-svnserve-processes
function murder(){
  echo -e "${RED}These will be killed:${NONE}"
  ps -eo pid,cmd | grep -v "grep" | grep $1
  # first 3 commands find the right running processes
  # sed - gets rid of any whitespace from the front of the command
  # cut - gets the first column (in this case, the pid)
  # xargs - runs each found pid through the kill command
  ps -eo pid,cmd | grep -v "grep" | grep "$1" | sed "s/^ *//" | cut -d' ' -f1 | xargs -i sudo kill -9 "{}"
}

# find all the folders of passed in value
#? where <NAME> -> find all folders with NAME (supports * wildcard)
function where(){
  echo " = = = = Directories"
	echo "sudo find / -type d -iname $1"
	sudo find / -type d -iname $1
	echo " = = = = Files"
	echo "sudo find / -type f -iname $1"
  sudo find / -type f -iname $1
  #sudo find / -type d | grep $1
}

# http://stackoverflow.com/a/68600/5006
#? bak <filepath> -> make a copy of filepath named filepath.bak
function bak(){
  if [ -w $1 ]; then
    cp $1{,.bak}
  else
    sudo cp $1{,.bak}
  fi
}
#? mbak <filepath> -> rename a file from filepath to filepath.bak
function mbak(){
  if [ -w $1 ]; then
    mv $1{,.bak}
  else
    sudo mv $1{,.bak}
  fi
}

#? ret -> returns the result code of the last run command
# http://stackoverflow.com/a/68397/500
alias ret='echo $?'

#? hist,h <cmd|n> -> get rows in history matching cmd, or last n rows
# since 3-14-12 this combined with histl (created 3-10-12)
function hist(){

  # set -x

  if [ "$#" -eq 0 ]; then

    history | tail -n 25

  elif [ $(is_int $1; echo $?) -eq 0 ]; then
  
    history | tail -n $1
  
  else

    history | grep $1  
  
  fi
  
  # set +x

}
alias h=hist

# added 2-18-12
#? idr,initd <NAME> -> init.d restart <NAME>
function idr(){
  echo "/etc/init.d/$1 restart"
  sudo /etc/init.d/$1 restart
}
alias initr=idr
alias initd=idr
alias itd=idr
alias itr=idr

#? .. -> cd ..
alias ..='cd ..' 
#? ... -> cd ../..
alias ...='cd ../..'
alias ....=...

#   This file echoes a bunch of color codes to the 
#   terminal to demonstrate what's available.  Each 
#   line is the color code of one forground color,
#   out of 17 (default + 16 escapes), followed by a 
#   test use of that color on all nine background 
#   colors (default + 8 escapes).
#   via: http://tldp.org/HOWTO/Bash-Prompt-HOWTO/x329.html
#? colors -> print available colors
function colors(){

  T='gYw'   # The test text

  echo -e "\n                 40m     41m     42m     43m\
       44m     45m     46m     47m";

  for FGs in '    m' '   1m' '  30m' '1;30m' '  31m' '1;31m' '  32m' \
             '1;32m' '  33m' '1;33m' '  34m' '1;34m' '  35m' '1;35m' \
             '  36m' '1;36m' '  37m' '1;37m';
    do FG=${FGs// /}
    echo -en " $FGs \033[$FG  $T  "
    for BG in 40m 41m 42m 43m 44m 45m 46m 47m;
      do echo -en "$EINS \033[$FG\033[$BG  $T  \033[0m";
    done
    echo;
  done
  echo
}

# this will print out the input string in the form of "cmd - desc"
function printHelp(){

  regex='\s*(.+)\s*->\s*(.*)'
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

#? bash-help -> print this help menu
function bash-help(){

  echo -e "${BLUE}= = = = = = Useful Commands${NONE}"

  printHelp "cd - -> go to the previous directory (similar to pop)"
  printHelp "!N:p -> instead of running history line N, place it on the prompt"

  # http://stackoverflow.com/a/68429/5006
  printHelp "sudo !! -> run the last command, but with sudo"

  # http://stackoverflow.com/a/171938/5006
  printHelp "ls -d */ -> list only subdirectories of the current dir"

  # http://www.cyberciti.biz/faq/redirecting-stderr-to-stdout/
  # http://www.cyberciti.biz/faq/how-to-redirect-output-and-errors-to-devnull/
  printHelp "cmd &> file -> pipe the cmd stderr output to a file"
  printHelp "cmd > file 2>&1 -> pipe all cmd output to a file or /dev/null"
  printHelp ". file -> pull aliases and functions from file into shell"
  
  # http://www.cyberciti.biz/tips/linux-debian-package-management-cheat-sheet.html
  printHelp "dpkg -L <NAME> -> list files owned by the installed package NAME"
  printHelp "dpkg -l <NAME> -> list packages related to NAME"
  printHelp "dpkg -S <FILE> -> what packages owns FILE"
  printHelp "dpkg -s <NAME> -> get info about package NAME"
  printHelp "apt-cache search <NAME> -> search packages related to NAME"
  printHelp "apt-cache depends <NAME> -> list dependencies of package NAME"
  # http://www.debian-administration.org/articles/184
  printHelp "lsof -i :<PORT> -> see what is listening on that port"
  # http://ubuntuforums.org/showthread.php?t=261366
  printHelp "dpkg --get-selections -> list all installed packages"

  # we self document these files
  bashfiles=(~/.bash_aliases ~/.bash_adhoc)
  for bashfile in "${bashfiles[@]}"; do

    if [ -f $bashfile ]; then

      echo ""
      echo -e "${BLUE}= = = = = = $bashfile${NONE}"

      #we want to run the command and only split the string on newlines, not all whitespace
      # the $'\n' makes it so the newline is interpretted correctly
      IFS=$'\n'
      helplines=(`cat "$bashfile" | grep "#?"`)
      unset IFS

      # this will loop through each item in the array
      for line in "${helplines[@]}"; do

        if [ "${line:0:2}" == "#?" ]; then

          printHelp "${line:2}"

        fi

      done

    fi

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

}
# sadly, these don't work
#alias -h=help
#alias --help=help
alias ?=bash-help

# http://old.nabble.com/show-all-if-ambiguous-broken--td1613156.html
# http://stackoverflow.com/a/68449/5006
# http://liquidat.wordpress.com/2008/08/20/short-tip-bash-tab-completion-with-one-tab/
# http://superuser.com/questions/271626/
bind "set completion-ignore-case on"
bind "set show-all-if-ambiguous on"
bind "set mark-symlinked-directories on"
bind "set show-all-if-unmodified on"

# don't ever obliterate the history file
# http://briancarper.net/blog/248/ via: http://news.ycombinator.com/item?id=3755276
shopt -s histappend

# http://stackoverflow.com/a/69087/5006
# do ". acd_func.sh"
# acd_func 1.0.5, 10-nov-2004
# petar marinov, http:/geocities.com/h2428, this is public domain
cd_func ()
{
  local x2 the_new_dir adir index
  local -i cnt

  if [[ $1 ==  "--" ]]; then
    dirs -v
    return 0
  fi

  the_new_dir=$1
  [[ -z $1 ]] && the_new_dir=$HOME

  if [[ ${the_new_dir:0:1} == '-' ]]; then
    #
    # Extract dir N from dirs
    index=${the_new_dir:1}
    [[ -z $index ]] && index=1
    adir=$(dirs +$index)
    [[ -z $adir ]] && return 1
    the_new_dir=$adir
  fi

  #
  # '~' has to be substituted by ${HOME}
  [[ ${the_new_dir:0:1} == '~' ]] && the_new_dir="${HOME}${the_new_dir:1}"

  #
  # Now change to the new dir and add to the top of the stack
  pushd "${the_new_dir}" > /dev/null
  [[ $? -ne 0 ]] && return 1
  the_new_dir=$(pwd)

  #
  # Trim down everything beyond 11th entry
  popd -n +11 2>/dev/null 1>/dev/null

  #
  # Remove any other occurence of this dir, skipping the top of the stack
  for ((cnt=1; cnt <= 10; cnt++)); do
    x2=$(dirs +${cnt} 2>/dev/null)
    [[ $? -ne 0 ]] && return 0
    [[ ${x2:0:1} == '~' ]] && x2="${HOME}${x2:1}"
    if [[ "${x2}" == "${the_new_dir}" ]]; then
      popd -n +$cnt 2>/dev/null 1>/dev/null
      cnt=cnt-1
    fi
  done

  return 0
}

#? cd - -> go to the previous directory (similar to pop)
#? cd -- -> list all dirs in history
#? cd -N -> go to dir specified at N (N found via cd --)
alias cd=cd_func

# this will set the prompt to red if the last command failed, and green if it succeeded
# https://wiki.archlinux.org/index.php/Color_Bash_Prompt
ORIG_PS1=$PS1
PROMPT_COMMAND='RET=$?; history -a'
RET_COLOR='$(if [[ $RET = 0 ]]; then echo -ne "${GREEN}"; else echo -ne "${RED}"; fi;)'
PS1="\[${RET_COLOR}\]$ORIG_PS1\[${NONE}\]"

# include the bash_adhoc file
# basically, since this file is now generic, I needed a new place to put custom
# methods that are for a particular box
if [ -f ~/.bash_adhoc ]; then
    . ~/.bash_adhoc
fi
