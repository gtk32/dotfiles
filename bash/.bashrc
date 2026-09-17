# Source global definitions
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
  PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Aliases
alias vim='nvim'
alias ls='exa --icons always'
alias la='exa -lgah --icons always'
alias ll='exa -lgh --icons always --sort newest'
alias lt='ls --human-readable --size -1 -S --classify'
alias df='df -Ph'
alias mnt="mount | awk -F' ' '{ printf \"%s\t%s\n\",\$1,\$3; }' | column -t | grep -E ^/dev/ | sort"
alias ping='ping -c4'
alias journalctl="journalctl -b 0"
alias cat="bat -p --theme='1337'"
alias glow="glow -t"
alias gcb="git branch --show-current"
alias gab="git branch --all"
alias lg='/usr/bin/lazygit'

# Syntax highlighting Manpager
export MANPAGER="less -R --use-color -Dd+r -Du+b"
export EDITOR="nvim"

# Andere variables
export GPG_TTY=$(tty)

# Set up fzf key bindings and fuzzy completion
eval "$(fzf --bash)"
export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow --exclude .git --exclude node_modules --exclude .cache --exclude .ansible --exclude .local/share/Trash --exclude .vdirsyncer'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

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
