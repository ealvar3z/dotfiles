SHELL_SESSION_DISABLE=1
bindkey -v
export KEYTIMEOUT=15
bindkey -M viins 'jk' vi-cmd-mode

bindkey '^?' backward-delete-char
bindkey '^H' backward-delete-char

fpath=($HOME/.zsh/completions $fpath)

autoload -Uz vcs_info
autoload -Uz compinit && compinit

zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats '(%b) '

precmd() {
  vcs_info
}

setopt prompt_subst
unsetopt prompt_sp
unset zle_bracketed_paste

if [[ -z ${vcs_info_msg_0_} ]]; then
    PS1='; '
else
    PS1='${vcs_info_msg_0_}; '
fi

alias bup='brew update && brew upgrade && brew autoremove && brew cleanup -s'
alias bsz='du -sh /opt/homebrew ~/.cache/Homebrew 2>/dev/null'
alias c='clear'
alias x='exit'
alias la='ls -a'
alias ll='ls -lah'
alias rg='rg --colors match:none'
alias grep='grep --color=never'
