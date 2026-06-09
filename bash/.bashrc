# Source global definitions
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
  PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Source ~/.bash_scripts
source ~/.bash_scripts

# Aliases
alias vim='nvim'
alias ls='exa --icons'
alias la='exa -lgah --icons'
alias ll='exa -lgh --icons --sort newest'
alias lt='ls --human-readable --size -1 -S --classify'
alias df='df -Ph'
alias mnt="mount | awk -F' ' '{ printf \"%s\t%s\n\",\$1,\$3; }' | column -t | grep -E ^/dev/ | sort"
alias ping='ping -c4'
alias journalctl="journalctl -b 0"
alias cat="bat -p --theme='1337'"
alias ollama="podman start ollama && podman start open-webui"
alias glow="glow -t"
alias gcb="git branch --show-current"
alias gab="git branch --all"
alias lg='/usr/bin/lazygit'
alias fabric='/usr/bin/fabric-ai'
alias scale='/home/geert/Downloads/Git/Waifu2x-ncnn-vulkan/waifu2x-ncnn-vulkan-20250915-linux/waifu2x-ncnn-vulkan'

# Syntax highlighting Manpager
export MANPAGER="less -R --use-color -Dd+r -Du+b"
export EDITOR="nvim"

# Set up fzf key bindings and fuzzy completion
eval "$(fzf --bash)"

# Aliases for kitty kittens
alias icat="kitty +kitten icat"
alias issh="kitty +kitten ssh"
alias transfer="kitty +kitten transfer --permissions-bypass"

# Starship prompt
eval "$(starship init bash)"

# Zoxide autojump
eval "$(zoxide init --cmd cd bash)"

# Create the Hotkey (Ctrl+P)
bind -x '"\C-p": pj'

unset rc
