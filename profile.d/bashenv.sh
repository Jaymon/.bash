#!/bin/bash
###############################################################################
# bashenv.sh
#
# sets the environment like the prompt and certain bash options
###############################################################################

# this file should only be ran in login/interactive shells
[ -z "$PS1" ] && return


# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize


# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
# http://unix.stackexchange.com/a/10925
HISTCONTROL=ignoredups:ignorespace

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# don't ever obliterate the history file
# http://briancarper.net/blog/248/ via: http://news.ycombinator.com/item?id=3755276
shopt -s histappend


# https://www.quora.com/What-are-some-time-saving-tips-that-every-Linux-user-should-know/answer/Chen-Bin-3
# The trick is I seldom re-use the old command without editing. So insert below line into ~/.bashrc:
# then !9899 will insert the command into shell instead of execute it.
# shopt -s histverify


# This command auto-corrects when you use cd 
# https://www.quora.com/What-are-some-time-saving-tips-that-every-Linux-user-should-know/answer/Vikneshwar-Vicky
shopt -s cdspell


# If set, a command name that is the name of a directory is executed as if it were
# the argument to the cd command. This option is only used by interactive shells.
# https://unix.stackexchange.com/a/232407/118750
shopt -s autocd


# Only show the last 3 directories in the bash \w prompt
# https://superuser.com/a/1067793/164279
#   If set to a number greater than zero, the value is used as the number of
#   trailing directory components to retain when expanding the \w and \W prompt
#   string escapes (see PROMPTING below). Characters removed are replaced with
#   an ellipsis
PROMPT_DIRTRIM=3


###############################################################################
# colors
###############################################################################
# use them in echo like this: echo -e "${RED}test${NONE}"
# in Mac, you can't use these, you have to put in the full \e...
YELLOW='\033[0;33m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
RED='\033[0;31m'
LIGHTRED="\033[1;31m"
GREEN="\033[0;32m"
BLACK='\033[0;30m'
BLUE='\033[0;34m'
LIGHTGRAY="\033[37m"
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


###############################################################################
# PROMPT
###############################################################################
# internal function meant to be used in the PROMPT_COMMAND
function set_bashenv() {
  if [[ -z $TERM_TITLE ]]; then
    # http://superuser.com/questions/419775/with-bash-iterm2-how-to-name-tabs
    # https://gist.github.com/phette23/5270658
    # http://hints.macworld.com/article.php?story=20031015173932306
    echo -ne "\033]0;"$USER@${PWD##*/}"\007"
    #echo -ne "\033]0;"$*"\007"
  else
    echo -ne "\033]0;"$TERM_TITLE"\007"
  fi
  if [[ -z $TERM ]]; then
    export TERM=xterm-256color
  fi
}

# I can't for the life of me figure out how to get the last command exit code in PS1, so I have to use PROMPT_COMMAND
#ret_prompt='RET=$?; history -a;set_bashenv'
ret_prompt='RET=$?; set_bashenv'
if [[ -n $PROMPT_COMMAND ]]; then
  if [[ $PROMPT_COMMAND =~ ^[[:space:]]*\; ]]; then
    export PROMPT_COMMAND="$ret_prompt$PROMPT_COMMAND"
  else
    export PROMPT_COMMAND="$ret_prompt;$PROMPT_COMMAND"
  fi
else
  export PROMPT_COMMAND="$ret_prompt"
fi


#trap 'history -a' EXIT


# http://niczsoft.com/2010/05/my-git-prompt/
# http://stackoverflow.com/questions/4133904/ps1-line-with-git-current-branch-and-colors
# https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh
# http://code-worrier.com/blog/git-branch-in-bash-prompt/
# http://stackoverflow.com/questions/4133904/ps1-line-with-git-current-branch-and-colors
# http://tldp.org/LDP/Bash-Beginners-Guide/html/sect_03_01.html
# http://ss64.com/bash/syntax-prompt.html

# http://unix.stackexchange.com/questions/8396/bash-display-exit-status-in-prompt
# http://blog.superuser.com/2011/09/21/customizing-your-bash-command-prompt/
# https://dougbarton.us/Bash/Bash-prompts.html
# http://linuxconfig.org/bash-prompt-basics

# evidently, having colors in function is hard:
# http://stackoverflow.com/questions/6592077/bash-prompt-and-echoing-colors-inside-a-function
# http://welltemperedstudio.wordpress.com/2009/07/14/colorful-bash-prompts-and-line-wrapping-problem/

# print user
PS1='\[$(echo -ne $CYAN)\]\u\[$(echo -ne $NONE)\]'

PS1="$PS1"':'

# print the current directory path
PS1="$PS1"'\[$(echo -ne $LIGHTGRAY)\]\w\[$(echo -ne $NONE)\] '

# The next block handles displaying a git status if we are in a directory with a GIT repo

# display green if there aren't any changes in the current repo
PS1="$PS1"'\[$(if [[ -n $(git status 2> /dev/null | grep -i nothing | grep -i commit) ]]; then color=$GREEN;'
# display light red if there are commits not sent to remote
PS1="$PS1"'elif [[ -n $(git status 2> /dev/null | grep -i branch | grep -i ahead | grep -i commit) ]]; then color=$LIGHTRED;'
# display red if there are uncommited changes
PS1="$PS1"'else color=$RED; fi;'
# actually print out the color
PS1="$PS1"'echo -ne $color)\]'
# print the branch name
PS1="$PS1"'$(branch=$([[ -d .git ]] && git branch 2> /dev/null | grep -e ^* | cut -d" " -f 2); if [[ -n $branch ]]; then echo -n "($branch) "; fi;)' 
# restore color back to default
PS1="$PS1"'\[$(echo -ne $NONE)\]'

# print green if last command was successful (return code was 0), red if it failed (return code > 0)
PS1="$PS1"'\[$(color=$GREEN; if [[ $RET -gt 0 ]]; then color=$RED; fi; echo -ne $color)\]\$\[$(echo -ne $NONE)\] '

