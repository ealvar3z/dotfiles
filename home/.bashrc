#!/usr/bin/bash
# shellcheck disable=SC1090,SC1091

case $- in
*i*) ;; # interactive
*) return ;;
esac

# ------------------------- distro detection -------------------------

export DISTRO
if [[ $(uname -r) =~ Microsoft ]]; then
    if grep -q "Microsoft" /proc/version && ! grep -q "WSL2" /proc/version; then
        DISTRO="WSL1"
    else
        DISTRO="WSL2"
    fi
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    DISTRO="Linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    DISTRO="macOS"
elif [[ "$OSTYPE" == "freebsd"* ]]; then
    DISTRO="FreeBSD"
elif [[ "$OSTYPE" == "openbsd"* ]]; then
    DISTRO="OpenBSD"
else
    DISTRO="Unknown"
fi

# ---------------------- local utility functions ---------------------

_have() { type "$1" &>/dev/null; }
_source_if() { [[ -r "$1" ]] && source "$1"; }

# ----------------------- environment variables ----------------------

export LANG=en_US.UTF-8 
export HELP_BROWSER=w3m
export BROWSERCLI=w3m
export BROWSER=chromium
export TERM=tmux-256color
export CLICOLOR=1
export HRULEWIDTH=79
export EDITOR=/usr/bin/ed
export VISUAL=/usr/bin/vi
export DOTFILES="$HOME/dotfiles"
export GOPATH="$HOME/go"
export GOBIN="$GOPATH/bin"
export PTB_DIR="$HOME/src/ptb/txt"
export DOOMBIN="$HOME/.emacs.d/bin"
export ODIN_PATH="$HOME/src/Odin"
export PYTHONDONTWRITEBYTECODE=2
export OAUTH_REFRESH_TOKEN=$(rbw get davmail.oauth.refreshToken)
export LC_COLLATE=C

[[ -d /.vim/spell ]] && export VIMSPELL=("$HOME/.vim/spell/*.add")

# -------------------------------- gpg -------------------------------

GPG_TTY=$(tty)
export GPG_TTY

# ------------------------------- pager ------------------------------

# Set LESS options
export LESS="-FXR"

# Define ANSI escape sequences for colors and text attributes
export LESS_TERMCAP_mb=$'\e[35m' # Magenta for blinking text
export LESS_TERMCAP_md=$'\e[33m' # Yellow for bold text
export LESS_TERMCAP_me=$'\e[0m'  # Reset all attributes
export LESS_TERMCAP_se=$'\e[0m'  # Reset standout-mode
export LESS_TERMCAP_so=$'\e[34m' # Blue for standout-mode text
export LESS_TERMCAP_ue=$'\e[0m'  # Reset underline
export LESS_TERMCAP_us=$'\e[4m'  # Underline

# Set MANPAGER to use less with -R flag
export MANPAGER="less -R"

# Optionally, set PAGER for other applications
export PAGER="less -R"

# ----------------------------- dircolors ----------------------------

if _have dircolors; then
	if [[ -r "$HOME/.dircolors" ]]; then
		eval "$(dircolors -b "$HOME/.dircolors")"
	else
		eval "$(dircolors -b)"
	fi
fi

# ------------------------------- path -------------------------------

paths() {
	echo -e "${PATH//:/\\n}"
}

