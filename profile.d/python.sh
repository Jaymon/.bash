#!/bin/bash

###############################################################################
# pypi distribution
###############################################################################

#? pyload -> upload the python project to pypi
function pyload() {

    if ! twine -h > /dev/null 2>&1; then
        {
            echo "twine is missing, install it!"
            echo -e "\tpip install --upgrade twine"
        } >&2
        return 1
    fi

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


###############################################################################
# virtual environment
###############################################################################

# NOTE -- The pyvenv, pycreate, and pyactivate methods have to be functions because
# they mess with the actual shell environment

# pycreate [VIRTUAL-ENV-NAME] -> create a virtual environment
function pycreate() {

    if [ "$#" -eq 0 ]; then
        echo "no VIRTUAL-ENV-NAME specified"
        return 1
    fi

    env=$1

    if python --version | grep "Python 3." > /dev/null 2>&1; then
        # https://stackoverflow.com/a/30233408/5006
        python -m venv ${@:2} "$env"
    else
        virtualenv ${@:2} "$env"
    fi

    echo "Created virtual environment: $env"


    # create an evironment shell file that custom config can be added to
    environ_f=".env"
    if [[ ! -f "$environ_f" ]]; then
        if [[ -n "$PYVENV_ENVIRON_FILE" ]]; then
            cp "$PYVENV_ENVIRON_FILE" "$environ_f"
            echo "Copied environ file: $environ_f from $PYVENV_ENVIRON_FILE"
        else
            touch "$environ_f"
            echo "Created blank environ file: $environ_f"
        fi
    fi


    # create a usercustomize python file to customize the python installation
    site_f="$env/sitecustomize.py"
    if [[ -f "$PYVENV_CUSTOMIZE_FILE" ]]; then
        cp "$PYVENV_CUSTOMIZE_FILE" "$env/sitecustomize.py"
        echo "Copied site customize file: $site_f from $PYVENV_CUSTOMIZE_FILE"
    else
        touch "$env/sitecustomize.py"
        echo "Created blank site customize file: $site_f"
    fi

    # we map our custom sitecustomize.py.py file to the sitecustomize so it gets run when
    # our virtualenv python gets run, this is really just for convenience
    py_d=$(find "$env/lib" -type d -name "python*")
    #cp "$PYENV_CUSTOMIZE_FILE" "$py_d/sitecustomize.py"
    $(pushd "$py_d"; ln -s ../../sitecustomize.py sitecustomize.py; popd) &>/dev/null

}


# pyactivate [VIRTUAL-ENV-NAME] -> activate a virtual environment
function pyactivate() {

  fp=$(find . -type f -ipath "*$1/bin/activate")
  #source "$fp"
  . "$fp"

  environ_f=".env"
  if [[ -f "$environ_f" ]]; then
    . "$environ_f"
    echo "Sourced environ file: $environ_f"
  fi

#  req_f="requirements.txt"
#  if [[ -f "$req_f" ]]; then
#    pip install -r "$req_f"
#    echo "Installed dependencies in file: $req_f"
#  fi

}


#? pydeactivate -> de-activate a virtual environment
function pydeactivate() {
  deactivate
}
alias pydone=pydeactivate
alias pykill=pydeactivate
alias pyclear=pydeactivate


# http://docs.python-guide.org/en/latest/dev/virtualenvs/
#? pyvenv [VIRTUAL-ENV-NAME] -> create a virtual environment in current directory
function pyvenv() {

    # we want to fail on any command failing in the script
    # http://stackoverflow.com/questions/821396/aborting-a-shell-script-if-any-command-returns-a-non-zero-value
    #set -e
    set -o pipefail
    #set -x

    python_version=$(python --version | cut -d ' ' -f2)
    search=".venv${python_version}"
    if [ "$#" -gt 0 ]; then
        search=$1
    fi

    # SEARCH FORWARD - search for the virtual env name forwards first
    env=$(find . -type d -iname "$search" | head -n 1 | xargs basename)

    # SEARCH BACKWARD - if we don't find the environment moving forward then move backwards
    if [[ ! -d $env ]]; then
        path=$PWD
        while [[ $path != "/" ]]; do
            env=$(find "$path" -type d -maxdepth 1 -iname "$search" | head -n 1 | xargs basename)
          if [[ -d "$env" ]]; then
            break
          fi
          path=$(dirname "$path")
        done
    fi

    # We didn't find a current environment so let's set it to the default
    if [[ -z "$env" ]]; then
        env=$search
    fi

    echo "Using $env as the virtual environment name"

    if [[ ! -d "$env" ]]; then
        pycreate $env ${@:2}
        created_env=1
    fi

    pyactivate $env

    #set +x
    #set +e
    set +o pipefail

}


###############################################################################
# other
###############################################################################

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


#? pycd MODULE -> go to the source of the python module (eg, pycd foo.bar)
# https://chris-lamb.co.uk/posts/locating-source-any-python-module
# http://stackoverflow.com/a/2723437/5006
function pycd() {
  cd "$(python -c "import os.path as _, ${1}; \
    print _.dirname(_.realpath(${1}.__file__[:-1]))" \
  )"
}



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

    # decide what template to use, if name ends with test then use test template
    template=$PYVENV_TEMPLATE
    name=$1
    name=${name%.py}
    if [[ "$name" = *test ]]; then
        template=$PYVENV_TEMPLATE_TEST
    fi

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
            if [[ -n $template ]]; then
                cp "$template" "$init_f"
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
        if [[ -n $template ]]; then
            cp "$template" "$name"
        else
            touch "$name"
        fi
    fi

    #set +x
}
alias pymk=pytouch
alias mkpy=pymk
alias pymake=pymk


# py-check-imports -> uses pylint to check for all unused imports
function py-unused-imports() {
    # https://github.com/PyCQA/pylint
    # https://stackoverflow.com/questions/2540202/#comment81968262_2540211
    pylint * | grep "unused-import"
}

