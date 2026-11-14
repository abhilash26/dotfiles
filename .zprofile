#
# ~/.zprofile
#

# Zsh configuration directory
export ZDOTDIR="$HOME/.config/zsh"

# XDG base directories
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# Add user scripts and binaries to PATH
export PATH="$PATH:$HOME/.scripts:$HOME/.local/bin"

# Default applications
export TERMINAL="foot"
export EDITOR="nvim"
export VISUAL="zeditor"
export BROWSER="helium-browser"
export PAGER="less"
export MANPAGER="bat -plman"


# Start Mango on the first virtual terminal
if [[ "$(tty 2>/dev/null)" == "/dev/tty1" ]] && ! pgrep -x mango >/dev/null; then
  exec mango
fi
