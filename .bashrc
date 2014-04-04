# DEBUG #echo 'sourced $HOME/.bashrc'

# C vars {{{
export C_INCLUDE_PATH=/usr/local/include/:${C_INCLUDE_PATH}
export LIBRARY_PATH=/usr/local/lib:${LIBRARY_PATH}
export LD_LIBRARY_PATH=/usr/local/lib:${LD_LIBRARY_PATH}
# }}}

## Safety features ## {{{
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -I'                    # 'rm -i' prompts for every file
# safer alternative w/ timeout, not stored in history
# alias rm=' timeout 3 rm -Iv --one-file-system'
alias ln='ln -i'
alias cls=' echo -ne "\033c"'       # clear screen for real (it does not work in Terminology)
# }}}

# My aliases {{{
alias q='exit'
alias :q='exit'
alias vt='vim -p' #Open arguments in multiple tabs
# }}}

# TMUX {{{
if which tmux 2>&1 >/dev/null; then
#if not inside a tmux session, and if no session is started, start a new session
    test -z "$TMUX" && (tmux attach || tmux new-session)

    # when quitting tmux, try to attach
    while test -z ${TMUX}; do
        tmux attach || break
    done
fi
# }}}