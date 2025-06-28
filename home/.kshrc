#!/bin/sh

stty status '^T'

PATH=$HOME/bin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/X11R6/bin:/usr/local/bin:/usr/local/sbin

# use vim if it's installed, vi otherwise
case "$(command -v vim)" in
  */vim) VIM=vim ;;
  *)     VIM=vi  ;;
esac

EDITOR=$VIM
VISUAL=$VIM
FCEDIT=$EDITOR
PAGER=less
LESS='-iMRS -x2'
CLICOLOR=0
HISTFILE=$HOME/.ksh_history
HISTSIZE=20000

set -o vi

# shellcheck disable=SC2086
update_complete_rbw() {
  rbw_list=$(rbw ls)
  set -A complete_rbw 			-- init rbwphrase add import show ls
  set -A complete_rbw_add		-- $rbw_list
  set -A complete_rbw_edit		-- $rbw_list
  set -A complete_rbw_export	-- $rbw_list
  set -A complete_p				-- $rbw_list
  set -A complete_rbw_get		-- $rbw_list
}
update_complete_rbw
rbw_export()	{ rbw export	"$1"; }
rbw_add()		{ rbw add	"$1" && update_complete_rbw; }
rbw_edit()		{ rbw edit	"$1"; }
rbw_get()		{ rbw get	"$1"; }
p()				{ rbw export	"$1"; }

t()	{ tmux new -DAs 0; }
s() { stmux 'irc' 'pub/irc'	'senpai'; }

png()	{ optipng -preserve -strip all -o7 $*; }
jpg()	{ jpegoptim --strip-all --preserve --preserve-perms --verbose -m80 $@; }
j50()	{ jpegoptim --strip-all --preserve --preserve-perms --verbose -m50 $@; }
j20() 	{ jpegoptim --strip-all --preserve --preserve-perms --verbose -m20 $@; }
fit()	{ convert -resize 1200 "$1" "$1"; jpg "$1"; }
f50()	{ convert -resize 50 "$1" "$1"; jpg "$1"; }
f120()	{ convert -resize 120 "$1" "$1"; jpg "$1"; }
f600()	{ convert -resize 600 "$1" "$1"; jpg "$1"; }

alias c='clear'
alias x='exit'
alias cp='cp -i'
alias lc='ls -la'
alias mv='mv -i'
alias rm='rm -i'

g() { test -n "$1" && a=$(ag "$1" | fzf | cut -d: -f1) && test -n "$a" && vi "$a"; }

alias ga='git add --all'
alias gap='git add --all -p'
alias gc='git commit'
alias gd='git diff'
alias gf='git commit --amend --no-edit'
alias gl='git log --oneline -30'
alias gp='git push'
alias gpf='git push -f'
alias gr='git rebase -i HEAD~20'
alias gs='git status -sb'
alias gpl='git pull'

