#!/bin/bash
###############################################################################
# env.sh
#
# handy methods for dealing with environment specific things, for the actual
# bash environment configuration (how I like my shell setup), look at bashenv.sh
###############################################################################

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

