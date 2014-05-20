[ -e ~/dotfiles/zshrc.grml ] && . ~/dotfiles/zshrc.grml

# Platform checker {{{
platform='unknown'
unamestr=`uname`
if [[ "$unamestr" == 'Darwin' ]]; then
   platform='Mac'
elif [[ "$unamestr" == 'FreeBSD' ]]; then
   platform='freebsd'
fi
#}}}

# Case-sensitivity {{{
## case-insensitive (all),partial-word and then substring completion
zstyle ':completion:*' matcher-list 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
#}}}

## Safety features ## {{{
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'                    # 'rm -i' prompts for every file
# safer alternative w/ timeout, not stored in history
# alias rm=' timeout 3 rm -Iv --one-file-system'
alias ln='ln -i'
alias cls=' echo -ne "\033c"'       # clear screen for real (it does not work in Terminology)
# }}}

# My aliases {{{
alias q='exit'
alias :q='exit'
alias l='ls -lhAF --color'
if [ $platform == 'Mac' ]; then
	alias vim="/usr/local/bin/vim -p"
else
	alias vim='vim -p'
fi
# }}}

EDITOR=vim; export EDITOR
VISUAL=vim; export VISUAL

# TMUX {{{
if which tmux 2>&1 >/dev/null; then
#if not inside a tmux session, and if no session is started, start a new session
    test -z "$TMUX" && (tmux attach || tmux new-session)
fi
# }}}
