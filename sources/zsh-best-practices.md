# Zsh Best Practices

## Script Structure

### Shebang and Options
```zsh
#!/usr/bin/env zsh
# Use env for portability

# Set strict mode
setopt ERR_EXIT      # Exit on error
setopt NO_UNSET      # Error on undefined variables
setopt PIPE_FAIL     # Fail pipe if any command fails
```

### Script Template
```zsh
#!/usr/bin/env zsh

# Script metadata
# Description: What this script does
# Author: Your name
# Version: 1.0.0

# Strict mode
setopt ERR_EXIT NO_UNSET PIPE_FAIL

# Global variables
readonly SCRIPT_DIR="${0:A:h}"
readonly SCRIPT_NAME="${0:t}"

# Functions
usage() {
    cat << EOF
Usage: $SCRIPT_NAME [options] arguments

Description of script

Options:
    -h, --help     Show this help message
    -v, --verbose  Enable verbose output
EOF
}

main() {
    # Main script logic
    local arg="$1"
    
    # Your code here
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        -v|--verbose)
            VERBOSE=1
            shift
            ;;
        *)
            break
            ;;
    esac
done

# Run main function
main "$@"
```

## Coding Standards

### Naming Conventions
```zsh
# Variables: lowercase with underscores
local user_name="john"
local file_path="/path/to/file"

# Constants: uppercase
readonly MAX_RETRIES=3
readonly CONFIG_FILE="config.ini"

# Functions: lowercase with underscores
function process_data() {
    # ...
}

# Private functions: prefix with underscore
function _internal_helper() {
    # ...
}
```

### Variable Quoting
```zsh
# Always quote variables to prevent word splitting
echo "$variable"
[[ "$var" == "$other" ]]

# Use arrays for lists
files=( file1.txt file2.txt )
for file in "${files[@]}"; do
    echo "$file"
done

# Quote command substitution
output="$(command)"
```

### Use Local Variables
```zsh
function my_function() {
    # Declare local variables
    local temp_file
    local -i counter=0
    local -a items
    local -A config
    
    # Function logic
}
```

## Error Handling

### Check Command Success
```zsh
# Method 1: if statement
if ! command; then
    echo "Command failed" >&2
    return 1
fi

# Method 2: || operator
command || {
    echo "Command failed" >&2
    return 1
}

# Method 3: check exit code
command
if [[ $? -ne 0 ]]; then
    echo "Command failed" >&2
    return 1
fi
```

### Validation
```zsh
# Validate arguments
function process_file() {
    local file="$1"
    
    if [[ -z "$file" ]]; then
        echo "Error: File argument required" >&2
        return 1
    fi
    
    if [[ ! -f "$file" ]]; then
        echo "Error: File not found: $file" >&2
        return 1
    fi
    
    # Process file
}
```

### Cleanup on Exit
```zsh
# Trap for cleanup
cleanup() {
    rm -f "$temp_file"
    echo "Cleanup completed"
}
trap cleanup EXIT INT TERM

# Create temporary file
temp_file=$(mktemp)
```

## Performance Tips

### Avoid External Commands
```zsh
# Bad - spawns subprocess
length=$(echo "$string" | wc -c)

# Good - use built-in
length=${#string}

# Bad - external basename
name=$(basename "$path")

# Good - parameter expansion
name="${path:t}"
```

### Use Built-in Features
```zsh
# String manipulation
${string//search/replace}  # Replace all
${string/#prefix/}         # Remove prefix
${string/%suffix/}         # Remove suffix

# Math operations
(( result = 5 + 3 ))
(( counter++ ))

# Pattern matching
[[ $file == *.txt ]]
```

### Efficient Loops
```zsh
# Use glob instead of ls
for file in *.txt; do
    [[ -f "$file" ]] || continue
    process_file "$file"
done

# Use read for file processing
while IFS= read -r line; do
    process_line "$line"
done < file.txt
```

## Portability Considerations

### Feature Detection
```zsh
# Check if feature is available
if (( $+commands[git] )); then
    # git is available
fi

# Check if function exists
if (( $+functions[my_func] )); then
    # function is defined
fi

# Check if variable is set
if (( $+var_name )); then
    # variable is set
fi
```

### POSIX Compatibility
```zsh
# When POSIX compatibility needed
emulate sh
# or
#!/bin/sh

# Stick to POSIX features
[ "$var" = "value" ]  # Not [[ ]]
test -f "$file"       # Not [[ -f ]]
```

## Security Best Practices

### Avoid eval
```zsh
# Bad - security risk
eval "$user_input"

# Good - use arrays or other methods
cmd=( command arg1 arg2 )
"${cmd[@]}"
```

### Safe Temporary Files
```zsh
# Use mktemp for temp files
temp_file=$(mktemp) || {
    echo "Failed to create temp file" >&2
    exit 1
}

# Secure permissions
chmod 600 "$temp_file"
```

### Input Validation
```zsh
# Validate user input
read -r user_input

# Whitelist validation
if [[ ! "$user_input" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    echo "Invalid input" >&2
    exit 1
fi
```

## Testing and Debugging

### Debug Mode
```zsh
# Enable debug output
setopt XTRACE

# Debug specific section
{
    setopt LOCAL_OPTIONS XTRACE
    # code to debug
}

# Conditional debugging
[[ -n "$DEBUG" ]] && setopt XTRACE
```

### Assertions
```zsh
# Simple assertion function
assert() {
    if ! "$@"; then
        echo "Assertion failed: $*" >&2
        exit 1
    fi
}

# Usage
assert [[ -f "$config_file" ]]
assert (( count > 0 ))
```

### Testing Functions
```zsh
# Simple test framework
test_function_name() {
    local result
    result=$(function_to_test arg1 arg2)
    
    if [[ "$result" == "expected" ]]; then
        echo "✓ test_function_name passed"
    else
        echo "✗ test_function_name failed"
        echo "  Expected: expected"
        echo "  Got: $result"
        return 1
    fi
}
```

## Documentation

### Function Documentation
```zsh
# Document functions with comments
# Usage: process_file <file> [options]
# Description: Process the given file
# Arguments:
#   $1 - File path to process
#   $2 - Optional processing mode
# Returns:
#   0 on success, 1 on error
# Example:
#   process_file input.txt fast
function process_file() {
    # Implementation
}
```

### Inline Comments
```zsh
# Use comments to explain WHY, not WHAT
# Good
# Retry 3 times because API is occasionally unreliable
for i in {1..3}; do
    api_call && break
done

# Not needed - code is self-explanatory
# Set counter to 0
counter=0
```

## Resources
- Google Shell Style Guide: https://google.github.io/styleguide/shellguide.html
- Zsh Development Guide: https://zsh.sourceforge.io/Guide/
