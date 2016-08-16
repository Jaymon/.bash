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


#? pycount [PACKAGE_NAME] -> print out how many downloads the given module has received
function pycount() {
  package_name=$1
  if [[ -z $package_name ]]; then
    package_name=$(python setup.py --name)
  fi

  if [[ -n $package_name ]]; then
    # http://www.cambus.net/parsing-json-from-command-line-using-python/
    curl "https://pypi.python.org/pypi/$package_name/json" -s | python -c 'import sys, json; print json.load(sys.stdin)["urls"][0]["downloads"]'
  else
    echo "No package name passed in and no setup.py found in current directory"
  fi
}


### NOTE -- none of these seem to work, but pout.json does
# ? ppj -> pretty print json to be used with pipe: cat json.txt|ppj
# http://stackoverflow.com/questions/352098/how-to-pretty-print-json-from-the-command-line
#jsonpp='python -mjson.tool'
#ppj=jsonpp
#ppjson=jsonpp


#? pycd MODULE -> go to the source of the python module (eg, pycd foo.bar)
# https://chris-lamb.co.uk/posts/locating-source-any-python-module
# http://stackoverflow.com/a/2723437/5006
function pycd() {
  cd "$(python -c "import os.path as _, ${1}; \
    print _.dirname(_.realpath(${1}.__file__[:-1]))"
  )"
}


# http://docs.python-guide.org/en/latest/dev/virtualenvs/
#? pyenv [VIRTUAL-ENV-NAME] -> create a virtual environamnet in current directory
function pyenv() {
  env="venv"
  if [ "$#" -gt 0 ]; then
    env=$1
  fi

  if [[ ! -d "$env" ]]; then
    virtualenv --no-site-packages "$env"
  fi
  pyact
}
alias vigo=pyenv
alias venv=pyenv

#? pyact -> activate a virtual environment
function pyact() {
  fp=$(find . -type f -ipath "*/bin/activate")
  source "$fp"
}
alias vido=pyact

#? pydone -> de-activate a virtual environment
function pydone() {
  deactivate
}
alias vino=pydone
alias pykill=pydone

