# Zsh Version Compatibility

<!-- semantic-tags: version, compatibility, migration, zsh5 -->

## Version Compatibility Matrix

The table below summarises feature availability across common Zsh releases.
Use `zsh --version` to confirm the version on any target system.

| Feature | 5.0 | 5.1 | 5.2 | 5.3 | 5.4 | 5.5 | 5.6 | 5.7 | 5.8 | 5.9 |
|---------|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| `typeset -A` (associative arrays) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| `${0:A}` absolute path expansion | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| `zparseopts` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| `zsh/zutil` (`zformat`, `zregexparse`) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| `zsh/datetime` (`strftime`) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| `zsh/zprof` (profiling) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| `zsh/param/private` (`private` keyword) | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| `WARN_NESTED_VAR` option | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| `TYPESET_SILENT` option | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| `set -o pipefail` (PIPE_FAIL) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| `${var//pattern/replacement}` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| `(( expr ))` arithmetic | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| `vared` built-in | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Regex `=~` in `[[ ]]` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

```zsh
# Guard: require a minimum Zsh version
zsh_require_version() {
    local required="$1"   # e.g. "5.8"
    local major="${required%%.*}"
    local minor="${required#*.}"
    if (( ZSH_VERSION_MAJOR < major ||
          ( ZSH_VERSION_MAJOR == major && ZSH_VERSION_MINOR < minor ) )); then
        print -u2 "Error: Zsh ${required}+ required (found ${ZSH_VERSION})"
        return 1
    fi
}

# Usage at script top:
autoload -Uz is-at-least
is-at-least 5.8 || { echo "Requires Zsh 5.8+"; exit 1; }
```

---

## Zsh 5.x Features

### Core Improvements (5.0–5.8)

#### Parameter Expansion Flags (5.0+)
```zsh
# Case conversion
print ${(U)word}        # UPPERCASE
print ${(L)word}        # lowercase
print ${(C)word}        # Capitalised

# Quoting and escaping
print ${(q)path}        # shell-quote the value
print ${(Q)quoted}      # remove one level of quoting

# Array joining and splitting
local -a parts=(a b c)
print ${(j:,:)parts}    # a,b,c  — join with comma
print ${(s:,:)csv}      # split on comma into array
```

#### `zsh/param/private` (Pre-5.9 Alternative)
```zsh
# Before private keyword: use local with nesting guard
nested_safe() {
    local my_var="inner"
    outer_func        # my_var visible inside outer_func if it uses 'local my_var' too
}
```

#### Associative Array Improvements (5.0+)
```zsh
typeset -A config
config=(
    host  "localhost"
    port  "5432"
    name  "mydb"
)

# Iterate key-value pairs
for key val in "${(@kv)config}"; do
    print "$key = $val"
done

# Test key existence
(( ${+config[host]} )) && print "host is set"
```

#### `zsh/datetime` Module (5.0+)
```zsh
zmodload zsh/datetime

# High-resolution timestamp
print $EPOCHSECONDS          # seconds since epoch
print $EPOCHREALTIME         # float: seconds.microseconds

# Formatted date without forking date(1)
strftime "%Y-%m-%d %H:%M:%S" $EPOCHSECONDS
```

#### `zparseopts` (5.0+)
```zsh
# Parse options without manual case/shift loops
parse_options() {
    local -a verbose output help
    zparseopts -D -E -- \
        v=verbose -verbose=verbose \
        o:=output -output:=output \
        h=help -help=help

    (( ${#help}    )) && { usage; return 0; }
    (( ${#verbose} )) && print "Verbose on"
    (( ${#output}  )) && print "Output: ${output[-1]}"
}
```

#### `autoload -Uz` and Function Autoloading (5.0+)
```zsh
# Add custom function directory
fpath=("$HOME/.zsh/functions" $fpath)

# Mark functions for lazy loading
autoload -Uz my_function other_function

# Function is sourced from fpath on first call
```

#### Here-String and Here-Doc Improvements (5.0+)
```zsh
# Indented here-doc (<<- strips leading tabs)
cat <<- 'EOF'
	Line 1 with leading tab stripped
	Line 2
EOF

# Here-string — pass a string as stdin
grep "pattern" <<< "$variable"
```

### Zsh 5.1 — Unicode and Multibyte
```zsh
# Multibyte character counting
local emoji="😀"
print ${#emoji}   # 1 (character count, not bytes)

# Use LC_ALL=C for byte-level operations when needed
LC_ALL=C wc -c <<< "$emoji"
```

### Zsh 5.2 — `zsh/zutil` Improvements
```zsh
zmodload zsh/zutil

# zformat: structured string formatting
local result
zformat -f result "Host: %h Port: %p" h:"$host" p:"$port"
print "$result"
```

### Zsh 5.3 — POSIX Compatibility Options
```zsh
# Improved POSIX_TRAPS behaviour
setopt POSIX_TRAPS      # Traps fire in subshells like POSIX requires

# LOCAL_OPTIONS: reset setopt changes when a function returns
setopt LOCAL_OPTIONS
setopt NULL_GLOB        # Cleared on function return
```

### Zsh 5.4 — `WARN_CREATE_GLOBAL`
```zsh
# Warn when a function creates a global variable without typeset/local
setopt WARN_CREATE_GLOBAL

accidental_global() {
    my_var="oops"   # Warning: my_var created as global
    local my_var="ok"
}
```

