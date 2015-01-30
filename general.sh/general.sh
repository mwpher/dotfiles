#!/bin/sh
# **Requires**: *Bash, Git, Tmux, Zsh, Vim*
cd;
git clone --recursive https://github.com/mwpher/dotfiles;
git config --global user.name "Matthew Pherigo";
git config --global user.email hybrid120@gmail.com;
git config --global push.default simple;
ln -s dotfiles/zshrc .zshrc;
ln -s dotfiles/tmux.conf .tmux.conf;
ln -s dotfiles/dotvim/ .vim;
cd dotfiles;
git submodule foreach git checkout master;
