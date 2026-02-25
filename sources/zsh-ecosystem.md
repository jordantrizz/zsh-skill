# Zsh Ecosystem

## Popular Frameworks

### Oh My Zsh

Oh My Zsh is the most popular Zsh framework with a large community, hundreds of plugins, and many themes.

**Installation:**
```zsh
# Install via curl
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install via wget
sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
```

**Configuration (`~/.zshrc`):**
```zsh
# Set theme
ZSH_THEME="robbyrussell"

# Enable plugins
plugins=(git docker kubectl python pip brew)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Custom aliases after loading OMZ
alias ll="ls -lah"
```

**Key Directories:**
- `~/.oh-my-zsh/themes/` — Built-in themes
- `~/.oh-my-zsh/plugins/` — Built-in plugins
- `~/.oh-my-zsh/custom/themes/` — User themes
- `~/.oh-my-zsh/custom/plugins/` — User plugins

**Updating:**
```zsh
omz update
```

---

### Prezto

Prezto is a lighter, faster alternative to Oh My Zsh with a modular design.

**Installation:**
```zsh
# Clone the repo
git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"

# Create symlinks
setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
    ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done

# Start a new Zsh session
zsh
```

**Configuration (`~/.zpreztorc`):**
```zsh
# Set modules to load (order matters)
zstyle ':prezto:load' pmodule \
    'environment' \
    'terminal' \
    'editor' \
    'history' \
    'directory' \
    'spectrum' \
    'utility' \
    'completion' \
    'prompt'

# Set theme
zstyle ':prezto:module:prompt' theme 'sorin'
```

---

### Zinit (formerly zplugin)

Zinit is a fast, feature-rich plugin manager for Zsh with turbo mode for async loading.

**Installation:**
```zsh
bash -c "$(curl --fail --show-error --silent --location \
    https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
```

**Configuration (`~/.zshrc`):**
```zsh
# Load zinit
source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"

# Load plugins
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions

# Turbo mode (async loading)
zinit wait lucid light-mode for \
    atinit"zicompinit; zicdreplay" \
    zdharma-continuum/fast-syntax-highlighting \
    blockf \
    zsh-users/zsh-completions \
    atload"!_zsh_autosuggest_start" \
    zsh-users/zsh-autosuggestions

# Load snippets from Oh My Zsh
zinit snippet OMZP::git
zinit snippet OMZP::docker
```

---

### Antigen

