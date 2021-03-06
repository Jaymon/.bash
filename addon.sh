#!/bin/bash
###############################################################################
# addon.sh
# 
# holds stuff related to adding features and external scripts that I might want to use
#
###############################################################################

# http://apple.stackexchange.com/questions/55875/have-git-autocomplete-branches-at-the-terminal-command-line/55886#55886
# http://code-worrier.com/blog/autocomplete-git/
#? add_git_tab_complete -> run this to add git tab auto complete to your shell
function add_git_tab_complete() {

  # git was installed with homebrew
  git_f="/usr/local/etc/bash_completion.d/git-completion.bash"
  if [[ -f $git_f ]]; then

    bash_dir=$(getBashDir)
    bash_f=$bash_dir/addon_git_completion.sh

    echo "Installing Git AutoComplete to $bash_f"
    echo -e "if [[ -f $git_f ]]; then\n  . $git_f\nfi" > $bash_f

    if [ -f $bash_f ]; then
      . $bash_f
      echo "git autocomplete Addon installed!"
    fi
  else
    addAddon "git_completion" "Git AutoComplete" "https://raw.github.com/git/git/master/contrib/completion/git-completion.bash"
  fi
}

#? add_lc -> run this to add lc command to your shell
function add_lc() {
  addAddon "listcommands" "List Commands" "https://raw.github.com/Jaymon/lc-listcommands-bash/master/listcommands.sh"
}

#? add_urlencode -> run this to add urlencode and urldecode functions to bash
# https://gist.github.com/cdown/1163649
function add_urlencode() {
  addAddon "urlencode" "Url encode/decode" "https://gist.githubusercontent.com/cdown/1163649/raw/63a5c12725f85ef90c8bf0c165f4f04ee228fccb/gistfile1.sh"
}

#? add_vagrant_helper -> adds a vagrant helper file with handy vagrant stuff
#function add_vagrant_helper() {
#  echo "Finding vagrant public key (this could take some time)..."
#  # https://groups.google.com/d/msg/vagrant-up/B5WIfDcIRtE/TuHyLIN9nVEJ
#  vagrant_pub_key=$(find / -name vagrant.pub 2>/dev/null | grep "vagrant.pub")
#  if [[ -n $vagrant_pub_key ]]; then
#    vagrant_priv_key=${vagrant_pub_key:0:-4}
#    echo "vagrant private key found at $vagrant_priv_key"
#
#    vagrant_ssh_command='ssh -A -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no vagrant@localhost -p 2222'
#
#    bash_dir=$(getBashDir)
#    bash_f=$bash_dir/addon_vagrant.sh
#
#    echo "Installing $bash_f"
#    echo "alias sshv='$vagrant_ssh_command -i $vagrant_priv_key'" > $bash_f
#
#    if [ -f $bash_f ]; then
#      . $bash_f
#      echo "vagrant addon installed!"
#    fi
#
#  else
#    echo "key was not found!!!, is vagrant installed?"
#  fi
#
#}

# TODO -- add cuts https://raw.githubusercontent.com/arielf/cuts/master/cuts
# via: https://stackoverflow.com/questions/17644000/how-to-get-second-last-field-from-a-cut-command

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


# TODO -- add an external source and bin directory, and modify addAddon to either put files to be
# sourced in external/source or external/bin and have external/bin be added to path and have external/source
# be sourced on startup.

