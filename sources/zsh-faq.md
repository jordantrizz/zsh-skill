# Zsh FAQ

<!-- semantic-tags: faq, zsh, questions, answers, troubleshooting, beginners, reference -->

A curated list of frequently asked questions about Zsh scripting, organized by topic.
Each entry includes a direct answer and runnable code examples where relevant.

---

## 📌 General Zsh Questions

<!-- semantic-tags: general, basics, overview, startup, configuration -->

**Q: What is Zsh and why use it instead of Bash?**

Zsh is an extended Bourne-compatible shell with a richer feature set than Bash: superior
tab-completion, spelling correction, glob qualifiers, associative arrays without `declare`,
floating-point arithmetic, and more expressive parameter expansion. It is the default shell
on macOS since Catalina and is available on all major Linux distributions.

---

**Q: What startup files does Zsh read, and in what order?**

| File | When read |
|------|-----------|
| `/etc/zshenv` | Always, every shell |
| `~/.zshenv` | Always, every shell |
| `/etc/zprofile` | Login shells only |
| `~/.zprofile` | Login shells only |
| `/etc/zshrc` | Interactive shells only |
| `~/.zshrc` | Interactive shells only |
| `/etc/zlogin` | Login shells, after zshrc |
| `~/.zlogin` | Login shells, after zshrc |

Rule of thumb: put environment variables (`PATH`, etc.) in `~/.zshenv`; interactive
configuration (aliases, completions, prompts) in `~/.zshrc`.

---

**Q: How do I check my Zsh version?**

```zsh
zsh --version
echo $ZSH_VERSION
```

---

**Q: How do I enable "strict mode" in a script?**

```zsh
#!/usr/bin/env zsh
setopt ERR_EXIT     # Exit immediately on error
setopt NO_UNSET     # Treat unset variables as errors
setopt PIPE_FAIL    # Propagate pipe errors
```

---

**Q: What is the difference between `#!/bin/zsh` and `#!/usr/bin/env zsh`?**

`#!/usr/bin/env zsh` is more portable: it finds `zsh` on `PATH` so it works when Zsh is
installed outside `/bin` (e.g. Homebrew on macOS). Use `#!/usr/bin/env zsh` for scripts
you intend to share; use `#!/bin/zsh` only when you need an exact, fixed path.

---

**Q: How do I source another file and keep variables local to my script?**

```zsh
# Source a helper library
source "${0:A:h}/lib/helpers.zsh"

# Variables defined with 'local' inside functions are scoped to that function.
# Top-level (global) variables from sourced files bleed into the current shell;
# use a subshell if isolation is required.
(
    source untrusted.zsh
    do_something
)
```

---

## 🗂️ Arrays and Associative Arrays

<!-- semantic-tags: arrays, associative-arrays, hash, maps, data-structures -->

**Q: How do I declare and use a plain array?**

```zsh
# Declaration
local -a fruits=(apple banana cherry)

# Access (1-indexed)
echo $fruits[1]          # apple
echo $fruits[-1]         # cherry (last element)
echo $fruits[2,3]        # banana cherry (slice)

# Length
echo ${#fruits}

# Append
fruits+=(date)

# Iterate
for fruit in $fruits; do
    echo $fruit
done
```

---

**Q: How do I declare and use an associative array (hash map)?**

```zsh
# Declaration — requires typeset/local -A
local -A config
config[host]="localhost"
config[port]="5432"
config[db]="myapp"

# Access
echo $config[host]

# Check if key exists
if (( ${+config[timeout]} )); then
    echo "timeout is set"
fi

# Iterate keys and values
for key val in ${(kv)config}; do
    echo "$key = $val"
done

# All keys / all values
echo ${(k)config}
echo ${(v)config}
```

---

**Q: How do I pass an array to a function?**

```zsh
# Pass by value (copy) using ${array[@]}
print_items() {
    local -a items=("$@")
    for item in $items; do
        echo "  - $item"
    done
}

local -a my_list=(one two three)
print_items "${my_list[@]}"

# Pass by name (reference) using a nameref
process_array() {
    local -n arr_ref=$1     # nameref — requires Zsh 5.1+
    echo "Length: ${#arr_ref}"
}

process_array my_list
```

---

**Q: How do I remove an element from an array?**