Antigen is a plugin manager modeled after Vundle (Vim's plugin manager).

**Installation:**
```zsh
curl -L git.io/antigen > ~/antigen.zsh
```

**Configuration (`~/.zshrc`):**
```zsh
source ~/antigen.zsh

# Load Oh My Zsh library
antigen use oh-my-zsh

# Load bundles (plugins)
antigen bundle git
antigen bundle docker
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-syntax-highlighting

# Set theme
antigen theme robbyrussell

# Apply changes
antigen apply
```

---

### Zim (Zsh IMproved Framework)

Zim is one of the fastest Zsh frameworks, optimized for quick shell startup.

**Installation:**
```zsh
curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh
```

**Configuration (`~/.zimrc`):**
```zsh
# Set theme
zmodule duration-info
zmodule git-info
zmodule prompt-pwd
zmodule eriner    # theme

# Load modules
zmodule environment
zmodule input
zmodule termtitle
zmodule utility
zmodule completion

# Load plugins
zmodule zsh-users/zsh-autosuggestions
zmodule zsh-users/zsh-syntax-highlighting
```

**Updating:**
```zsh
zimfw upgrade
zimfw update
```

---

### Sheldon

Sheldon is a fast, configurable shell plugin manager written in Rust.

**Installation:**
```zsh
curl --proto '=https' -fLsS https://rossmacarthur.github.io/install/crate.sh \
    | bash -s -- --repo rossmacarthur/sheldon --to ~/.local/bin
```

**Configuration (`~/.config/sheldon/plugins.toml`):**
```toml
shell = "zsh"

[plugins.zsh-autosuggestions]
github = "zsh-users/zsh-autosuggestions"

[plugins.zsh-syntax-highlighting]
github = "zsh-users/zsh-syntax-highlighting"

[plugins.pure]
github = "sindresorhus/pure"
use = ["{async,pure}.zsh"]
```

## Plugin Management

### Essential Plugins

**Productivity:**
```zsh
# zsh-autosuggestions: Fish-like suggestions from history
# Install with your plugin manager, then:
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#999"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# zsh-syntax-highlighting: Syntax color in command line
# Must be sourced LAST in .zshrc

# zsh-history-substring-search: Search history by substring
bindkey '^[[A' history-substring-search-up    # up arrow
bindkey '^[[B' history-substring-search-down  # down arrow

# fzf: Fuzzy finder integration
# After installing fzf, add key bindings:
source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh
```

**Git Integration:**
```zsh
# Oh My Zsh git plugin provides many aliases
# Common ones:
# ga    = git add
# gcmsg = git commit -m
# gst   = git status
# glog  = git log --oneline --decorate --graph
# gp    = git push
# gl    = git pull
```

**Directory Navigation:**
```zsh
# zoxide: smarter cd command
# Install: https://github.com/ajeetdsouza/zoxide
eval "$(zoxide init zsh)"
# Now use: z project  (instead of cd ~/dev/myproject)

# autojump: jump to frequently visited directories
[[ -s /usr/share/autojump/autojump.zsh ]] && source /usr/share/autojump/autojump.zsh
```

### Writing Custom Plugins

```zsh
# Create plugin directory
mkdir -p ~/.oh-my-zsh/custom/plugins/myplugin

# Create plugin file
cat > ~/.oh-my-zsh/custom/plugins/myplugin/myplugin.plugin.zsh << 'EOF'
# My custom plugin

# Aliases
alias myalias='echo "my plugin alias"'

# Functions
myfunction() {
    echo "Hello from my plugin: $*"
}

# Completions (optional)
_myfunction() {
    _arguments \
        '--option[description]:value:(val1 val2)' \
        '*:argument:_files'
}
compdef _myfunction myfunction
EOF

# Add to plugins list in ~/.zshrc
plugins=(... myplugin)
```

### Plugin Compatibility

```zsh
# Check if a plugin is loaded (Oh My Zsh)
if (( $+functions[omz] )); then
    omz plugin list
fi

# Conditionally load based on command availability
if (( $+commands[kubectl] )); then
    plugins+=(kubectl)
fi

# Safe plugin function override
# Call original function from override
if (( $+functions[_original_func] )); then
    _original_func_backup="$(typeset -f _original_func)"
fi
```

## Theme Systems

### Prompt Customization

**Basic PROMPT:**
```zsh
# Simple custom prompt
PROMPT='%F{green}%n@%m%f:%F{blue}%~%f$ '

# Prompt expansion codes
# %n  - username
# %m  - hostname (short)
# %M  - hostname (full)
# %~  - current directory (~ for home)
# %/  - current directory (full path)
# %d  - current directory (full path, alias for %/)
# %!  - history event number
# %?  - exit code of last command
# %#  - # for root, % for others
# %t  - current time (12-hour)
# %T  - current time (24-hour)
# %*  - current time with seconds

# Colors in prompts
# %F{color}text%f  - foreground color
# %K{color}text%k  - background color
# %B text %b       - bold
# %U text %u       - underline
# Colors: black red green yellow blue magenta cyan white
# Also: 256-color numbers (0-255)
```

**Multiline Prompt:**
```zsh
# Two-line prompt with git info
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats '%F{yellow}(%b)%f '

setopt PROMPT_SUBST
PROMPT='%F{green}%n%f@%F{blue}%m%f %F{cyan}%~%f ${vcs_info_msg_0_}
%# '
```

### Popular Themes

**Powerlevel10k:**
```zsh
# Most popular theme - fast, highly configurable
# Install:
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# In ~/.zshrc:
ZSH_THEME="powerlevel10k/powerlevel10k"

# Run configuration wizard:
p10k configure
```

**Starship:**
```zsh
# Cross-shell prompt written in Rust
# Install:
curl -sS https://starship.rs/install.sh | sh

# Add to ~/.zshrc:
eval "$(starship init zsh)"

# Configure in ~/.config/starship.toml
```

**Pure:**
```zsh
# Minimal, elegant prompt
# Install via plugin manager or:
npm install --global pure-prompt

# In ~/.zshrc:
autoload -U promptinit; promptinit
prompt pure
```

### Creating a Custom Theme

```zsh
# Save as ~/.oh-my-zsh/custom/themes/mytheme.zsh-theme

# Helper functions
_git_prompt_info() {
    local branch
    branch=$(git symbolic-ref --short HEAD 2>/dev/null) || return
    echo " %F{yellow}($branch)%f"
}

_exit_code_prompt() {
    local code=$?
    (( code )) && echo " %F{red}[$code]%f"
}

# Configure vcs_info
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats ' %F{yellow}(%b)%f'

# Hook to update vcs_info
precmd() {
    vcs_info
}

# Set prompts
setopt PROMPT_SUBST

PROMPT='%F{green}%n%f@%F{cyan}%m%f %F{blue}%2~%f${vcs_info_msg_0_} %# '
RPROMPT='%F{red}%(?..%?)%f'
```

## Additional Tools

### Completion Tools

```zsh
# carapace: multi-shell completion bridge
# https://github.com/carapace-sh/carapace-bin
carapace _carapace zsh | source /dev/stdin

# navi: interactive cheatsheet tool
# https://github.com/denisidoro/navi
eval "$(navi widget zsh)"
```

### Environment Managers

```zsh
# direnv: load .envrc automatically on cd
eval "$(direnv hook zsh)"

# asdf: manage multiple runtime versions
source $(brew --prefix asdf)/libexec/asdf.sh
# or
source ~/.asdf/asdf.sh

# pyenv, rbenv, nodenv - language version managers
eval "$(pyenv init -)"
eval "$(rbenv init -)"
```

### Shell Utilities

```zsh
# bat: cat with syntax highlighting
alias cat='bat --style=plain'

# eza/exa: modern ls replacement
alias ls='eza --icons'
alias ll='eza -la --icons'

# ripgrep: fast grep replacement
alias grep='rg'

# fd: fast find replacement
alias find='fd'

# delta: better git diff
git config --global core.pager delta
```

## Resources
- Oh My Zsh: https://ohmyz.sh/
- Prezto: https://github.com/sorin-ionescu/prezto
- Zinit: https://github.com/zdharma-continuum/zinit
- Zim: https://zimfw.sh/
- Powerlevel10k: https://github.com/romkatv/powerlevel10k
- Starship: https://starship.rs/
- Awesome Zsh Plugins: https://github.com/unixorn/awesome-zsh-plugins
