#!/bin/bash
###############################################################################
# addon.sh
# 
# holds stuff related to adding features and external scripts that I might want to use
#
###############################################################################

# http://apple.stackexchange.com/questions/55875/have-git-autocomplete-branches-at-the-terminal-command-line/55886#55886
# http://code-worrier.com/blog/autocomplete-git/
#? addGitTabComplete -> run this to add git tab auto complete to your shell
function addGitTabComplete(){
  addAddon "git_completion" "Git AutoComplete" "https://raw.github.com/git/git/master/contrib/completion/git-completion.bash"
}

#? addLc -> run this to add lc command to your shell
function addLc(){
  addAddon "listcommands" "List Commands" "https://raw.github.com/Jaymon/lc-listcommands-bash/master/listcommands.sh"
}

function addAddon() {
  if [[ $# -ne 3 ]]; then
    echo "addAddon FILENAME NAME URL"
    return 1
  fi

  bash_dir=$(getBashDir)
  git_f=$bash_dir/addon_$1.sh
  echo "Installing $2 $git_f"
  curl $3 -o $git_f
  if [[ $? -eq 0 ]]; then
    if [ -f $git_f ]; then
      . $git_f
      echo "$2 installed!"
    fi
  fi

}