```zsh
local -a items=(a b c d e)

# Remove by index
items[3]=()          # removes 'c'

# Remove by value
items=(${items:#b})  # removes all elements equal to 'b'

# Remove elements matching a pattern
items=(${items:#[aeiou]})  # removes single-character vowels
```

---

**Q: How do I sort an array?**

```zsh
local -a words=(banana apple cherry date)

# Alphabetical sort using (o) flag
local -a sorted=("${(o)words[@]}")

# Reverse sort
local -a rev_sorted=("${(O)words[@]}")

# Numeric sort
local -a nums=(10 2 30 4)
local -a sorted_nums=("${(on)nums[@]}")
```

---

## 🔤 String Manipulation

<!-- semantic-tags: strings, parameter-expansion, substitution, manipulation, text -->

**Q: How do I get a substring?**

```zsh
local str="Hello, World!"

# By index (1-based offset, length)
echo ${str:7:5}          # World

# Everything from offset
echo ${str:7}            # World!

# Last N characters
echo ${str: -6}          # orld!  (note the space before -)
```

---

**Q: How do I convert a string to uppercase or lowercase?**

```zsh
local str="Hello World"

echo ${str:u}   # HELLO WORLD  (uppercase)
echo ${str:l}   # hello world  (lowercase)

# Capitalise first character
echo ${(C)str}  # Hello World  (title case)
```

---

**Q: How do I strip leading and trailing whitespace?**

```zsh
local str="  hello world  "

# Strip leading whitespace
echo ${str##*( )}   # requires EXTENDED_GLOB

# Strip trailing whitespace
echo ${str%%*( )}

# Strip both (combine or use a function)
strip_whitespace() {
    local s="$1"
    s="${s##*( )}"
    s="${s%%*( )}"
    echo "$s"
}
```

---

**Q: How do I split a string on a delimiter?**

```zsh
local csv="one,two,three"

# Split into array using (s) flag
local -a parts=("${(s:,:)csv}")
echo $parts[2]   # two

# Split on multi-char delimiter
local data="foo::bar::baz"
local -a fields=("${(s/::/)data}")
```

---

**Q: How do I replace a substring?**

```zsh
local str="foo bar foo baz"

# Replace first occurrence
echo ${str/foo/FOO}    # FOO bar foo baz

# Replace all occurrences
echo ${str//foo/FOO}   # FOO bar FOO baz

# Replace at the start
echo ${str/#foo/FOO}   # FOO bar foo baz

# Replace at the end
local path="/usr/local/bin"
echo ${path/%bin/sbin}  # /usr/local/sbin
```

---

**Q: How do I check if a string contains a substring?**

```zsh
local haystack="Hello, World!"

if [[ $haystack == *"World"* ]]; then
    echo "found"
fi

# Case-insensitive
if [[ ${haystack:l} == *"world"* ]]; then
    echo "found (case-insensitive)"
fi
```

---

## 📁 File Operations

<!-- semantic-tags: files, directories, globbing, path, io -->

**Q: How do I iterate over files in a directory?**

```zsh
# All files in current directory
for file in *(.); do     # (.) = regular files only
    echo "$file"
done

# Recursive, specific extension
for file in **/*.log(N); do   # (N) = nullglob, no error if none
    echo "$file"
done

# Using a null-safe check
local -a logfiles=(*.log(N))
if (( ${#logfiles} == 0 )); then
    echo "No log files found"
fi
```

---

**Q: How do I get the directory and filename from a path?**

```zsh
local path="/usr/local/bin/zsh"

echo ${path:h}   # /usr/local/bin  (head / dirname)
echo ${path:t}   # zsh             (tail / basename)
echo ${path:e}   # (extension — empty here)
echo ${path:r}   # /usr/local/bin/zsh (root, without extension)

# For a file with extension
local file="archive.tar.gz"
echo ${file:e}   # gz
echo ${file:r}   # archive.tar
```

---

**Q: How do I get the absolute (resolved) path of a file?**

```zsh
# Resolve symlinks and relative components
local abs_path="${file:A}"

# Directory of the current script (reliable even with symlinks)
readonly SCRIPT_DIR="${0:A:h}"
```

---

**Q: How do I read a file line by line?**

```zsh
while IFS= read -r line; do
    echo "Line: $line"
done < file.txt

# Or process directly
while IFS= read -r line; do
    [[ -z $line || $line == \#* ]] && continue   # skip blank/comments
    process_line "$line"
done < config.txt
```

