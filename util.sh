#!/bin/bash
###############################################################################
# util.sh
#
# functions/aliases that help me do things easier
###############################################################################

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

# some more ls aliases
# http://apple.stackexchange.com/questions/33677/
alias ls='ls -Gp'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias lt='ll -tr'

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
# have grep ignore symlinks
# http://www.linuxquestions.org/questions/linux-newbie-8/can-grep-exclude-symlinks-838343/
function ggrep(){
  find . -type f -exec grep --color -Hn $1 {} \;
}

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

#? pycrm <PATH> -> remove all .pyc files at PATH, defaults to .
function pycrm(){
  if [ "$#" -eq 0 ]; then
    find . -name '*.pyc' -delete
  else
    find $1 -name '*.pyc' -delete
  fi
}
alias rmpyc=pycrm

