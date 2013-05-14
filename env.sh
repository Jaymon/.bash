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

#PS1='\u:\w \$ '
# http://niczsoft.com/2010/05/my-git-prompt/
# http://stackoverflow.com/questions/4133904/ps1-line-with-git-current-branch-and-colors
# https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh
# http://code-worrier.com/blog/git-branch-in-bash-prompt/
# http://stackoverflow.com/questions/4133904/ps1-line-with-git-current-branch-and-colors
# http://tldp.org/LDP/Bash-Beginners-Guide/html/sect_03_01.html
# http://ss64.com/bash/syntax-prompt.html
function git_prompt() {
  if [[ -d .git ]]; then
    branch=$(git branch 2> /dev/null | grep -e ^* | cut -d ' ' -f 2)
    color=""
    git_changes=$(git status 2> /dev/null | grep -iE "nothing\s+(to\s+commit|added\s+to\s+commit)")
    if [[ $? -gt 0 ]]; then
      color=$RED
    else
      color=$GREEN
    fi

    echo -ne " $color($branch)"
  else
    echo -ne ""
  fi
}

function ret_prompt() {
  color=$GREEN
  if [[ $RET -gt 0 ]]; then
  #if [[ $1 -gt 0 ]]; then
    color=$RED
  fi;

  echo -ne "$color\$"
}

# I can't for the life of me figure out how to get the last command exit code in PS1, so I have to use PROMPT_COMMAND
PROMPT_COMMAND='RET=$?; history -a'


# http://unix.stackexchange.com/questions/8396/bash-display-exit-status-in-prompt
# http://blog.superuser.com/2011/09/21/customizing-your-bash-command-prompt/
# https://dougbarton.us/Bash/Bash-prompts.html
# http://linuxconfig.org/bash-prompt-basics
PS1='\[$(echo -ne $CYAN)\]\u:\[$(echo -ne $LIGHTGRAY)\]\w$(git_prompt) $(ret_prompt)\[$(echo -ne $NONE)\] '

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    #PS1="\[\e]0;\u@\h: \w\a\]$PS1"
    PS1="\[\e]0;\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# this will set the prompt to red if the last command failed, and green if it succeeded
# https://wiki.archlinux.org/index.php/Color_Bash_Prompt
#ORIG_PS1=$PS1
#PROMPT_COMMAND='RET=$?; history -a'
#RET_COLOR='$(if [[ $RET = 0 ]]; then echo -ne "${GREEN}"; else echo -ne "${RED}"; fi;)'
#PS1="\[${RET_COLOR}\]$ORIG_PS1\[${NONE}\]"

