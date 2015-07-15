#!/bin/bash
###############################################################################
# linux.sh
#
#`Linux specific commands
#
###############################################################################
# we only want to bother sourcing any of this if we are in MacOS
if ! uname | grep -q "Linux"; then
  return 0
fi

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