---

**Q: How do I write to a file (overwrite vs. append)?**

```zsh
# Overwrite
echo "new content" > output.txt

# Append
echo "another line" >> output.txt

# Multi-line here-document
cat > output.txt << 'EOF'
Line one
Line two
EOF
```

---

## 🛡️ Error Handling

<!-- semantic-tags: error-handling, traps, exit-codes, robustness -->

**Q: How do I trap errors and clean up temporary files?**

```zsh
#!/usr/bin/env zsh
setopt ERR_EXIT NO_UNSET PIPE_FAIL

local tmpfile=$(mktemp)

cleanup() {
    rm -f "$tmpfile"
}
trap cleanup EXIT        # runs on any exit
trap 'cleanup; exit 1' INT TERM   # runs on Ctrl-C / kill

# Work with $tmpfile safely
echo "data" > "$tmpfile"
process "$tmpfile"
```

---

**Q: How do I check the exit status of a command?**

```zsh
# Direct test
if ! command_that_may_fail; then
    echo "Command failed" >&2
    return 1
fi

# Capture exit code
some_command
local status=$?
if (( status != 0 )); then
    echo "Failed with status $status" >&2
fi

# Allow a command to fail without exiting (when ERR_EXIT is set)
command_that_may_fail || true
```

---

**Q: How do I provide meaningful error messages?**

```zsh
# Write errors to stderr
error() {
    echo "[ERROR] $*" >&2
}

# Include context
validate_file() {
    local file="$1"
    if [[ ! -f $file ]]; then
        error "File not found: $file"
        return 1
    fi
    if [[ ! -r $file ]]; then
        error "File not readable: $file"
        return 1
    fi
}
```

---

**Q: How do I handle optional commands that may not be installed?**

```zsh
# Check if a command exists
if ! command -v jq &>/dev/null; then
    echo "jq is required but not installed" >&2
    exit 1
fi

# Provide a fallback
if command -v ggrep &>/dev/null; then
    GREP=ggrep
else
    GREP=grep
fi
```

---

## 🔍 Debugging

<!-- semantic-tags: debugging, tracing, xtrace, verbose, diagnostics -->

**Q: How do I trace script execution?**

```zsh
# Enable tracing for entire script (add to shebang line or top)
setopt XTRACE          # prints each command before executing

# Enable only for a section
setopt XTRACE
problematic_function
unsetopt XTRACE

# Run a script with tracing from the command line
zsh -x script.zsh
```

---

**Q: How do I print variable values for debugging?**

```zsh
# Simple
echo "DEBUG: var=$var" >&2

# Structured debug function (only prints when DEBUG=1)
debug() {
    [[ ${DEBUG:-0} == 1 ]] || return 0
    echo "[DEBUG] $*" >&2
}

debug "Processing file: $file"
```

---

**Q: How do I check which function is failing?**

```zsh
# Use $funcstack to see the call stack
show_stack() {
    echo "Call stack:" >&2
    local i
    for i in ${(k)funcstack}; do
        echo "  $i: ${funcstack[$i]}" >&2
    done
}

# Or use ERR trap to log failures
trap 'echo "Error at line $LINENO in ${funcstack[1]}" >&2' ERR
```

---

**Q: How do I dry-run a script without making changes?**

```zsh
# Check for --dry-run flag and define a run() wrapper
DRY_RUN=0
[[ ${1:-} == "--dry-run" ]] && DRY_RUN=1

run() {
    if (( DRY_RUN )); then
        echo "[DRY RUN] $*" >&2
    else
        "$@"
    fi
}

run rm -rf /tmp/old_cache
run rsync -av src/ dest/
```

---

## ⚡ Performance

<!-- semantic-tags: performance, optimization, speed, efficiency, benchmarking -->

**Q: How do I measure the execution time of a command or function?**

```zsh
# Built-in time keyword
time my_function

# Manual timing
local start=$EPOCHREALTIME
do_work
local elapsed=$(( EPOCHREALTIME - start ))
printf "Elapsed: %.3f seconds\n" $elapsed
```

---

**Q: What are the common performance pitfalls in Zsh scripts?**

