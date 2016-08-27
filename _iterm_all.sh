
#SH_INCLUDE_DIR="${BASH_SOURCE%/*}"
#if [[ ! -d "$SH_INCLUDE_DIR" ]]; then SH_INCLUDE_DIR="$PWD"; fi
#. "$SH_INCLUDE_DIR/_internal.sh"

. ~/.bash/_internal.sh

function pwds() {

  pwd_path="${TMPDIR}pwds.txt"
  echo "" > "$pwd_path"
  # TODO -- check TERM_PROGRAM=iTerm.app

  #/usr/bin/osascript <<EOT
  #tell application "iTerm"
  #  set w to (current terminal)
  #  if w is not (current terminal) then
  #    tell w
  #      repeat with s in sessions
  #        tell s
  #          write text "pwd >> \"${pwd_path}\""
  #        end tell
  #      end repeat
  #    end tell
  #  end if
  #end tell
  #EOT


  /usr/bin/osascript <<EOT
tell application "iTerm"
  set w2 to (current terminal)
  set id2 to the name of the first session of w2
  repeat with w in terminals
    if w is not w2 then
      tell w
        repeat with s in sessions
          set id1 to the name of s
          if id1 is not id2 then
            tell s
              write text "pwd >> \"${pwd_path}\""
            end tell
          end if
        end repeat
      end tell
    end if
  end repeat
end tell
EOT

  #cat $pwd_path

  #userprompt "$(cat $pwd_path)"

  IFS=$'\n'; ds=( $(cat $pwd_path) ); unset IFS
  userprompt "${ds[@]}"

  IFS=$'\n'; ds=( $userprompt_chosen ); unset IFS
  for d in ${ds[@]}; do
    #echo $d
    #eval "pushd $d"
    pushd $d
    break
  done

}
