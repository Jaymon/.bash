
#alias sshv='ssh -A -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no vagrant@localhost -p 2222 -i /Applications/Vagrant/embedded/gems/gems/vagrant-1.2.1/keys/vagrant'

function sshv () {
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
}

alias sshav='ssh -A -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no vagrant@localhost -p 2222'
