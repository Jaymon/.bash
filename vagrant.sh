###############################################################################
# Vagrant specific helpers
###############################################################################

#alias sshv='ssh -A -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no vagrant@localhost -p 2222 -i /Applications/Vagrant/embedded/gems/gems/vagrant-1.2.1/keys/vagrant'

function sshv () {

  if [[ -d "./.vagrant" ]]; then

    if [[ -d "./.vagrant/machines/default/virtualbox" ]]; then

      # all of this is still faster than running vagrant ssh :(
      box_id=$(cat ./.vagrant/machines/default/virtualbox/id)
      port=$(VboxManage showvminfo $box_id | grep "name = ssh" | grep "host port = \d\+" --only-matching | cut -d" " -f4)
      private_key=./.vagrant/machines/default/virtualbox/private_key
      ssh -A -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no vagrant@localhost -p $port -i "$private_key"

    else
      # $(find .vagrant -type f -name "private_key")
      vagrant ssh

    fi

  else

    status=$(vagrant global-status | tail -n +3)

    # split the string into an array
    IFS=$'\n'; status=( $status ); unset IFS
    for index in "${!status[@]}"; do
      line=$(echo ${status[index]} | sed -e 's/[[:space:]]*$//')
      if [[ -z $line ]]; then
        break
      else
        #echo $line
        box_id=$(echo $line | cut -d ' ' -f 1)
        box_status=$(echo $line | cut -d ' ' -f 4)
        box_dir=$(echo $line | cut -d ' ' -f 5)
        #echo $box_id
        #echo $box_status
        if [[ $box_status == "running" ]]; then
          pushd "$box_dir" > /dev/null
          vagrant ssh
          break
        fi

      fi
    done

  fi
}

alias sshav='ssh -A -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no vagrant@localhost -p 2222'

# just speeds up common vagrant operations
alias vu='vagrant up'
alias vp='vagrant provision'
alias vd='vagrant destroy -f'
alias vs='vagrant suspend'
alias vr='vagrant reload'


