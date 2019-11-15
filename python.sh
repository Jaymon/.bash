#!/bin/bash

#? pyload -> upload the python project to pypi
function pyload() {

    # https://stackoverflow.com/questions/26737222/how-to-make-pypi-description-markdown-work
    # https://stackoverflow.com/a/26737258/5006
    if python3 setup.py check; then
        python3 setup.py sdist
        # https://pypi.org/project/twine/
        twine upload dist/*
        pyclean
    fi

}
alias pyup=pyload

# This is here just in case while I switch over all setup.py to support markdown
function pyloadold () {
  pandoc --from=markdown --to=rst --output=README.rst README.md
  # http://inre.dundeemt.com/2014-05-04/pypi-vs-readme-rst-a-tale-of-frustration-and-unnecessary-binding/
  if python setup.py check --restructuredtext --strict; then
    python setup.py sdist upload
    pyclean

  fi
}

#? pyclean -> clean up the current directory of the residual python sdist crap
function pyclean() {
    # !!! get rid of all the left over folders and files
    if [[ -f setup.py ]]; then
        if which trash > /dev/null 2>&1; then
            trash README.rst > /dev/null 2>&1
            trash dist > /dev/null 2>&1
            trash *.egg-info > /dev/null 2>&1
            trash build > /dev/null 2>&1
            trash .eggs > /dev/null 2>&1
        else
            rm README.rst > /dev/null 2>&1
            rm -rf dist
            rm -rf *.egg-info
            rm -rf build
            rm -rf .eggs
        fi

    fi

    pycrm
}


#? pyreg -> register the python project in the current directory (must have setup.py)
alias pyreg='python setup.py register'


#? pycrm <PATH> -> remove all .pyc files at PATH, defaults to .
function pycrm(){
  d="."
  if [ "$#" -gt 0 ]; then
    d=$1
  fi

  find $d -name '*.pyc' -delete > /dev/null 2>&1
  find $d -name '__pycache__' -type d -exec rm -rf "{}" \; > /dev/null 2>&1

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

  if [ "$#" -gt 0 ]; then
    env=$1
  else
      if [[ -d "venv3" ]]; then
          env="venv3"
      else
          env=".venv3"
      fi
  fi

  pyvenv $env --python=python3 ${@:2}

}
alias pyvenv3=pyvir3


function pyvir2() {

  if [ "$#" -gt 0 ]; then
    env=$1
  else
      if [[ -d "venv" ]]; then
          env="venv"
      else
          env=".venv"
      fi
  fi

  pyvenv $env ${@:2}

}
alias pyvenv2=pyvir2


function pycreate() {
  if [ "$#" -eq 0 ]; then
    echo "no VIRTUAL-ENV-NAME specified"
    return 1
  fi

  env=$1
  virtualenv --no-site-packages ${@:2} "$env"

  # create an evironment shell file that custom config can be added to
  if [[ ! -f ".env" ]]; then
      if [[ -n "$PYENV_ENVIRON_FILE" ]]; then
        #cp "$PYENV_ENVIRON_FILE" "$env/environ.sh"
        cp "$PYENV_ENVIRON_FILE" ".env"
      else
        #touch "$env/environ.sh"
        touch ".env"
      fi
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
  $(pushd "$py_d"; ln -s ../../environ.py sitecustomize.py; popd) &>/dev/null

}

# http://docs.python-guide.org/en/latest/dev/virtualenvs/
#? pyvenv [VIRTUAL-ENV-NAME] -> create a virtual environment in current directory
function pyvenv() {

    # we want to fail on any command failing in the script
    # http://stackoverflow.com/questions/821396/aborting-a-shell-script-if-any-command-returns-a-non-zero-value
    #set -e
    set -o pipefail

    set -x

    search=""
    if [ "$#" -gt 0 ]; then
        search=$1
    fi

    # SEARCH FORWARD - search for the virtual env name forwards first
    if [[ -n $search ]]; then
        env=$(find . -type d -iname "$search" | head -n 1 | xargs basename)
    else
        env=$(find . -type d -iname ".venv*" -o -iname "venv*" | head -n 1 | xargs basename)
    fi

    # SEARCH BACKWARD - if we don't find the environment moving forward then move backwards
    if [[ ! -d $env ]]; then
        path=$PWD
        while [[ $path != "/" ]]; do
            #echo $path
            if [[ -n $search ]]; then
                env=$(find "$path" -type d -maxdepth 1 -iname "$search" | head -n 1 | xargs basename)
            else
                env=$(find "$path" -type d -maxdepth 1 -iname ".venv*" -o -iname "venv*" | head -n 1 | xargs basename)
            fi
          if [[ -d "$env" ]]; then
            break
          fi
          path=$(dirname "$path")
        done
    fi

    if [[ ! -d "$env" ]]; then
        env=".venv"
        pycreate $env ${@:2}
        created_env=1
    fi

    pyact $env

    if [[ -n "$created_env" ]]; then
        if [[ -n "$PYENV_REQUIREMENTS_FILE" ]]; then
            # we upgrade pip because https://github.com/pyca/cryptography/issues/2692
            pip -q install --upgrade pip
            pip -q install -r "$PYENV_REQUIREMENTS_FILE"
        fi

        if which python3 > /dev/null 2>&1; then
            pymodules=$(python3 -c "import distutils.core; print('\n'.join(distutils.core.run_setup('setup.py').install_requires))")
            for f in $pymodules; do
                pip install "$f"
            done
        fi

    fi

    set +x

    set +e
    set +o pipefail

}
alias vigo=pyvenv
alias venv=pyvenv

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

  environ_f=".env"
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


#? pytouch PATH -> take a path and make a python module (eg, foo/bar/ would create foo/__init__.py etc)
#? pytouch NAME -> create NAME (eg foo.py) using a template if PYENV_TEMPLATE is set
function pytouch() {

    if [[ $# -eq 0 ]] || [[ $1 == "--help" ]] || [[ $1 == "-h" ]]; then
        >&2 echo "usage: $(basename $0) NAME"
        >&2 echo "create NAME (eg foo.py) using a template if PYENV_TEMPLATE is set"
        >&2 echo ""
        >&2 echo "NAME can be a path (foo/bar/che), if you want to create a package,"
        >&2 echo "end NAME with a / (eg, foo/bar/), otherwise a .py file will be created"
        >&2 echo "(eg, foo would create foo.py while foo/bar would create foo/bar.py)"
        exit 0
    fi

    #set -x

    # figure out if we have an absolute path or not
    if [[ ${1:0:1} == "/" ]]; then
        base="/"
    else
        base=""
    fi

    # split on / so we can make the different directories
    IFS=$'/'; ds=( $1 ); unset IFS
    basename=${ds[-1]}

    # iterate through all the subfolders and create directories and add __init__.py file
    # https://stackoverflow.com/a/44939917/5006
    for d in ${ds[@]::${#ds[@]}-1}; do
        base="${base}${d}/"
        mkdir -p "$base"

        init_f="${base}__init__.py"
        if [[ ! -f "$init_f" ]]; then
            if [[ -n $PYENV_TEMPLATE ]]; then
                cp "$PYENV_TEMPLATE" "$init_f"
            else
                touch "$init_f"
            fi
        fi
    done

    # if we end with / then we want the final basename to be a package (eg foo/bar/
    # would create foo/bar/__init__.py) but if it doesn't end with / then it would
    # create foo/bar.py
    if [[ $1 =~ /$ ]]; then
        base="${base}${basename}/"
        mkdir -p "$base"
        name="${base}__init__.py"
    else
        if [[ ! $basename =~ \.py$ ]]; then
            name="${base}${basename}.py"
        else
            name="${base}${basename}"
        fi
    fi

    if [[ ! -f "$name" ]]; then
        if [[ -n $PYENV_TEMPLATE ]]; then
            cp "$PYENV_TEMPLATE" "$name"
        else
            touch "$name"
        fi
    fi

    #set +x
}
alias pymk=pytouch
alias mkpy=pymk
alias pymake=pymk


#? pytouch PATH -> take a path and make a python test module, uses PYENV_TEMPLATE_TEST env variable 
function pytesttouch() {

    #test_name=$(basename $1)
    test_name=$1
    test_name=${test_name%.py}
    test_name=${test_name%_test}
    echo $test_name

    orig_template=$PYENV_TEMPLATE
    PYENV_TEMPLATE=$PYENV_TEMPLATE_TEST

    pytouch "${test_name}_test"

    PYENV_TEMPLATE=$orig_template

}
alias mkpyt=pytesttouch
alias pymaket=pytesttouch
alias pytmk=pytesttouch

