#!/bin/bash
###############################################################################
# env.sh
#
# sets the environment like the prompt and certain bash options
###############################################################################

# http://old.nabble.com/show-all-if-ambiguous-broken--td1613156.html
# http://stackoverflow.com/a/68449/5006
# http://liquidat.wordpress.com/2008/08/20/short-tip-bash-tab-completion-with-one-tab/
# http://superuser.com/questions/271626/
bind "set completion-ignore-case on"
bind "set show-all-if-ambiguous on"
bind "set mark-symlinked-directories on"
bind "set show-all-if-unmodified on"

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# don't ever obliterate the history file
# http://briancarper.net/blog/248/ via: http://news.ycombinator.com/item?id=3755276
shopt -s histappend

# this will set the prompt to red if the last command failed, and green if it succeeded
# https://wiki.archlinux.org/index.php/Color_Bash_Prompt
ORIG_PS1=$PS1
PROMPT_COMMAND='RET=$?; history -a'
RET_COLOR='$(if [[ $RET = 0 ]]; then echo -ne "${GREEN}"; else echo -ne "${RED}"; fi;)'
PS1="\[${RET_COLOR}\]$ORIG_PS1\[${NONE}\]"

