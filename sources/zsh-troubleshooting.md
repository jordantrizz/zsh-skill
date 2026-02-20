# Zsh Troubleshooting Guide

## Common Errors and Solutions

### "command not found" Errors

**Problem:** A command you installed isn't found.

```zsh
# Diagnosis
echo $PATH
which command_name
whence -v command_name

# Solution: Add directory to PATH
export PATH="/usr/local/bin:$PATH"

# For persistent fix, add to ~/.zshenv
echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.zshenv

# Reload configuration
source ~/.zshenv
```

**Problem:** Function or alias not found in scripts.

```zsh
# Scripts don't source ~/.zshrc by default
# Solution 1: Source explicitly
source ~/.zshrc

# Solution 2: Use zsh -i (interactive mode) — avoid this in production
zsh -i -c "my_function"

# Solution 3: Move shared functions to ~/.zshenv or a sourced library
source ~/.zsh/lib/functions.zsh
```

### "bad pattern" / Globbing Errors

**Problem:** Glob pattern matches nothing and causes an error.

```zsh
# Error: zsh: no matches found: *.txt
# Solution 1: Use NULL_GLOB option
setopt NULL_GLOB
for f in *.txt; do ... done

# Solution 2: Check before looping
local -a files=(*.txt)
(( ${#files} )) || { echo "No files found"; return }

# Solution 3: Disable globbing for specific command
noglob find . -name "*.txt"
```

**Problem:** Special characters in filenames cause issues.

```zsh
# Always quote variables
file="name with spaces.txt"
cat "$file"          # correct
cat $file            # wrong - word splits

# Use arrays for file lists
local -a files=("file 1.txt" "file 2.txt")
for f in "${files[@]}"; do
    cat "$f"
done
```

### "unbound variable" Errors

**Problem:** Script exits when accessing undefined variable (with `NO_UNSET`).

```zsh
# Check if variable is set before using
if [[ -v MY_VAR ]]; then
    echo "$MY_VAR"
fi

# Use default value
echo "${MY_VAR:-default_value}"

# Set variable only if unset
: "${MY_VAR:=default_value}"
```

### Quoting and Escaping Issues

**Problem:** String with special characters behaves unexpectedly.

```zsh
# Understand quoting rules
echo "Double quotes: $var is expanded"
echo 'Single quotes: $var is literal'
echo $'Escape sequences:\n\ttab'

# Safely pass arguments with special chars
local -a args=("--message" "fix: resolve issue #42 (urgent)")
git commit "${args[@]}"

# Heredoc with no expansion
cat << 'EOF'
No $expansion here
EOF

# Heredoc with expansion
cat << EOF
HOME is $HOME
EOF
```

### Function Scoping Issues

**Problem:** Variables leak between functions.

```zsh
# Bad: global variable pollution
my_func() {
    temp="some value"   # global!
}

# Good: always declare local
my_func() {
    local temp="some value"
    local -i count=0
    local -a items=()
    local -A map=()
}
```

**Problem:** Return values not captured correctly.

```zsh
# Functions return exit codes (0-255), not strings
# Use command substitution for string return values
get_value() {
    echo "result"         # print the value
}
local result
result=$(get_value)       # capture via subshell

# For numeric results, use a nameref (Zsh 5.1+)
get_count() {
    local -n _result_ref=$1
    _result_ref=42
}
local count
get_count count
echo "$count"             # 42
```

### Array Problems

**Problem:** Array indexing confusion.

```zsh
# Zsh arrays are 1-indexed by default (unlike bash's 0-indexed)
local -a arr=(a b c)
echo $arr[1]       # "a" (first element)
echo $arr[0]       # "" (empty - no element 0)
echo $arr[-1]      # "c" (last element)
echo $arr[2,3]     # "b c" (slice)

# Make 0-indexed if needed (for porting bash scripts)
local -a arr
arr[0]="first"
# or
setopt KSH_ARRAYS  # use with caution - changes global behavior
```

**Problem:** Array expansion without quotes.

```zsh
local -a files=("file 1.txt" "file 2.txt")

# Wrong: breaks on spaces
for f in $files; do echo "$f"; done

# Correct: preserves elements
for f in "${files[@]}"; do echo "$f"; done

# Pass array to function
process_files "${files[@]}"
```

### Subshell Side Effects

**Problem:** Variable assignments in subshells don't propagate.

```zsh
# Bad: assignment happens in subshell
result=""
echo "hello" | read result   # result stays empty!

# Good: use process substitution
read result < <(echo "hello")
echo "$result"  # "hello"

# Or use a temp variable via command substitution
result=$(echo "hello")
```

### Startup / Configuration Issues

**Problem:** Changes to `.zshrc` don't take effect.

```zsh
# Reload without restarting
source ~/.zshrc
# or
exec zsh

# Debug which files are sourced
zsh -xvli 2>&1 | head -50

# Check for syntax errors
zsh -n ~/.zshrc
```

**Problem:** Slow shell startup.

```zsh
# Profile startup time
zsh -i -c 'zprof' 2>&1 | head -30

# Or add to top of .zshrc:
zmodload zsh/zprof
# ... your config ...
# At the end:
zprof
```

## Debugging Techniques

### Trace Execution

