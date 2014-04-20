#!/bin/sh
which git || return 1

git config --global user.name "Matthew Pherigo"
git config --global user.email hybrid120@gmail.com
git commit --amend --reset-author
