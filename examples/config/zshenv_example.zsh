#!/usr/bin/env zsh
# zshenv_example.zsh - Example ~/.zshenv configuration
#
# ~/.zshenv is sourced for ALL Zsh sessions (interactive, non-interactive, scripts)
# Keep it minimal and focused on environment variables

# ============================================================
# PATH Configuration
# ============================================================

# Add custom bin directories (only if they exist)
path_dirs=(
    "$HOME/.local/bin"
    "$HOME/bin"
    "/usr/local/bin"
    "/usr/local/sbin"
)

for dir in "${path_dirs[@]}"; do
    [[ -d "$dir" && ":$PATH:" != *":$dir:"* ]] && PATH="$dir:$PATH"
done

export PATH

# ============================================================
# XDG Base Directory Specification
# ============================================================
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# ============================================================
# Zsh-specific Environment
# ============================================================
export ZDOTDIR="${XDG_CONFIG_HOME}/zsh"   # Store zsh config in ~/.config/zsh
export HISTFILE="${XDG_STATE_HOME}/zsh/history"

# ============================================================
# Core Tool Preferences
# ============================================================
export EDITOR="${EDITOR:-vim}"
export VISUAL="${VISUAL:-$EDITOR}"
export PAGER="${PAGER:-less}"
export LESS="${LESS:--R --quit-if-one-screen --no-init}"
export MANPAGER="${MANPAGER:-less -X}"

# ============================================================
# Locale
# ============================================================
export LANG="${LANG:-en_US.UTF-8}"
export LC_ALL="${LC_ALL:-en_US.UTF-8}"

# ============================================================
# Development Tools (only if installed)
# ============================================================

# Go
[[ -d "$HOME/go" ]] && export GOPATH="$HOME/go" && PATH="$GOPATH/bin:$PATH"

# Rust/Cargo
[[ -d "$HOME/.cargo/bin" ]] && PATH="$HOME/.cargo/bin:$PATH"

# Node Version Manager (lazy-load in .zshrc)
export NVM_DIR="${XDG_DATA_HOME}/nvm"

# Python
export PYTHONDONTWRITEBYTECODE=1   # don't create .pyc files
export PYTHONUNBUFFERED=1          # unbuffered stdout/stderr

# ============================================================
# Security / Privacy
# ============================================================
export LESSHISTFILE="-"   # disable less history file
export MYSQL_HISTFILE="/dev/null"

# ============================================================
# Application Settings
# ============================================================
# Docker
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

# fzf
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"

# Homebrew (macOS)
if [[ -d "/opt/homebrew" ]]; then
    export HOMEBREW_PREFIX="/opt/homebrew"
    PATH="$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:$PATH"
fi
