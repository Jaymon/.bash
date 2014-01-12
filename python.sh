#!/bin/bash

function pyload() {
  pandoc --from=markdown --to=rst --output=README.rst README.md
  python setup.py sdist upload
  # todo -- get rid of all the left over folders?
}

alias pyreg='python setup.py register'

