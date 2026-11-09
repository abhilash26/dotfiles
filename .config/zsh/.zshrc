#
# ~/.zshrc
#

# Configuration and plugin directories
export ZDOTDIR="$HOME/.config/zsh"
export ZPLUGINDIR="/usr/share/zsh/plugins"

# Load a file if it exists
source_file() {
  [[ -f "$1" ]] && source "$1"
}

# Load a plugin if its standard plugin file exists
source_plugin() {
  local plugin="$1"
  local plugin_file="$ZPLUGINDIR/$plugin/$plugin.zsh"

  [[ -f "$plugin_file" ]] && source "$plugin_file"
}

# Aliases
source_file "$ZDOTDIR/zsh_aliases.zsh"

# Colors and completion
autoload -Uz colors && colors
autoload -Uz compinit && compinit

# Emacs-style keybindings
bindkey -e

# History
HISTFILE="$ZDOTDIR/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000

setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS

# Convenience options
setopt AUTO_CD
setopt INTERACTIVE_COMMENTS
setopt NO_BEEP

# Up/down arrows search history
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search

# Completion behavior
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'

# Plugins: load syntax highlighting last
source_plugin "zsh-autosuggestions"
source_plugin "zsh-syntax-highlighting"

# Zoxide
eval "$(zoxide init zsh)"

setopt PROMPT_SUBST
PROMPT=$'\n%F{blue}%~%f ❯ '
