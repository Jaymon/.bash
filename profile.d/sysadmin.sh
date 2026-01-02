###############################################################################
# Git specific helpers
###############################################################################
alias gc="git commit -a -m"
alias ga="git add"
alias gr="git checkout --"
alias gs='git status'
alias gd='git diff'

alias gp='git push'
alias gpo='git push origin'
#alias gpom='git push origin master'

alias gl='git pull'
alias glo='git pull origin'
#alias glom="git pull origin master"
#alias gloms='git submodule foreach git pull origin master' # update all submodules in repo
#alias gsub=gloms

alias gr='git remote -v'
alias grem=gr
alias gre=gr

#? gbr -> return the name of the current branch
alias gbr=gitbranch

function gpob () {
  git push origin $(gbr)
}
function gpom () {
  git push origin $(gbr)
}

function glob () {
  git pull origin $(gbr)
}
function glom () {
  git pull origin $(gbr)
}

alias glog='git log --pretty=format:"%h%x09%an%x09%s"'
alias gamend="git commit --amend -m"
# git log --graph --decorate --all
alias gg="git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n'' %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' --all"

#? gf [FILENAME] -> search all the files under source control in the current folder
# http://stackoverflow.com/questions/15606955/how-can-i-make-git-show-a-list-of-the-files-that-are-being-tracked
function gf () {
  if [[ $# -eq 0 ]]; then
    git ls-tree -r $(gbr) --name-only
  else
    git ls-tree -r $(gbr) --name-only | grep "$1"
  fi

}

#? ggrep SEARCH-STRING -> Grep the git logs for the SEARCH-STRING
# http://stackoverflow.com/questions/7124914/how-to-search-a-git-repository-by-commit-message
function ggrep () {
  git log --all --grep="$1"
}

#? gb -> open up the homepage for this repo in your default browser
function gb () {
  git_http=$(git2web .)
  open "$git_http"
}

#? gdel BRANCH_NAME -> delete a branch from both local and remote
function gdel () {
  if [[ $# -gt 0 ]]; then
    echo "Deleting local branch: $1"
    git branch -d $1

    # check if a remote branch exists
    echo "Checking for remote branch: $1"
    if git ls-remote 2>&1 | grep -q "/$1"; then
      echo "Deleting remote branch: $1"
      git push origin --delete $1
    fi

  fi
}

#? gcd -> move backwards until you find the root repo directory
function g.. () {
    cd $(gitroot)
}
alias gcd=g..
alias g.=g..


###############################################################################
# other handy system utilities
###############################################################################

# retry CMD -> run CMD until you get 0 exit code
# this has to be a function because if it is own script you couldn't use aliases
# (eg, I couldn't do `retry ussh name@host` and have it work
function retry () {
  cmd="$@"
  echo $cmd
  # we use eval so aliases and functions work as expected
  eval $cmd
  while [ $? -ne 0 ]; do
    sleep 5
    eval $cmd
  done
  # https://stackoverflow.com/a/24770962/5006
}


###############################################################################
# utils
###############################################################################

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias igrep='grep -i'
# have grep ignore symlinks
# http://www.linuxquestions.org/questions/linux-newbie-8/can-grep-exclude-symlinks-838343/
function agrep(){
  find . -type f -exec grep --color -Hn $1 {} \;
}


# have less, by default, give more information on the prompt
# 2-20-12 
# http://en.wikipedia.org/wiki/Less_%28Unix%29
alias less='less -M'


#? ret -> returns the result code of the last run command
# http://stackoverflow.com/a/68397/500
alias ret='echo $?'


#? incognito -> turn history off for this shell session
# http://unix.stackexchange.com/a/10923
function incognito () {
  #set +o history
  # I don't use "set +o" anymore because it makes it so I can't even hit arrow up
  # to get the last command run, I want to still have a working command history
  # I just don't want it to be persisted when the shell exits
  export HISTFILE="/dev/null"
  echo "You are now in incognito mode for the remainder of this shell session"

  # this is set to allow other scripts and things to respect incognito mode
  export INCOGNITO=1
  export TERM_TITLE="Incognito Mode"
}
alias incog=incognito


#? envfile [FILE] -> Export all the environment variables of <FILE> (default to ./.env) into the current session
function envfile () {
    path=./.env
    if [[ -n $1 ]]; then
        path=$1
    fi

    if [[ -f "$path" ]]; then
        set -o allexport
        source "$path"
        set +o allexport
    fi
}
alias ef=envfile


###############################################################################
#
#? h <cmd|n> -> get rows in history matching cmd, or last n rows
#
# since 3-14-12 this combined with histl (created 3-10-12), this was converted to
# a bin script but bin scripts can't run history:
# 
# https://unix.stackexchange.com/questions/112354/history-stops-working-when-run-inside-bash-script
#
# So I've converted it back to an alias/function
#
###############################################################################
function h () {
    if [[ $1 == "--help" ]] || [[ $1 == "-h" ]]; then

        echo "usage: ${FUNCNAME[0]} [CMD|N]"
        echo "get rows in history matching cmd, or last N rows"
        return 0

    fi

    if [[ "$#" -eq 0 ]]; then

        echo "history | tail -n 25"
        history | tail -n 25
        #cat $history_file | tail -n 25

    elif [[ $(is_int $1; echo $?) -eq 0 ]]; then

        echo "history | tail -n $1"
        history | tail -n $1
        #cat $history_file | tail -n $1

    else

        echo "history | grep -i $1"
        history | grep -i $1
        #cat $history_file | grep -i $1

    fi

}
alias hist=h


###############################################################################
#
# Golang specific stuff
#
###############################################################################

#? govenv [NAME] -> Creates a pseudo golang virtual environment
# Golang doesn't really need a virtual environment but sometimes I don't want
# to pollute the global ~/.go directory with a bunch of crap
function govenv() {

    # we want to fail on any command failing in the script
    #set -e
    set -o pipefail
    #set -x

    version=$(go version | cut -d ' ' -f3 | cut -c 3-)
    search=".govenv${version}"
    if [ "$#" -gt 0 ]; then
        search=$1

    fi

    env=$(seek fb "$search")
    basename=$(basename "$env")

    # We didn't find a current environment so let's set it to the default
    if [[ -z "$env" ]]; then
        env=$search
        basename=$(basename $search)
    fi

    echo "Using $basename as the virtual environment name"

    gopath="$env/go"
    gocache="$env/cache"
    gobin="$gopath/bin"

    if [[ ! -d "$env" ]]; then
      mkdir -p "$env"
      mkdir -p "$gopath"
      mkdir -p "$gocache"
      #mkdir -p "$env/bin"

    fi

    # realpath has to be called after the $env path actually exists
    env=$(realpath "$env")

    # https://pkg.go.dev/cmd/go#hdr-GOPATH_environment_variable
    export GOPATH="$gopath"
    export GOCACH="$gocache"
    #export GOBIN="$env/bin"
    export PATH="$PATH:${GOPATH}/go/bin"
    # go env -w GOBIN=

    #set +x
    #set +e
    set +o pipefail

}