```zsh
# Enable xtrace (prints each command before execution)
setopt XTRACE

# Debug a specific section only
{
    setopt LOCAL_OPTIONS XTRACE
    problematic_code
}

# From the command line
zsh -x myscript.zsh

# Debug with line numbers
PS4='%x:%I> '   # file:line>
setopt XTRACE
```

### Verbose Mode

```zsh
# Print lines as they are read (before execution)
setopt VERBOSE

# Combine with XTRACE for maximum output
setopt VERBOSE XTRACE
```

### Print Variables

```zsh
# Print variable value and type
typeset -p variable_name

# Print all local variables in scope
typeset

# Print functions
typeset -f function_name
functions function_name

# Print all defined functions
typeset -f
```

### Dry Run Pattern

```zsh
# Implement a --dry-run flag
DRY_RUN=0

run_cmd() {
    if (( DRY_RUN )); then
        echo "[DRY RUN] $*"
    else
        "$@"
    fi
}

# Usage
run_cmd rm -rf /tmp/old_data
run_cmd cp source.txt dest.txt
```

### Testing with zsh -n

```zsh
# Syntax check without executing
zsh -n myscript.zsh

# Check multiple files
for f in scripts/*.zsh; do
    zsh -n "$f" || echo "Syntax error in: $f"
done
```

### Adding Debug Breakpoints

```zsh
# Simple breakpoint function
breakpoint() {
    echo "=== BREAKPOINT: ${funcfiletrace[1]} ===" >&2
    echo "  Function: ${funcstack[2]}" >&2
    echo "  Press Enter to continue, 'q' to quit" >&2
    local input
    read -r input
    [[ "$input" == "q" ]] && exit 1
}

# Usage in code
my_function() {
    local data="$(fetch_data)"
    breakpoint  # pause here to inspect
    process "$data"
}
```

### Checking Exit Codes

```zsh
# Print exit code after each command
setopt PRINT_EXIT_VALUE

# Check specific exit code
command_that_might_fail
echo "Exit code: $?"

# Trap on error
trap 'echo "Error at line $LINENO: exit code $?"' ERR
```

## Performance Issues

### Diagnosing Slow Scripts

```zsh
# Time a command or function
time my_slow_function

# Detailed profiling with zprof
zmodload zsh/zprof
my_slow_function
zprof | head -20

# Benchmark with TIMEFMT
TIMEFMT='%J: %*Es elapsed, %P CPU'
time { for i in {1..1000}; do echo $i; done > /dev/null }
```

### Common Performance Anti-patterns

```zsh
# SLOW: Calling external commands in a loop
for file in *; do
    size=$(du -sh "$file" | cut -f1)  # spawns 2 processes per iteration
    echo "$file: $size"
done

# FAST: Use zsh built-ins
zmodload zsh/stat
for file in *; do
    zstat -H stat "$file"
    echo "$file: $stat[size] bytes"
done

# SLOW: Useless use of cat
cat file.txt | grep "pattern"

# FAST: Redirect directly
grep "pattern" file.txt

# SLOW: Subshell for string manipulation
lower=$(echo "$string" | tr '[:upper:]' '[:lower:]')

# FAST: Parameter expansion flag
lower="${(L)string}"

# SLOW: External command for length
len=$(echo -n "$string" | wc -c)

# FAST: Built-in
len=${#string}
```

### Startup Performance

```zsh
# Lazy-load expensive initializations
nvm() {
    unfunction nvm
    export NVM_DIR="$HOME/.nvm"
    [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
    nvm "$@"
}

# Compile zsh files for faster loading
zcompile ~/.zshrc
for f in ~/.zsh/functions/*; do
    zcompile "$f"
done

# Only run compinit once per day
autoload -Uz compinit
if [[ -n "${ZDOTDIR:-$HOME}/.zcompdump"(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi
```

### Memory Usage

```zsh
# Avoid loading large files into memory
# Bad: reads entire file
local content
content=$(cat large_file.txt)
process "$content"

# Good: stream processing
while IFS= read -r line; do
    process_line "$line"
done < large_file.txt

# Unset large variables when done
local -a big_array=(...)
# ... use big_array ...
unset big_array
```

## Common Zsh vs Bash Differences

### Array Indexing

```zsh
# Zsh: 1-indexed
arr=(a b c)
echo $arr[1]  # "a"

# Bash: 0-indexed
arr=(a b c)
echo ${arr[0]}  # "a"

# Solution: use setopt KSH_ARRAYS for bash compatibility
# or simply start your Zsh arrays at index 1
```

### Glob Expansion Differences

```zsh
# Zsh fails on no match (unlike bash which passes the literal pattern)
# bash: ls *.xyz -> "ls: cannot access *.xyz: ..."
# zsh: ls *.xyz -> "zsh: no matches found: *.xyz"

# Make zsh behave like bash
setopt NO_NOMATCH
# or per-command
ls *.xyz 2>/dev/null
```

### `local` in Functions

```zsh
# Both bash and zsh support local, but zsh also supports typeset
function my_func {
    local  str_var="hello"
    local -i int_var=42
    local -a arr_var=(1 2 3)
    local -A map_var=([key]=value)
    typeset -r readonly_var="constant"
}
```

## Resources
- Zsh FAQ: https://zsh.sourceforge.io/FAQ/
- Zsh Workers Mailing List: https://www.zsh.org/mla/workers/
- ShellCheck (linting): https://www.shellcheck.net/
- Zsh Documentation: https://zsh.sourceforge.io/Doc/Release/
