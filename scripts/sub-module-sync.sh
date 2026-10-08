#!/bin/bash -x
git submodule foreach 'git fetch'
git submodule foreach 'git checkout $(git config -f $toplevel/.gitmodules submodule.$name.branch || echo main)'
