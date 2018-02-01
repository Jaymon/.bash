#!/bin/bash

#? pyload -> upload the python project to pypi
function pyload() {
  pandoc --from=markdown --to=rst --output=README.rst README.md
  # http://inre.dundeemt.com/2014-05-04/pypi-vs-readme-rst-a-tale-of-frustration-and-unnecessary-binding/
  if python setup.py check --restructuredtext --strict; then
    python setup.py sdist upload

    # !!! get rid of all the left over folders and files
    rm README.rst
    rm -rf dist
    rm -rf *.egg-info

  fi
}
alias pyup=pyload


#? pyreg -> register the python project in the current directory (must have setup.py)
alias pyreg='python setup.py register'


#? pycrm <PATH> -> remove all .pyc files at PATH, defaults to .
function pycrm(){
  d="."
  if [ "$#" -gt 0 ]; then
    d=$1
  fi

  find $d -name '*.pyc' -delete
  find $d -name '__pycache__' -type d -exec rm -r "{}" \;

}
alias rmpyc=pycrm


#? pyname [PACKAGE_NAME] -> return whether there is a package with this name
function pyname() {
  package_name=$1
  if [[ -z $package_name ]]; then
    echo "No package name passed in and no setup.py found in current directory"
    return 1
  fi

  if curl "https://pypi.python.org/pypi/$package_name/json" -s | grep -i "200 OK"; then
    echo ":( Package ${package_name} alread exists!"
  else
    echo ":) Package ${package_name} is Available!"
  fi
}


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
    print _.dirname(_.realpath(${1}.__file__[:-1]))" \
  )"
}


#? pyenv3 [VIRTUAL-ENV-NAME] -> create a python3 virtual environment in current directory
function pyvir3() {

  env="venv3"
  if [ "$#" -gt 0 ]; then
    env=$1
  fi

  pyenv $env --python=python3 ${@:2}

}
alias pyenv3=pyvir3


function pyvir2() {

  env="venv"
  if [ "$#" -gt 0 ]; then
    env=$1
  fi

  pyenv $env ${@:2}

}
alias pyenv2=pyvir2


function pycreate() {
  if [ "$#" -eq 0 ]; then
    echo "no VIRTUAL-ENV-NAME specified"
    return 1
  fi

  env=$1
  virtualenv --no-site-packages ${@:2} "$env"

  # create an evironment shell file that custom config can be added to
  if [[ -n "$PYENV_ENVIRON_FILE" ]]; then
    cp "$PYENV_ENVIRON_FILE" "$env/environ.sh"
  else
    touch "$env/environ.sh"
  fi

  # create a usercustomize python file to customize the python installation
  if [[ -n "$PYENV_CUSTOMIZE_FILE" ]]; then
    cp "$PYENV_CUSTOMIZE_FILE" "$env/environ.py"
  else
    touch "$env/environ.py"
  fi

  # we map our custom environ.py file to the sitecustomize so it gets run when
  # our virtualenv python gets run
  py_d=$(find "$env/lib" -type d -name "python*")
  #cp "$PYENV_CUSTOMIZE_FILE" "$py_d/sitecustomize.py"
  $(pushd "$py_d"; ln -s ../../environ.py sitecustomize.py; popd)

}

# http://docs.python-guide.org/en/latest/dev/virtualenvs/
#? pyenv [VIRTUAL-ENV-NAME] -> create a virtual environment in current directory
function pyenv() {

  #set -x

  if [ "$#" -gt 0 ]; then
    env=$1
  else
    env=$(find . -type d -iname "venv*" | head -n 1 | xargs basename)
  fi

  if [[ ! -d "$env" ]]; then
    env="venv"
    pycreate $env ${@:2}
    created_env=1

  fi
  pyact $env

  if [[ -n "$created_env" ]]; then
    if [[ -n "$PYENV_REQUIREMENTS_FILE" ]]; then
      # we upgrade pip because https://github.com/pyca/cryptography/issues/2692
      pip install --upgrade pip
      pip install -r "$PYENV_REQUIREMENTS_FILE"
    fi
  fi

  #set +x

}
alias vigo=pyenv
alias venv=pyenv

#? pyact [VIRTUAL-ENV-NAME] -> activate a virtual environment
function pyact() {

  fp=$(find . -type f -ipath "*$1/bin/activate")
  #source "$fp"
  . "$fp"

  # source a custom environment variable if it is there
  env_d=$(dirname $(dirname $fp))
  environ_f="$env_d/environ.sh"
  if [[ -f "$environ_f" ]]; then
    . "$environ_f"
  fi

  if [[ -f ./requirements.txt ]]; then
    pip install -r ./requirements.txt
  fi
}
alias vido=pyact

#? pydone -> de-activate a virtual environment
function pydone() {
  deactivate
}
alias vino=pydone
alias pykill=pydone
alias pyclear=pydone


#? pymk PATH -> take a path and make a python module (eg, foo/bar would create foo/__init__.py etc)
function pymk() {

  #set -x

  if [ "$#" -eq 0 ]; then
    >&2 echo "pymk DIRECTORY"
  fi

  mkdir -p "$1"

  if [[ ${1:0:1} == "/" ]]; then
    base="/"
  else
    base=""
  fi

  IFS=$'/'; ds=( $1 ); unset IFS
  for d in ${ds[@]}; do
    base="${base}${d}/"
    init_f="${base}__init__.py"

    if [[ ! -f "$init_f" ]]; then
      touch "$init_f"
    fi
  done

  #set +x
}
alias mkpy=pymk
alias pymake=pymk

