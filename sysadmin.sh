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
alias gb='git branch 2> /dev/null | grep -e ^* | cut -d" " -f 2'

function gpob () {
  git push origin $(gb)
}

alias gl='git pull'
alias glo='git pull origin'
alias glom="git pull origin master"

function glob () {
  git pull origin $(gb)
}

alias glog='git log --pretty=format:"%h%x09%an%x09%s"'
alias gamend="git commit --amend -m"
# git log --graph --decorate --all
alias gg="git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n'' %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' --all"

#? gf [FILENAME] -> search all the files under source control in the current folder
# http://stackoverflow.com/questions/15606955/how-can-i-make-git-show-a-list-of-the-files-that-are-being-tracked
function gf () {
  if [[ $# -eq 0 ]]; then
    git ls-tree -r $(gb) --name-only
  else
    git ls-tree -r $(gb) --name-only | grep "$1"
  fi

}


###############################################################################
# Vagrant specific helpers
###############################################################################

alias vu='vagrant up'
alias vp='vagrant provision'
alias vd='vagrant destroy -f'
alias vs='vagrant suspend'
alias vr='vagrant reload'


###############################################################################
# Misc helpers
###############################################################################

#? cs INPUT -> search all the files in current folder
function cs() {
  grep --color=auto --exclude=*.pyc -Rin "$1" *
}
alias sc=cs
alias sf=cs


#? ussh -> unsecured ssh, this is handy for AWS and other boxes where the box's host key can change
alias ussh='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'

#? uscp -> unsecured scp, this is handy for AWS and other boxes where the box's host key can change
alias uscp='scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'

