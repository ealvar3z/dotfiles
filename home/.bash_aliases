# Unix
alias mkdir="mkdir -p"
alias la="ls -a"
alias ll="ls -al"
alias ln="ln -v"
alias vi="nvim"
alias c="clear"
alias x="exit"

# OpenBSD
alias ai='doas pkg_add'
alias ad='doas pkg_delete'
alias au='doas pkg_add -u'
alias as='pkg_info -Q'

# Git
alias ga='git add'
alias gb='git branch'
alias gc='git commit'
alias gco='git checkout'
alias gl='git log --oneline --grpah --decorate'
alias gp='git push'
alias gs='git diff'
alias gs='git status'

# Arch
yay="paru"

# llm manpages
alias ?="llm"

# Bundler
alias b="bundle"

# Rails
alias migrate="bin/rails db:migrate db:rollback && bin/rails db:migrate db:test:prepare"
alias s="rspec"

# Pretty print the path
alias path='echo -e "${PATH//:/\\n}"'

# Easier navigation: ..., ....
alias ..="cd ../"
alias ...="cd ../.."
alias ....="cd ../../.."
alias d="cd ~/Downloads"
alias conf="cd ~/.config"
alias dots="cd ~/dotfiles"

# Include custom aliases
if [[ -f ~/.aliases.local ]]; then
  source ~/.aliases.local
fi
