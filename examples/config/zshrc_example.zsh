#!/usr/bin/env zsh
# zshrc_example.zsh - Example ~/.zshrc configuration
#
# Copy relevant sections to your ~/.zshrc and customize as needed

# ============================================================
# Performance: Profile startup if DEBUG_STARTUP is set
# ============================================================
[[ -n "${DEBUG_STARTUP:-}" ]] && zmodload zsh/zprof

# ============================================================
# History Configuration
# ============================================================
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000

setopt SHARE_HISTORY          # share history between sessions
setopt HIST_IGNORE_DUPS       # ignore duplicate entries
setopt HIST_IGNORE_SPACE      # ignore entries starting with space
setopt HIST_REDUCE_BLANKS     # remove extra blanks
setopt EXTENDED_HISTORY       # save timestamp and duration

# ============================================================
# Navigation
# ============================================================
setopt AUTO_CD                # type directory name to cd
setopt AUTO_PUSHD             # auto push to dir stack
setopt PUSHD_IGNORE_DUPS      # no duplicates in dir stack
setopt CDABLE_VARS            # cd to variable-named dirs

DIRSTACKSIZE=20

# ============================================================
# Completion
# ============================================================
autoload -Uz compinit

# Only regenerate .zcompdump once per day
if [[ -n "${ZDOTDIR:-$HOME}/.zcompdump"(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi

setopt COMPLETE_IN_WORD       # complete from both ends
setopt AUTO_MENU              # show menu on second Tab
setopt ALWAYS_TO_END          # move cursor to end after completion
setopt AUTO_PARAM_SLASH       # add / after directory completions

# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Colored completion menu
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select

# Group completions by category
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'

# ============================================================
# Prompt
# ============================================================
autoload -Uz vcs_info
zstyle ':vcs_info:git:*' formats ' %F{yellow}(%b)%f'
zstyle ':vcs_info:*' enable git

precmd() { vcs_info }

setopt PROMPT_SUBST
PROMPT='%F{green}%n%f@%F{blue}%m%f %F{cyan}%2~%f${vcs_info_msg_0_} %(?.%F{green}.%F{red})%#%f '
RPROMPT='%F{red}%(?..%? )%f%F{yellow}%*%f'

# ============================================================
# Key Bindings
# ============================================================
bindkey -e   # emacs key bindings (default)

# Better history search
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search    # up arrow
bindkey '^[[B' down-line-or-beginning-search  # down arrow
bindkey '^[^[[A' history-beginning-search-backward  # alt+up
bindkey '^[^[[B' history-beginning-search-forward   # alt+down
bindkey '^[[1;5C' forward-word   # ctrl+right
bindkey '^[[1;5D' backward-word  # ctrl+left

# ============================================================
# Aliases
# ============================================================
# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Listing
alias ls='ls --color=auto'
alias ll='ls -lah'
alias la='ls -A'
alias lt='ls -lth'   # sort by time

# Safety
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

# Common shortcuts
alias g='git'
alias d='docker'
alias k='kubectl'
alias tf='terraform'

# Reload config
alias reload='source ~/.zshrc && echo "Reloaded ~/.zshrc"'

# Grep with colors
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Show size of items in current dir, sorted
alias duu='du -sh * | sort -h'

# IP addresses
alias myip='curl -s https://ipinfo.io/ip'
alias localip='ipconfig getifaddr en0 2>/dev/null || hostname -I | awk "{print \$1}"'

# ============================================================
# Functions
# ============================================================

# Create directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract archives
extract() {
    local file="$1"
    [[ -f "$file" ]] || { echo "Not a file: $file" >&2; return 1 }
    case "$file" in
        *.tar.bz2)  tar xjf "$file"  ;;
        *.tar.gz)   tar xzf "$file"  ;;
        *.tar.xz)   tar xJf "$file"  ;;
        *.tar)      tar xf  "$file"  ;;
        *.bz2)      bunzip2 "$file"  ;;
        *.gz)       gunzip  "$file"  ;;
        *.zip)      unzip   "$file"  ;;
        *.7z)       7z x    "$file"  ;;
        *.rar)      unrar x "$file"  ;;
        *)          echo "Unknown archive: $file" >&2; return 1 ;;
    esac
}

# Quick web search from terminal
search() {
    local query="${(j:+:)@}"
    local url="https://www.google.com/search?q=${query}"
    if (( $+commands[open] )); then
        open "$url"
    elif (( $+commands[xdg-open] )); then
        xdg-open "$url"
    else
        echo "$url"
    fi
}

# Show PATH entries, one per line
path() {
    echo "${PATH//:/$'\n'}"
}

# ============================================================
# Environment Variables
# ============================================================
export EDITOR="vim"
export VISUAL="$EDITOR"
export PAGER="less"
export LESS="-R --quit-if-one-screen"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# ============================================================
# Load Local Customizations (not tracked by VCS)
# ============================================================
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# ============================================================
# End: print startup time if profiling
# ============================================================
[[ -n "${DEBUG_STARTUP:-}" ]] && zprof
