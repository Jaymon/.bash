#!/bin/bash
###############################################################################
# bashenv.sh
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
# http://unix.stackexchange.com/a/10925
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

# I can't for the life of me figure out how to get the last command exit code in PS1, so I have to use PROMPT_COMMAND
ret_prompt='RET=$?; history -a'
if [[ -n $PROMPT_COMMAND ]]; then
  if [[ $PROMPT_COMMAND =~ ^[[:space:]]*\; ]]; then
    export PROMPT_COMMAND="$ret_prompt$PROMPT_COMMAND"
  else
    export PROMPT_COMMAND="$ret_prompt;$PROMPT_COMMAND"
  fi
else
  export PROMPT_COMMAND="$ret_prompt"
fi

# http://unix.stackexchange.com/questions/8396/bash-display-exit-status-in-prompt
# http://blog.superuser.com/2011/09/21/customizing-your-bash-command-prompt/
# https://dougbarton.us/Bash/Bash-prompts.html
# http://linuxconfig.org/bash-prompt-basics
#PS1='\[$(echo -ne $CYAN)\]\u:\[$(echo -ne $LIGHTGRAY)\]\w$(git_prompt) $(ret_prompt)\[$(echo -ne $NONE)\] '
#PS1='\[$(echo -ne $CYAN)\]\u:\[$(echo -ne $LIGHTGRAY)\]\w $(ret_prompt)\[$(echo -ne $NONE)\] '

PS1='\[$(echo -ne $CYAN)\]\u\[$(echo -ne $NONE)\]'
PS1="$PS1"':'
PS1="$PS1"'\[$(echo -ne $LIGHTGRAY)\]\w\[$(echo -ne $NONE)\] '
#PS1="$PS1"''
#PS1="$PS1"'\[$(color=$GREEN; if [[ $(git status 2> /dev/null | grep -iE "nothing\s+(to\s+commit|added\s+to\s+commit)") -gt 0 ]]; then
#color=$RED; fi; echo -ne $color)\] $(branch=$(git branch 2> /dev/null | grep -e ^* | cut -d " " -f 2; if [[ $? -gt 0 ]]; then
# echo -n " ($branch) "\[$(echo -ne $NONE)\]'

PS1="$PS1"'\[$(color=$RED; if [[ -n $(git status 2> /dev/null | grep -i nothing | grep -i commit) ]]; then color=$GREEN; if [[ -n $(git status 2> /dev/null | grep -i branch | grep -i ahead | grep -i commit) ]]; then color=$LIGHTRED; fi; fi; echo -ne $color)\]'
PS1="$PS1"'$(branch=$([[ -d .git ]] && git branch 2> /dev/null | grep -e ^* | cut -d" " -f 2); if [[ -n $branch ]]; then echo -n "($branch) "; fi;)' 
PS1="$PS1"'\[$(echo -ne $NONE)\]'

PS1="$PS1"'\[$(color=$GREEN; if [[ $RET -gt 0 ]]; then color=$RED; fi; echo -ne $color)\]\$\[$(echo -ne $NONE)\] '

# evidently, having colors in function is hard:
# http://stackoverflow.com/questions/6592077/bash-prompt-and-echoing-colors-inside-a-function
# http://welltemperedstudio.wordpress.com/2009/07/14/colorful-bash-prompts-and-line-wrapping-problem/

# If this is an xterm set the title to user@host:dir
case "$TERM" in
    xterm*|rxvt*|Eterm|aterm|kterm|gnome*)
        #PS1="$PS1"'\[\033]0;\u@\h:'"${chroot}"'${PWD}\007\]'
        PS1="$PS1"'\[\033]0;\u@'"${chroot}"'${PWD##*/}\007\]'
        ;;
    screen)
        #PS1="$PS1"'\[\033_\u@\h:'"${chroot}"'${PWD}\033\\\'
        PS1="$PS1"'\[\033_\u@'"${chroot}"'${PWD##*/}\033\\\'
;;
esac

# this will set the prompt to red if the last command failed, and green if it succeeded
# https://wiki.archlinux.org/index.php/Color_Bash_Prompt
#ORIG_PS1=$PS1
#PROMPT_COMMAND='RET=$?; history -a'
#RET_COLOR='$(if [[ $RET = 0 ]]; then echo -ne "${GREEN}"; else echo -ne "${RED}"; fi;)'
#PS1="\[${RET_COLOR}\]$ORIG_PS1\[${NONE}\]"