pathappend() {
	declare arg
	for arg in "$@"; do
		test -d "$arg" || continue
		PATH=${PATH//":$arg:"/:}
		PATH=${PATH/#"$arg:"/}
		PATH=${PATH/%":$arg"/}
		export PATH="${PATH:+"$PATH:"}$arg"
	done
} && export -f pathappend

pathprepend() {
	for arg in "$@"; do
		test -d "$arg" || continue
		PATH=${PATH//:"$arg:"/:}
		PATH=${PATH/#"$arg:"/}
		PATH=${PATH/%":$arg"/}
		export PATH="$arg${PATH:+":${PATH}"}"
	done
} && export -f pathprepend

# remember last arg will be first in path
pathprepend \
	"$HOME/bin" \
	"$HOME/.local/bin" \
	"$GOBIN" \
	"$DOOMBIN" \
	"$ODIN_PATH" \
	/usr/local/go/bin

pathappend \
	/usr/local/bin \
	/usr/local/sbin \
	/usr/local/games \
	/usr/games \
	/usr/sbin \
	/usr/bin \
	/snap/bin \
	/sbin \
	/bin

# ------------------------------ cdpath ------------------------------

export CDPATH=".:$DOTFILES:$HOME"

# ------------------------ bash shell options ------------------------

# shopt is for BASHOPTS, set is for SHELLOPTS

shopt -s checkwinsize # enables $COLUMNS and $ROWS
shopt -s expand_aliases
shopt -s globstar
shopt -s dotglob
shopt -s extglob

#shopt -s nullglob # bug kills completion for some
#set -o noclobber

# -------------------------- stty annoyances -------------------------

stty -ixon # disable control-s/control-q tty flow control

# ------------------------------ history -----------------------------

export HISTCONTROL=ignoreboth
export HISTSIZE=5000
export HISTFILESIZE=10000

shopt -s histappend

# --------------------------- smart prompt ---------------------------
#                 (keeping in bashrc for portability)

PROMPT_LONG=20
PROMPT_MAX=95
PROMPT_AT=@

__ps1() {
	local P='$' dir="${PWD##*/}" B countme short long double \
		r='\[\e[31m\]'  \
		u='\[\e[33m\]'  \
		b='\[\e[36m\]'  \
    x='\[\e[0m\]'   \
    h='\[\e[34m\]'  \
    p='\[\e[34m\]'
    # w='\[\e[35m\]'
    # g='\[\e[30m\]'

  [[ $EUID == 0 ]] && P='#' && u=$r && p=$u # root
	[[ $PWD = / ]] && dir=/
	[[ $PWD = "$HOME" ]] && dir='~'

	B=$(git branch --show-current 2>/dev/null)
	[[ $dir = "$B" ]] && B=.
	countme="$USER$PROMPT_AT$(hostname):$dir($B)\$ "

	[[ $B == master || $B == main ]] && b="$r"
	[[ -n "$B" ]] && B="$u($b$B$u)"

	short="$u\u$u$PROMPT_AT$u\h$u:$r$dir$B$p$P$x "
	long="$u╔ $u\u$u$PROMPT_AT$u\h$u:$r$dir$B\n$u╚ $p$P$x "
	double="$u╔ $u\u$h$PROMPT_AT$h\h$u:$r$dir\n$u║ $B\n$u╚ $p$P$x "

	if ((${#countme} > PROMPT_MAX)); then
		PS1="$double"
	elif ((${#countme} > PROMPT_LONG)); then
		PS1="$long"
	else
		PS1="$short"
	fi
}

PROMPT_COMMAND="__ps1"

# ----------------------------- keyboard -----------------------------

# only works if you have X and are using graphic Linux desktop

_have setxkbmap && test -n "$DISPLAY" &&
	setxkbmap -option ctrl:swapcaps &>/dev/null

# ------------------------------ aliases -----------------------------
#      (use exec scripts instead, which work from vim and subprocs)

unalias -a
alias '??'=gpt
alias dot='cd $DOTFILES'
alias scripts='cd $SCRIPTS'
alias free='free -h'
alias tree='tree -a'
alias df='df -h'
alias chmox='chmod +x'
alias diff='diff --color'
alias temp='cd $(mktemp -d)'

_have vim && alias vi=vim

# ------------- source external dependencies / completion ------------

# for mac
if [[ "$OSTYPE" == "darwin"* ]]; then
  brew_prefix="$(brew --prefix)"
	[[ -r "$brew_prefix/etc/profile.d/bash_completion.sh" ]] && . "$brew_prefix/etc/profile.d/bash_completion.sh"
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  elif [ -r /usr/pkg/share/bash-completion/bash_completion ]; then
	. /usr/pkg/share/bash-completion/bash_completion
  fi
fi

# -------------------- personalized configuration --------------------

_source_if "$HOME/.bash_personal"
_source_if "$HOME/.bash_private"
_source_if "$HOME/.bash_work"
_source_if "$HOME/.aliases"


[ -f ~/.fzf.bash ] && source ~/.fzf.bash

