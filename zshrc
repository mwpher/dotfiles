[ -e ~/dotfiles/zshrc.grml ] && . ~/dotfiles/zshrc.grml
[ -e ~/dotfiles/opp.zsh/opp.zsh ] && . ~/dotfiles/opp.zsh/opp.zsh

export HISTSIZE=10000
export HISTFILE="$HOME/.zhistory"
export SAVEHIST=$HISTSIZE
setopt autocd
export KEYTIMEOUT=1

# Vim mode {{{
zle-keymap-select () {
    if [ $TERM = "rxvt-256color" ]; then
        if [ $KEYMAP = vicmd ]; then
            echo -ne "\033]12;Red\007"
        else
            echo -ne "\033]12;Grey\007"
        fi
    fi
}
zle -N zle-keymap-select
zle-line-init () {
    zle -K viins
    if [ $TERM = "rxvt-256color" ]; then
        echo -ne "\033]12;Grey\007"
    fi
}
zle -N zle-line-init
setopt vi
# }}}
#VIM_PROMPT="%{$fg_bold[yellow]%} [% NORMAL]% %{$reset_color%}"
#function is_vimode () {
#	REPLY="${${KEYMAP/vicmd/$VIM_PROMPT}/(main|viins)/}"
#}
#grml_theme_add_token vimode is_vimode()
#zstyle ':prompt:grml:right:setup' items vimode sad-smiley

# Platform checker {{{
platform='unknown'
unamestr=`uname`
if [[ "$unamestr" == 'Darwin' ]]; then
   platform='Mac'
elif [[ "$unamestr" == 'FreeBSD' ]]; then
   platform='FreeBSD'
elif [[ "$unamestr" == 'OpenBSD' ]]; then
   platform='OpenBSD'
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

# Set env variables {{{
export EDITOR=vim
export VISUAL=vim
export SHELL=`which zsh`
if [ $platform == 'FreeBSD' ]; then
export C_INCLUDE_PATH=/usr/local/include/:${C_INCLUDE_PATH}
export LIBRARY_PATH=/usr/local/lib:${LIBRARY_PATH}
export LD_LIBRARY_PATH=/usr/local/lib:${LD_LIBRARY_PATH}
export CFLAGS='-Weverything -Wno-unused-parameter -std=c99 -O0 -D_FORTIFY_SOURCE=2 -fstack-protector-all -lmatt -lm'
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

alias ci='ci -u'
alias co='co -l'
# }}}
# Platform-specific aliases {{{
if [ $platform == 'Linux' ]; then
	alias ls='ls -lhAF --color'
	alias ls='ls -AF --color'
elif [ $platform == 'OpenBSD' ]; then
	alias ls='ls -lhAF'
	alias l='ls -AF'
	alias poweroff='shutdown -ph now'
else
	alias ls='ls -lhAFG'
	alias l='ls -AFG'
fi
if [ $platform == 'Mac' ]; then
	alias vim="/usr/local/bin/vim -p"
	alias vi="/usr/local/bin/vim -p"
else
	alias vim='vim -p'
	alias vi='vim -p'
fi
# }}}

# TMUX {{{
if which tmux 2>&1 >/dev/null; then
#if not inside a tmux session, and if no session is started, start a new session
    test -z "$TMUX" && (tmux attach || tmux new-session)
fi
# }}}

if [ -x /usr/games/fortune/freebsd-tips ] ; then \
			/usr/games/fortune/freebsd-tips ; fi
