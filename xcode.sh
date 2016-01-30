#? xopen -> run in the directory of an XCode project to open that project in XCode
function xopen () {
  xcode_project=$(find . -type d -iname *.xcworkspace -maxdepth 1 | sed 's|./||')
  if [[ -n $xcode_project ]]; then
    open "$xcode_project"
  else
    xcode_project=$(find . -type d -iname *.xcodeproj -maxdepth 1 | sed 's|./||')
    if [[ -n $xcode_project ]]; then
      open "$xcode_project"
    else
      >&2 echo "No XCode project found to open"
      return 1
    fi
  fi
}

