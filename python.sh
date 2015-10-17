#!/bin/bash

#? pyload -> upload the python project to pypi
function pyload() {
  pandoc --from=markdown --to=rst --output=README.rst README.md
  python setup.py sdist upload
  # todo -- get rid of all the left over folders?
}
alias pyup=pyload


#? pyreg -> register the python project in the current directory (must have setup.py)
alias pyreg='python setup.py register'


#? pycrm <PATH> -> remove all .pyc files at PATH, defaults to .
function pycrm(){
  if [ "$#" -eq 0 ]; then
    find . -name '*.pyc' -delete
  else
    find $1 -name '*.pyc' -delete
  fi
}
alias rmpyc=pycrm


### NOTE -- none of these seam to work, but pout.json does
# ? ppj -> pretty print json to be used with pipe: cat json.txt|ppj
# http://stackoverflow.com/questions/352098/how-to-pretty-print-json-from-the-command-line
#jsonpp='python -mjson.tool'
#ppj=jsonpp
#ppjson=jsonpp

