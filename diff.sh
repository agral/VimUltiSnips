#!/usr/bin/env bash

SCRIPT_BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

diff -r "$HOME/.vim/UltiSnips/" "$SCRIPT_BASEDIR/UltiSnips"
