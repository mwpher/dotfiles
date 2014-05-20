[ -e ~/dotfiles/zshrc.grml ] && . ~/dotfiles/zshrc.grml

# Platform checker {{{
platform='unknown'
unamestr=`uname`
if [[ "$unamestr" == 'Darwin' ]]; then
   platform='Mac'
elif [[ "$unamestr" == 'FreeBSD' ]]; then
   platform='Freebsd'
fi
#}}}

# Case-sensitivity {{{
## case-insensitive (all),partial-word and then substring completion
zstyle ':completion:*' matcher-list 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
#}}}

# WOW    SUCH ARCH COMMANDS {{{
# Custom command to list all packages not in base or base-devel
alias installed=\
	'comm -23 <(pacman -Qeq|sort) <(pacman -Qgq base base-devel|sort)'

#Use pacmatic instead of pacman
alias pacman='pacmatic'
#}}}

# FreeBSD C vars {{{
if [ $platform == 'FreeBSD' ]; then
export C_INCLUDE_PATH=/usr/local/include/:${C_INCLUDE_PATH}
export LIBRARY_PATH=/usr/local/lib:${LIBRARY_PATH}
export LD_LIBRARY_PATH=/usr/local/lib:${LD_LIBRARY_PATH}
fi
# }}}

## Safety features ## {{{
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'                    # 'rm -i' prompts for every file
# safer alternative w/ timeout, not stored in history
# alias rm=' timeout 3 rm -Iv --one-file-system'
alias ln='ln -i'
alias cls=' echo -ne "\033c"'       # clear screen for real (it does not work in Terminology)
if [ $platform == 'Linux' ]; then
	alias chown='chown --preserve-root'
	alias chmod='chmod --preserve-root'
	alias chgrp='chgrp --preserve-root'
fi
# }}}

# My aliases {{{
alias q='exit'
alias :q='exit'
if [ $platform == 'Linux' ]; then
	alias ls='ls -lhAF --color'
else
	alias ls='ls -lhAFG'
fi
alias vi='vim -p'
if [ $platform == 'Mac' ]; then
	alias vim="/usr/local/bin/vim -p"
else
	alias vim='vim -p'
fi

alias ci='ci -u'
alias co='co -l'
# }}}

EDITOR=vim; export EDITOR
VISUAL=vim; export VISUAL

# TMUX {{{
if which tmux 2>&1 >/dev/null; then
#if not inside a tmux session, and if no session is started, start a new session
    test -z "$TMUX" && (tmux attach || tmux new-session)
fi
# }}}

if [ -x /usr/games/fortune/freebsd-tips ] ; then \
			/usr/games/fortune/freebsd-tips ; fi
