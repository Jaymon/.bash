#!/bin/bash
###############################################################################
# util.sh
#
# functions/aliases that help me do things easier
#
# Things I always forget:
#   [[ ]] and [ ] syntax:
#     http://stackoverflow.com/questions/669452/is-preferable-over-in-bash-scripts
#     http://mywiki.wooledge.org/BashFAQ/031
#
# The IFS variable: http://en.wikipedia.org/wiki/Internal_field_separator
#
#
#
###############################################################################

# this is a helper function to allow easy testing of an int
# if you want to use this in an if: [ $(is_int <VALUE>; echo $?) -eq 0 ]
# or the simpler: [ $(is_int <value>) -eq 0 ]
# return 0 if input is an int, not zero otherwise
function is_int(){

  #set -x
  # canary, only one value is allowed
  if [ $# -gt 1 ]; then
    echo "1"
    return 1;
  fi

  # this will set the $? as either 0 or 1
  echo "$1" | grep -E "^[[:digit:]]+$" > /dev/null 2>&1
  retcode=$?
  echo $retcode
  #set +x
  return $retcode

}

#? tolower <VAR> ... -> change all passed in vars to lowercase
function tolower(){
  echo $@ | tr '[:upper:]' '[:lower:]'
}

# http://stackoverflow.com/questions/2264428/converting-string-to-lower-case-in-bash-shell-scripting
#? toupper <VAR> ... -> change all passed in vars to uppercase
function toupper(){
  echo $@ | tr '[:lower:]' '[:upper:]'
}

# http://stackoverflow.com/questions/394230/detect-the-os-from-a-bash-script
# is_os <name> -> true if name and os match
function is_os(){

  # canary, only one value is allowed
  if [ $# -gt 1 ]; then 
    echo "1"
    return 1;
  fi
  
  if [ "$(tolower $(uname))" == "$(tolower $1)" ]; then 
    echo "0"
    return 0;
  else
    echo "1"
    return 1;
  fi

}

#? get_tmp -> get the system appropriate temp directory
function get_tmp(){
  tmp_dir="/tmp/" 

  if [ "$TMPDIR" != "" ]; then
    tmp_dir="$TMPDIR"
  elif [ "$TMP" != "" ]; then
    tmp_dir="$TMP"
  elif [ "$TEMP" != "" ]; then
    tmp_dir="$TEMP"
  fi

  # make sure last char is a /
  # http://www.unix.com/shell-programming-scripting/14462-testing-last-character-string.html
  if [[ $tmp_dir != */ ]]; then
    tmp_dir="$tmp_dir"/
  fi

  # http://stackoverflow.com/questions/12283463/in-bash-how-do-i-join-n-parameters-together-as-a-string
  if [ $# -gt 0 ]; then
    IFS="/"
    tmp_dir="$tmp_dir""$*"
    unset IFS
  fi

  echo "$tmp_dir"
}

#? myhost -> return the hostname of the computer
# http://apple.stackexchange.com/a/53042
# http://superuser.com/a/430209
function myhost(){
  if [ $(is_os Darwin) -eq 0 ]; then
    scutil --get LocalHostName
  else
    echo $HOSTNAME
  fi
}

#? version -> return version information
#alias version='cat /etc/lsb-release'
function version(){
  if [ $(is_os Darwin) -eq 0 ]; then
    # http://apple.wikia.com/wiki/List_of_Mac_OS_versions
    version=$(sw_vers -productVersion)
    if [[ "$version" < "10.4" ]]; then
      echo "Panther"
    elif [[ "$version" < "10.5" ]]; then
      echo "Tiger"
    elif [[ "$version" < "10.6" ]]; then
      echo "Leopard"
    elif [[ "$version" < "10.7" ]]; then
      echo "Snow Leopard"
    elif [[ "$version" < "10.8" ]]; then
      echo "Lion"
    elif [[ "$version" < "10.9" ]]; then
      echo "Mountain Lion"
    elif [[ "$version" < "11" ]]; then
      echo "Mavericks"
    elif [[ "$version" < "12" ]]; then
      echo "Yosemite"
    fi
    sw_vers
    uname -a
    echo "type system_profiler for even more information"

  else
    info=$(cat /etc/lsb-release)
    is_ubuntu=$(echo $info | grep -i ubuntu &>/dev/null; echo $?)

    if [[ $is_ubuntu -eq 0 ]]; then
      # http://en.wikipedia.org/wiki/List_of_Ubuntu_releases
      # http://stackoverflow.com/questions/1494178/how-to-define-hash-tables-in-bash
      declare -A ubuntus=( ["13.10"]="Saucy Salamander", ["13.04"]="Raring Ringtail", ["12.10"]="Quantal Quetzal", ["12.04"]="Precise Pangolin", ["11.10"]="Oneiric Ocelot", ["11.04"]="Natty narwhal", ["10.10"]="Maverick Meerkat", ["10.04"]="Lucid Lynx" )
      for key in ${!ubuntus[@]}; do
        if [[ $(echo $info | grep "$key" &>/dev/null; echo $?) -eq 0 ]]; then
          echo ${ubuntus[$key]}
          break
        fi

      done

    fi

    echo "$info"
  fi
}
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

  if [ $(is_os Darwin) -eq 0 ]; then
    system_profiler SPHardwareDataType
  else
    num_cpus=$(grep "physical id" /proc/cpuinfo | sort -u | wc -l)
    if [ $num_cpus -eq 0 ]; then num_cpus=1; fi

    num_cores=$(grep -c ^processor /proc/cpuinfo)
    
    echo "number of cpus: $num_cpus"
    echo "number of cores: $num_cores"
    echo "number of cores per cpu: $(($num_cores / $num_cpus))"
  fi

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
  ps -A -ostat,ppid,pid,args | grep -e '^[Zz]'
}

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
      
      if [ $(is_int $2) -eq 0 ]; then
      
        cnt=$2
      
      fi

    
    else
    
      if [ $(is_int) -eq 0 ]; then
    
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

#? whoip <IPADDR> -> print information about the ip address
# http://stackoverflow.com/questions/13222564/what-information-can-i-get-from-an-ip-address
function whoip(){
  curl ipinfo.io/$1
}
alias wip=whoip

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
	ps -eo pid,etime,args | grep -v "grep" | grep $1
}

#? murder <NAME> -> run every process that matches NAME through sudo kill -9
# 2-20-12
# http://stackoverflow.com/questions/262597/how-to-kill-a-linux-process-by-stime-dangling-svnserve-processes
function murder(){
  echo -e "${RED}These will be killed:${NONE}"
  ps -eo pid,args | grep -v "grep" | grep $1
  # first 3 commands find the right running processes
  # sed - gets rid of any whitespace from the front of the command
  # cut - gets the first column (in this case, the pid)
  # xargs - runs each found pid through the kill command
  ps -eo pid,args | grep -v "grep" | grep "$1" | sed "s/^ *//" | cut -d' ' -f1 | xargs -i sudo kill -9 "{}"
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

  elif [ $(is_int $1) -eq 0 ]; then
  
    history | tail -n $1
  
  else

    history | grep $1  
  
  fi
  
  # set +x

}
alias h=hist

# make init.d scripts more supervisor like
#? irestart <NAME> -> init.d restart <NAME>
function irestart(){
  idid restart $1
}
#? istart <NAME> -> init.d start <NAME>
function istart(){
  idid start $1
}
#? istop <NAME> -> init.d stop <NAME>
function istop(){
  idid stop $1
}
function idid(){
  echo "/etc/init.d/$2 $1"
  sudo /etc/init.d/$2 $1
}

#? bd <NUM> -> how many directories to move back (eg, bd 2 = cd ../..)
function bd() {
  back_dir=""
  if [[ $# -eq 0 ]]; then
    back_dir="../"
  else
    for (( i=0; i<$1; i+=1 )); do 
      back_dir=$back_dir"../"
    done
  fi

  echo "cd $back_dir"
  pushd $back_dir
}
#? .. -> cd ..
alias ..='bd' 
#? ... -> cd ../..
alias ...='bd 2'
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

#? dsrm <PATH> -> remove all .DS_Store files at PATH, defaults to .
function dsrm(){
  if [ "$#" -eq 0 ]; then
    find . -name '.DS_Store' -delete
  else
    find $1 -name '.DS_Store' -delete
  fi
}
alias rmds=dsrm

#? envglobal -> print all exported global environment variables
function envglobal(){
  fn=$(get_tmp exportglobal.sh)
  if [ "$#" -eq 0 ]; then
    fn_exports=""
    if [[ -f $fn ]]; then
      fn_exports=$(cat "$fn")
    fi
    if [[ -n $fn_exports ]]; then
      echo -e "$fn_exports"
    fi
  else
    echo "$fn"
  fi
}

#? exportglobal KEY=VAL -> exports the env variable to current and all new shells
function exportglobal(){
  if [ "$#" -eq 0 ]; then
    echo "HELP: exportglobal NAME=val"
    return 1
  fi

  fn_exports=$(envglobal)

  # http://stackoverflow.com/questions/255898/how-to-iterate-over-arguments-in-bash-script
  for var in "$@"; do
    echo "export $var"
    # clear the var from the global export file
    # http://stackoverflow.com/questions/2680274/string-manipulation-in-bash-removing-leading-section
    # http://stackoverflow.com/questions/10638538/split-string-with-bash-with-symbol
    fn_exports=$(echo "$fn_exports" | grep -v "${var%%=*}")
    export "$var"
    # http://stackoverflow.com/questions/9139401/trying-to-embed-newline-in-a-variable-in-bash
    fn_exports+="\nexport ${var%%=*}=\"${var#*=}\""
  done

  echo -e "$fn_exports" > "$fn"

}

#? unsetglobal KEY=VAL -> unset global exported variables in current and all new shells
function unsetglobal(){
  if [ "$#" -eq 0 ]; then
    echo "HELP: unsetglobal NAME=val"
    return 1
  fi

  fn_exports=$(envglobal)

  # http://stackoverflow.com/questions/255898/how-to-iterate-over-arguments-in-bash-script
  for var in "$@"; do
    echo "unset $var"
    # clear the var from the global export file
    fn_exports=$(echo "$fn_exports" | grep -v "$var")
    unset "$var"
  done

  # re-add non unset vars back to the file
  echo -e "$fn_exports" > "$fn"

}

#? loadenv -> will load the global exported environment vars
function loadenv(){
  fn=$(envglobal file)
  if [[ -f $fn ]]; then
    . "$fn"
  fi
}
# actually do importing of environment variables if the exportglobal file exists on source of this file
loadenv

### NOTE -- none of these seam to work, but pout.json does
# ? ppj -> pretty print json to be used with pipe: cat json.txt|ppj
# http://stackoverflow.com/questions/352098/how-to-pretty-print-json-from-the-command-line
jsonpp='python -mjson.tool'
ppj=jsonpp
ppjson=jsonpp

#? far FILE PROG -> run PROG FILE or prompt for what FILE if more than one FILE found in subdirs
# find and run, ie, find FILE and run PROG FILE
function far() {

  #set -x

  if [[ $# -eq 0 ]]; then
    echo "far - find FILE and run PROG FILE"
    echo "usage: far FILE PROG"
    return 0
  fi

  c=""
  # the first thing we check for is the base case: far /path/to/real/file cmd
  if [[ -f $1 ]]; then
    # http://stackoverflow.com/questions/2701400/remove-first-element-from-in-bash
    c="${@:2} $1"
  else
    # we will want to prefix match the file path
    # eg, p/d/file -> p* / d* / file
    # ds would become [p*, d*], f would become file
    IFS=$'/'; ds=( $1 ); unset IFS
    f=${ds[-1]}
    ds=( ${ds[@]:0:${#ds[@]}-1} )
    base_dirs=( $PWD )

    # base_dirs would eventually end up with just $PWD/p*/d* folders
    # it does this by constantly replacing base_dirs with the next level of folders
    for d in ${ds[@]}; do

      new_base_dirs=""

      for base_dir in ${base_dirs[@]}; do
        # http://askubuntu.com/questions/266179/how-to-exclude-ignore-hidden-files-and-directories-in-a-wildcard-embedded-find
        new_ds=$(find $base_dir -not -path "*/\.*" -type d -mindepth 1 -iname "$d*")
        new_base_dirs="$new_base_dirs""$new_ds"
      done

      IFS=$'\n'; base_dirs=( $new_base_dirs ); unset IFS

    done

    #printf ${base_dirs[@]}

    # now find all the files that match the final value using all the found base dirs
    fs=""
    for base_dir in ${base_dirs[@]}; do
      new_fs=$(find $base_dir -not -path "*/\.*" -type f -iname "$f*" | grep -ive "pyc$")
      fs="$fs""$new_fs"
    done

    fs_count=$(echo "$fs" | wc -l)
    #echo $fs_count

    if [[ $fs_count -eq 1 ]]; then
      c="${@:2} $fs"

    else
      # split the string into an array
      IFS=$'\n'; fs=( $fs ); unset IFS

      # print out all the found files to the user and let them choose which one to open
      # http://stackoverflow.com/a/10586169
      for index in "${!fs[@]}"; do
        i=$(expr $index + 1)
        echo -e "[$i]\t${fs[index]}"
      done
      echo -e "[n]\tNone"
      # http://stackoverflow.com/questions/226703/how-do-i-prompt-for-input-in-a-linux-shell-script
      read -p "File? " fn
      if [[ ! $fn =~ [nN] ]]; then
        file_index=$(expr $fn - 1)
        c="${@:2} ${fs[file_index]}"
      fi
    
    fi

  fi

  # actually run the command if something was found
  if [[ ! -z $c ]]; then
    echo $c
    $c

  fi
  #set +x
}

#? explain <cmd> -> explain cmd, great with explain !!
function explain() {
  # https://news.ycombinator.com/item?id=6300735
  cmd="$(cut -d ' ' -f 1 <<< "$@" )";
  args="$(cut -d ' ' -f 2- <<< "$@" )";
  url="http://explainshell.com/explain/$cmd?args=$args"
  explanation="$(curl -s $url | grep '<pre' | sed -E 's/<\/?[a-z]+(\ [a-z]+=\"[a-z0-9]+\")*>//g' | sed -E 's/^\ +//g')"
  echo "$explanation"	
}

#? cronenv -> convert the shell to an environment similar to what a cron script would run in
# http://stackoverflow.com/a/2546509/5006
function cronenv() {
  cron_env+="HOME=$HOME\n"
  cron_env+="LOGNAME=$LOGNAME\n"
  cron_env+="PATH=/usr/bin:/bin\n"
  cron_env+="SHELL=/bin/sh\n"
  cron_env+="PWD=$PWD\n"

  if [[ ! -z $LC_ALL ]]; then
    cron_env+="LC_ALL=$LC_ALL\n"
  fi

  env - `echo -e $cron_env` /bin/sh
}

#? touched [DIR] [COUNT] -> print the last COUNT touched files in DIR
# http://stackoverflow.com/a/9052878/5006
# NOTE -- might have problem on Linux, if so then you can OS sniff and use the given
# stackoverflow link to run the Linux version instead
function touched() {
  basedir="."
  count=10
  if [[ $# -eq 1 ]]; then
    basedir=$1
  elif [ $# -eq 2 ]; then
    basedir=$1
    count=$2
  fi

  find $basedir -type f -print0 | xargs -0 stat -f "%m %N" | sort -rn | head -$count | cut -f2- -d" "
}

#? pml <path> -> convert a binary plist to an xml plist you can read
# http://initwithfunk.com/blog/2013/05/31/breaking-bad-with-dtrace/
alias pml='plutil -convert xml1'
alias plistxml=pml

#? pcat <path> -> cat plist file, this will convert to xml first
function pcat () {
  pml "$1"
  cat "$1"
}

#? flushdns -> flushes the dns cache
function flushdns() {
  # todo: make this better
  # http://coolestguidesontheplanet.com/clear-the-local-dns-cache-in-osx/
  if [ $(is_os Darwin) -eq 0 ]; then
    # this is 10.10 only
    sudo discoveryutil udnsflushcaches
  else
    if [[ -f /etc/init.d/named ]]; then
      sudo /etc/init.d/named restart
    else
      sudo /etc/init.d/nscd restart
    fi
  fi

}