- **Forking in loops** — every `$(command)` spawns a subshell. Cache results outside loops.
- **Reading files with `cat | ...`** — use redirection (`< file`) instead.
- **Parsing large files line-by-line in Zsh** — for large data, prefer `awk` or `sort`.
- **Not using built-ins** — `print`, `read`, `[[ ]]` are faster than external commands.

```zsh
# Slow: forks in every iteration
for file in *; do
    count=$(wc -l < "$file")  # subshell per iteration
done

# Faster: single subshell
local -A line_counts
while IFS=' ' read -r count file; do
    line_counts[$file]=$count
done < <(wc -l -- *)
```

---

**Q: How do I speed up Zsh startup?**

```zsh
# Profile startup time
zsh -i -c 'zprof' 2>&1 | head -20   # requires 'zmodload zsh/zprof' at top of .zshrc

# Lazy-load heavy completions
compdef _git git 2>/dev/null || true

# Compile .zshrc for faster parsing
zcompile ~/.zshrc
```

---

## 🆚 Comparison with Bash

<!-- semantic-tags: bash, comparison, migration, portability, differences -->

**Q: What are the main differences between Zsh and Bash arrays?**

| Feature | Bash | Zsh |
|---------|------|-----|
| Array indexing | 0-based | 1-based |
| Associative arrays | `declare -A` | `typeset -A` or `local -A` |
| Array length | `${#arr[@]}` | `${#arr}` |
| Last element | `${arr[-1]}` (Bash 4.3+) | `$arr[-1]` |
| Slice | `${arr[@]:1:2}` | `$arr[2,3]` |
| Null-safe iteration | `"${arr[@]}"` needed | `$arr` usually safe |

---

**Q: Which Bash constructs don't work in Zsh?**

```zsh
# Bash: source with arguments — not supported in Zsh
source script.sh arg1    # Zsh: arguments ignored or error

# Bash: [[ ]] with = for assignment — not valid in either, but Bash error messages differ

# Bash: function keyword is optional
my_func() { ... }        # Works in both
function my_func { ... } # Works in both

# Bash: $BASH_SOURCE — use $0 or ${(%):-%x} in Zsh
local script_dir="${0:A:h}"    # Zsh equivalent

# Bash: 0-based array indexing
arr=(a b c)
echo ${arr[0]}   # 'a' in Bash, empty in Zsh (no element 0)
echo $arr[1]     # 'a' in Zsh
```

---

**Q: How do I write a script that works in both Bash and Zsh?**

Use the POSIX-compatible subset and detect the shell at runtime:

```zsh
#!/usr/bin/env zsh
# This file is Zsh-only; for portable scripts use #!/bin/sh

# If you must support both, restrict yourself to:
# - POSIX [ ] tests instead of [[ ]]
# - printf instead of echo for portability
# - No Zsh-specific glob qualifiers or parameter flags
# - Explicit array handling compatible with both shells
```

For most new scripts, choose one shell and use its features fully rather than writing
lowest-common-denominator code.

---

**Q: Does Zsh support `set -e`, `set -u`, `set -o pipefail`?**

Yes — these POSIX/Bash options map directly to Zsh options:

```zsh
set -e           # equivalent to: setopt ERR_EXIT
set -u           # equivalent to: setopt NO_UNSET
set -o pipefail  # equivalent to: setopt PIPE_FAIL

# Zsh-native style (preferred in Zsh scripts)
setopt ERR_EXIT NO_UNSET PIPE_FAIL
```

---

## 🔗 Knowledge Graph Links

<!-- semantic-tags: knowledge-graph, cross-references, related-topics -->

| Topic | Related File |
|-------|-------------|
| Zsh fundamentals and syntax | [zsh-basics.md](./zsh-basics.md) |
| Advanced globbing, completion, parameters | [zsh-advanced.md](./zsh-advanced.md) |
| Script structure and coding standards | [zsh-best-practices.md](./zsh-best-practices.md) |
| Error messages and common fixes | [zsh-troubleshooting.md](./zsh-troubleshooting.md) |
| Quick syntax reference | [zsh-reference.md](./zsh-reference.md) |
| Scripting idioms and patterns | [zsh-scripting-patterns.md](./zsh-scripting-patterns.md) |
| Tools and ecosystem | [zsh-ecosystem.md](./zsh-ecosystem.md) |
| AI assistant integration | [claude-guide.md](./claude-guide.md) |

---

Last Updated: 2025-01-01
