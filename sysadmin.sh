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


alias vu='vagrant up'
alias vp='vagrant provision'
alias vd='vagrant destroy -f'
alias vs='vagrant suspend'
alias vr='vagrant reload'

#? cs INPUT -> search all the files in current folder
function cs() {
  grep --color=auto --exclude=*.pyc -Rin "$1" *
}
alias sc=cs

