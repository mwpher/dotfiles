#!/bin/sh
which git || return 1

git commit --amend --reset-author
