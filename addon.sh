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
  bash_dir=$(getBashDir)
  git_f=$bash_dir/addon_git_completion.sh
  echo "Installing Git autocomplete to $git_f"
  curl https://raw.github.com/git/git/master/contrib/completion/git-completion.bash -o $git_f
  if [[ $? -eq 0 ]]; then
    if [ -f $git_f ]; then
      . $git_f
      echo "Git autocomplete installed!"
    fi
  fi
}

