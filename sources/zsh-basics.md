# Zsh Basics

## Overview
Zsh (Z Shell) is a powerful Unix shell that serves as both an interactive login shell and a command interpreter for shell scripting. It's an extended Bourne shell with many improvements.

## Key Features

### 1. Command Line Editing
- Vi and Emacs editing modes
- Multi-line command editing
- Powerful tab completion system
- Spell correction for commands and arguments

### 2. Globbing and Pattern Matching
- Extended glob patterns with qualifiers
- Recursive globbing with `**`
- Numeric ranges in patterns
- Glob qualifiers for filtering results

### 3. Scripting Features
- Associative arrays (hash tables)
- Floating point arithmetic
- Advanced parameter expansion
- Function autoloading

## Basic Syntax

### Variables
```zsh
# Variable assignment (no spaces around =)
name="value"

# Using variables
echo $name
echo ${name}

# Arrays
array=(one two three)
echo $array[1]  # First element (1-indexed)
```

### Conditionals
```zsh
# If statement
if [[ condition ]]; then
    # commands
elif [[ other_condition ]]; then
    # commands
else
    # commands
fi

# Test operators
[[ -f file ]]      # File exists
[[ -d directory ]] # Directory exists
[[ $a == $b ]]     # String equality
[[ $a -eq $b ]]    # Numeric equality
```

### Loops
```zsh
# For loop
for item in $array; do
    echo $item
done

# While loop
while [[ condition ]]; do
    # commands
done

# Repeat command
repeat 5 echo "Hello"
```

### Functions
```zsh
# Function definition
function_name() {
    local var="local variable"
    echo "Arguments: $@"
    return 0
}

# Alternative syntax
function function_name {
    # commands
}
```

## Environment and Configuration

### Configuration Files
- `~/.zshenv` - Always sourced, environment variables
- `~/.zprofile` - Sourced for login shells
- `~/.zshrc` - Sourced for interactive shells
- `~/.zlogin` - Sourced for login shells (after zshrc)
- `~/.zlogout` - Sourced when login shell exits

### Common Environment Variables
```zsh
PATH="/usr/local/bin:$PATH"
EDITOR="vim"
LANG="en_US.UTF-8"
```

## Useful Built-in Commands

### Directory Navigation
```zsh
cd -        # Go to previous directory
pushd dir   # Push directory onto stack
popd        # Pop directory from stack
dirs -v     # Show directory stack
```

### Parameter Expansion
```zsh
${var:-default}      # Use default if var is unset
${var:=default}      # Set and use default if var is unset
${var:+alternate}    # Use alternate if var is set
${#var}              # Length of var
${var%pattern}       # Remove shortest match from end
${var%%pattern}      # Remove longest match from end
${var#pattern}       # Remove shortest match from start
${var##pattern}      # Remove longest match from start
```

## Resources
- Official documentation: https://zsh.sourceforge.io/Doc/
- Zsh Guide: https://zsh.sourceforge.io/Guide/
- Arch Wiki Zsh: https://wiki.archlinux.org/title/Zsh
