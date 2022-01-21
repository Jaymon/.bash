
# build a prefix search path from an easier path, so fo/ba would become fo*/ba*$
function convert_to_prefix_search_path() {
  # let's build a prefix search string that find can use

  # eg, p/d/file -> p* / d* / file
  # ds would become [p*, d*], f would become file
  #directories="^.*"
  directories=".*"
  IFS=$'/'; ds=( $1 ); unset IFS
  dlast=${ds[-1]}
  ds=( ${ds[@]:0:${#ds[@]}-1} )
  for d in ${ds[@]}; do
    directories+="${d}[^/]*/"
  done
  directories+="${dlast}[^/]*"
  echo $directories
}