### Zsh 5.5 — `zsh/system` Enhancements
```zsh
zmodload zsh/system

# Non-blocking file locking
if zsystem flock -t 0 /tmp/mylock; then
    # Critical section
    zsystem flock -u /tmp/mylock
else
    print "Lock busy; skipping"
fi
```

### Zsh 5.8 — Security Improvements
```zsh
# 5.8 introduced tighter handling of the PROMPT_SUBST option
# to limit code injection through prompt strings.
# Always use single-quoted prompt strings when PROMPT_SUBST is set:
setopt PROMPT_SUBST
PROMPT='%n@%m %~%# '     # safe: evaluated at prompt time
PROMPT="$USER@$(hostname) \$PWD%# "  # risky: $() runs at assignment
```

---

## Zsh 5.9+ Features

### `private` Variable Keyword
```zsh
# Load the private parameter module (5.9+)
zmodload zsh/param/private

# Variables declared with 'private' are NOT visible to called functions
outer() {
    private secret="hidden"
    inner                    # secret is invisible inside inner
}

inner() {
    print "${secret:-not set}"   # prints "not set"
}

# Contrast with 'local': local variables ARE visible to callees
outer_local() {
    local visible="seen"
    inner_local
}

inner_local() {
    print "$visible"   # prints "seen" — dynamic scoping
}
```

### `WARN_NESTED_VAR` Option
```zsh
# Warn when a nested function references an outer function's local
setopt WARN_NESTED_VAR

outer() {
    local my_var="outer value"
    inner   # Warning: inner reads outer's my_var
}

inner() {
    print "$my_var"   # generates WARN_NESTED_VAR warning
}
```

### `TYPESET_SILENT` Option
```zsh
# Suppress automatic output when typeset/declare used without assignment
setopt TYPESET_SILENT
typeset -i count   # no output (previously printed "count" in some contexts)
```

### Version Guard Pattern for 5.9 Features
```zsh
# Safely use 5.9+ features with a fallback
if is-at-least 5.9; then
    zmodload zsh/param/private
    use_private_vars() {
        private secret="$1"
        helper
    }
else
    use_private_vars() {
        local secret="$1"   # visible to callees; acceptable fallback
        helper
    }
fi
```

---

## Migration Guides

### Migrating from Bash to Zsh

```zsh
# ------------------------------------------------------------------
# Bash → Zsh: Common translation table
# ------------------------------------------------------------------

# Arrays (Bash 0-indexed → Zsh 1-indexed)
# Bash:  echo "${arr[0]}"
# Zsh:
print "$arr[1]"
print "${arr[1]}"   # also valid

# Declare vs typeset
# Bash:  declare -A map
# Zsh:
typeset -A map      # preferred Zsh idiom (declare also works)

# Word splitting
# Bash:  ls $flags   (splits on IFS automatically)
# Zsh:   ls ${=flags}  or  setopt SH_WORD_SPLIT for Bash behaviour

# String length
# Bash:  ${#var}
# Zsh:   ${#var}  (same — but counts characters, not bytes in multibyte locales)

# [[ regex matching ]]
# Bash:  [[ "$str" =~ ^[0-9]+$ ]]  — match stored in ${BASH_REMATCH[@]}
# Zsh:   [[ "$str" =~ '^[0-9]+$' ]] — match stored in $match[@]
if [[ "abc123" =~ '([a-z]+)([0-9]+)' ]]; then
    print "letters: $match[1]  digits: $match[2]"
fi

# Process substitution
# Bash:  diff <(cmd1) <(cmd2)
# Zsh:   diff =(cmd1) =(cmd2)   # = creates temp file; < creates pipe
```

### Migrating from Zsh 4.x to 5.x

```zsh
# 4.x used compctl for completions; 5.x uses compsys (compdef/_describe)
# Old (4.x):
compctl -f mycommand

# New (5.x):
_mycommand() { _files }
compdef _mycommand mycommand
```

### Migrating from Zsh 5.x to 5.9

```zsh
# 1. Replace 'local' with 'private' for truly private variables
#    when isolation from callees is required.
# 2. Enable WARN_NESTED_VAR to catch unintended dynamic scoping.
# 3. Review any prompts built with double-quotes for injection risk.

# Automated check: run with WARN_CREATE_GLOBAL + WARN_NESTED_VAR and
# review any warnings before upgrading production scripts.
setopt WARN_CREATE_GLOBAL WARN_NESTED_VAR
source ./your_script.zsh
```

### Checking Version at Runtime

```zsh
# Portable version check using the built-in is-at-least function
autoload -Uz is-at-least

case 1 in
    $(is-at-least 5.9 && echo 1))
        print "5.9+ features available"
        ;;
    $(is-at-least 5.8 && echo 1))
        print "5.8+ features available"
        ;;
    *)
        print "Zsh 5.x baseline"
        ;;
esac

# Or use numeric comparison directly
if (( ${ZSH_VERSION%%.*} > 5 ||
      ( ${ZSH_VERSION%%.*} == 5 && ${${ZSH_VERSION#*.}%%.*} >= 9 ) )); then
    print "Zsh 5.9+"
fi
```

---

<!-- related: sources/zsh-basics.md, sources/zsh-advanced.md, sources/zsh-best-practices.md -->
