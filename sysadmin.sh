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
alias gpom='git push origin master'

alias gr='git remote -v'
alias grem=gr
alias gre=gr

#? gbr -> return the name of the current branch
alias gbr='git branch 2> /dev/null | grep -e ^* | cut -d" " -f 2'

function gpob () {
  git push origin $(gbr)
}

alias gl='git pull'
alias glo='git pull origin'
alias glom="git pull origin master"

function glob () {
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
# Misc helpers
###############################################################################

#? freespace -> how much free space is left on the hard drive
function freespace () {
  df -h | head -2 | tail -1 | tr -s ' ' | cut -d' ' -f4
}
alias fs=freespace


#? dfs -> Directory used space, the file size of folders and files ordered by biggest
# https://stackoverflow.com/a/14749369/5006
function dfs () {
    du -a -h | sort -hr
}
alias dus=dfs
alias ds=dfs


#? cs INPUT -> search all the files in current folder
function cs () {
  grep --color=auto --exclude=*.pyc -Rin "$1" *
}
alias sc=cs
alias sf=cs


#? ussh -> unsecured ssh, this is handy for AWS and other boxes where the box's host key can change
alias ussh='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'

#? uscp -> unsecured scp, this is handy for AWS and other boxes where the box's host key can change
alias uscp='scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'

#? pssh user@host -P PASSWORD -> adds -P to pass in a password, which is handy when you are provisioning
# lots of boxes that don't yet have keys on them
function pssh () {

  # http://stackoverflow.com/questions/4780893/use-expect-in-bash-script-to-provide-password-to-ssh-command
  # https://www.pantz.org/software/expect/expect_examples_and_tips.html
  # http://stackoverflow.com/questions/16928004/how-to-enter-ssh-password-using-bash?lq=1
  # http://stackoverflow.com/questions/9075478/is-there-a-way-to-input-automatically-when-running-a-shell

  args=("$@")
  ssh_password=""
  ssh_args=""
  ssh_host=""

  #echo "count $#"

  i=0
  while [ $i -lt $# ]; do
    val=${args[$i]}
    #echo "args[$i]: $val"
    if [[ $val == "-P" ]]; then
      ((i++))
      ssh_password=${args[$i]}

    elif [[ $val =~ ^[A-Za-z0-9_]*@[A-Za-z0-9_.-]*$ ]]; then
      ssh_host=$val

    else
      ssh_args+=" $val"

    fi
    ((i++))
  done

  echo "ssh_host $ssh_host"
  echo "ssh_password $ssh_password"
  echo "ssh_args $ssh_args"

  ssh_script=$TMPDIR/pssh.sh
  echo -e "#!/usr/bin/expect" > $ssh_script
  echo -e "" >> $ssh_script
  echo -e "spawn ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $ssh_args $ssh_host" >> $ssh_script
  echo -e "expect \"*assword:\"" >> $ssh_script
  echo -e "send -- \"$ssh_password\\r\"" >> $ssh_script
  echo -e "interact" >> $ssh_script
  chmod 700 $ssh_script

  $ssh_script

  # let's not leave the script lying around since it does contain a password
  rm $ssh_script

}


# https://www.digitalocean.com/community/tutorials/how-to-use-ssh-keys-with-digitalocean-droplets
#? flussh IP-ADDRESS -> flush the ip address from the hosts file
flushssh='ssh-keygen -R'
flussh=flushssh
sshforget=flushssh


###############################################################################
# So you use vim for everything?
###############################################################################

# NOTE: I moved these from my .bash_profile, I'm not sure how good of an idea that was
# do vim specific things if vim exists
if which vim > /dev/null 2>&1; then
  # these will open any editor in gvim
  #export EDITOR="${vim} -g --remote-tab-silent"
  #export GIT_EDITOR="${vim} -g -f"
  # these will open the editor in console vim
  export EDITOR="vim --remote-tab-silent"
  export GIT_EDITOR="vim"

  # bash starts in insert mode, but when you hit escape you can then move around the command line using vi bindings
  # moved this to inputrc
  #set -o vi

fi


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


