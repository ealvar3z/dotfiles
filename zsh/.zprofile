if [ -d "/opt/homebrew" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -d "~/.linuxbrew" ]; then
  eval "$(~/.linuxbrew/bin/brew shellenv)"
elif [ -d "/home/linuxbrew" ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# eval "$(/usr/bin/mise activate zsh)"

# Created by `pipx` on 2024-06-08 01:12:55
export PATH="$PATH:/home/eax/.local/bin"
