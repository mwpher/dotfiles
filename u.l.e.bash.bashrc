# DEBUG #echo sourced /usr/local/etc/bash.bashrc

( [ -f $HOME/.bashrc ] && . $HOME/.bashrc ) || echo "$HOME/.bashrc is missing!"
