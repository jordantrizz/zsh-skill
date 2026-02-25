# Zsh Advanced Topics

## Advanced Globbing

### Glob Qualifiers
Zsh's glob qualifiers allow powerful file filtering:

```zsh
# Glob qualifiers follow pattern in parentheses
*(..)          # Regular files only
*(/)           # Directories only
*(*)           # Executable files
*(@)           # Symbolic links
*(L0)          # Empty files (zero length)
*(Lk+10)       # Files larger than 10 KB
*(mh-1)        # Files modified in last hour
*(om[1,3])     # Three newest files (by modification)
*(^m0)         # Not modified today
```

### Extended Globbing
```zsh
# Enable extended globbing
setopt EXTENDED_GLOB

# Pattern matching
^*.txt         # All except .txt files
**/*.py        # Recursive search for .py files
*.txt~file.txt # All .txt files except file.txt
(foo|bar)*     # Files starting with foo or bar
<1-10>.txt     # Files named 1.txt through 10.txt
```

## Completion System

### Basic Completion Setup
```zsh
# Initialize completion system
autoload -Uz compinit
compinit

# Completion options
setopt COMPLETE_IN_WORD    # Complete from both ends
setopt AUTO_MENU           # Show menu on second tab
setopt ALWAYS_TO_END       # Move cursor after completion
```

### Custom Completions
```zsh
# Define custom completion
_mycommand() {
    local -a options
    options=(
        'start:Start the service'
        'stop:Stop the service'
        'restart:Restart the service'
    )
    _describe 'command' options
}

# Register completion
compdef _mycommand mycommand
```

## Associative Arrays (Hash Tables)

```zsh
# Declare associative array
typeset -A hash

# Add entries
hash[key1]="value1"
hash[key2]="value2"

# Access values
echo $hash[key1]

# Iterate over keys
for key in ${(k)hash}; do
    echo "$key: $hash[$key]"
done

# Iterate over key-value pairs
for key value in ${(kv)hash}; do
    echo "$key -> $value"
done
```

## Parameter Expansion Flags

```zsh
# Split on whitespace
${=var}

# Split on custom separator
${(s/:/)var}

# Join array elements
${(j/:/)array}

# Lowercase/uppercase conversion
${(L)var}    # Lowercase
${(U)var}    # Uppercase

# Sorting
${(o)array}  # Sort ascending
${(O)array}  # Sort descending

# Unique elements
${(u)array}
```

## Zsh Hooks

Hooks allow executing functions at specific points:

```zsh
# Before executing command
preexec() {
    echo "Executing: $1"
}

# Before displaying prompt
precmd() {
    # Update terminal title, etc.
}

# When changing directory
chpwd() {
    echo "Changed to: $PWD"
}

# When command is not found
command_not_found_handler() {
    echo "Command '$1' not found"
    return 127
}
```

## Modules and Autoloading

### Loading Modules
```zsh
# Load zsh modules
zmodload zsh/datetime  # Date/time functions
zmodload zsh/mathfunc  # Mathematical functions
zmodload zsh/stat      # File stat functions

# Use datetime module
echo $EPOCHSECONDS     # Unix timestamp
strftime "%Y-%m-%d" $EPOCHSECONDS
```

### Function Autoloading
```zsh
# Mark functions for autoload
autoload -Uz function_name

# Autoload from fpath
fpath=(/path/to/functions $fpath)
autoload -Uz /path/to/functions/*(.:t)
```

## Advanced Scripting Patterns

### Error Handling
```zsh
# Exit on error
setopt ERR_EXIT

# Trap errors
trap 'echo "Error on line $LINENO"' ERR

# Check command success
if command; then
    echo "Success"
else
    echo "Failed with code $?"
fi
```

### Named Pipes (FIFOs)
```zsh
# Process substitution
diff <(ls dir1) <(ls dir2)

# Command substitution
output=$(command)
output=`command`
```

### Anonymous Functions
```zsh
# Inline anonymous function
() {
    local temp="temporary"
    echo $temp
}  # Variables don't leak

# With parameters
() {
    echo "Args: $@"
} arg1 arg2
```

## Performance Optimization

### Lazy Loading
```zsh
# Defer loading until first use
function nvm {
    unfunction nvm
    source /usr/share/nvm/init-nvm.sh
    nvm "$@"
}
```

### Compilation
```zsh
# Compile zsh files for faster loading
zcompile ~/.zshrc
zcompile ~/.zsh/functions/*
```

## Zsh Line Editor (ZLE)

### Custom Widgets
```zsh
# Create custom widget
my-widget() {
    LBUFFER+="text"
}
zle -N my-widget

# Bind to key
bindkey '^X^T' my-widget
```

### ZLE Commands
```zsh
# Common ZLE commands
zle clear-screen
zle reset-prompt
zle accept-line
zle backward-word
zle forward-word
```

## Resources
- Zsh Line Editor: https://zsh.sourceforge.io/Doc/Release/Zsh-Line-Editor.html
- Completion System: https://zsh.sourceforge.io/Doc/Release/Completion-System.html
- Expansion: https://zsh.sourceforge.io/Doc/Release/Expansion.html
