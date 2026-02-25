# Zsh Performance Optimization

<!-- semantic-tags: performance, optimization, benchmarking, profiling -->

## Performance Benchmarking Guide

### Using `zsh/zprof`

`zsh/zprof` is the built-in Zsh profiler. It must be loaded **before** the code under test.

```zsh
#!/usr/bin/env zsh
# profile_script.zsh — wrap any script for profiling

zmodload zsh/zprof   # Must be first

source ./script_under_test.zsh
# or call functions directly:
# my_function arg1 arg2

zprof              # Print profiling report to stdout
```

```
# Sample zprof output:
num  calls                time                       self            name
-----------------------------------------------------------------------------------
  1)    1          23.45    23.45   58.12%     18.33    18.33   45.44%  slow_function
  2)   10           5.12     0.51   12.70%      5.12     0.51   12.70%  string_concat
  3)    1           3.00     3.00    7.44%      3.00     3.00    7.44%  file_read
```

### Simple Timing with `EPOCHREALTIME`

```zsh
zmodload zsh/datetime

# Measure a block of code
bench() {
    local label="$1"; shift
    local -F start=$EPOCHREALTIME
    "$@"
    local -F end=$EPOCHREALTIME
    printf "%s: %.4f seconds\n" "$label" $(( end - start ))
}

bench "array loop" my_array_function
bench "string ops" my_string_function
```

### Timing with `time` Built-in

```zsh
# Built-in time; output goes to stderr by default
time my_function

# Run multiple iterations to average out noise
for i in {1..100}; do my_function; done |& tail -1

# Time a subshell
time (
    for i in {1..1000}; do
        echo "iteration $i" > /dev/null
    done
)
```

### Micro-benchmark Helper

```zsh
# micro_bench: run a command N times and report min/max/avg
micro_bench() {
    local iterations="${1:-100}"; shift
    local -a times
    local -F t0 t1

    for (( i = 1; i <= iterations; i++ )); do
        t0=$EPOCHREALTIME
        "$@" > /dev/null 2>&1
        t1=$EPOCHREALTIME
        times+=( $(( t1 - t0 )) )
    done

    # Compute stats using zsh arithmetic
    local -F sum=0 min=${times[1]} max=${times[1]}
    for t in "${times[@]}"; do
        sum=$(( sum + t ))
        (( t < min )) && min=$t
        (( t > max )) && max=$t
    done

    printf "cmd: %s  n=%d  avg=%.4fs  min=%.4fs  max=%.4fs\n" \
        "$*" "$iterations" "$(( sum / iterations ))" "$min" "$max"
}

micro_bench 200 grep -c "pattern" /usr/share/dict/words
```

---

## Optimization Techniques

### 1. Avoid Subshells in Loops

Subshells (`$(...)`) are expensive because they fork a new process.

```zsh
# Slow: forks a subshell on every iteration
for file in *.log; do
    size=$(wc -l < "$file")   # fork per file
    (( size > 1000 )) && print "$file has $size lines"
done

# Fast: read into array, use Zsh built-ins
local -a large_files
for file in *.log; do
    local -a lines=("${(@f)$(<"$file")}")   # read without wc
    (( ${#lines} > 1000 )) && large_files+=("$file")
done
print -l "${large_files[@]}"
```

### 2. Use Built-in String Operations

```zsh
# Slow: fork a process for every string operation
upper=$(echo "$str" | tr '[:lower:]' '[:upper:]')
trimmed=$(echo "$str" | sed 's/^ *//')

# Fast: Zsh parameter expansion flags — no fork
upper=${(U)str}
trimmed="${str##* }"        # trim leading spaces (glob trim)
trimmed="${str#"${str%%[! ]*}"}"  # POSIX-compatible trim
```

### 3. Prefer `print` over `echo`

```zsh
# echo forks in some shells; Zsh's print is always built-in
# Also: printf is built-in in Zsh 5+
print "Message"
printf "%s\n" "Message"
```

### 4. Use Arrays Instead of String Manipulation

```zsh
# Slow: repeated string concatenation
result=""
for item in "${items[@]}"; do
    result="${result},${item}"
done
result="${result#,}"    # strip leading comma

# Fast: join array with Zsh parameter expansion
print "${(j:,:)items}"
```

### 5. Avoid `cat` for Single-File Reads

```zsh
# Slow: forks cat
content=$(cat file.txt)

# Fast: Zsh built-in file read
content=$(<file.txt)
```

### 6. Use `(( ))` for Integer Arithmetic

```zsh
# Slow: forks bc or expr
result=$(echo "3 + 4" | bc)

# Fast: built-in arithmetic
(( result = 3 + 4 ))
result=$(( 3 + 4 ))
```

### 7. Lazy-Load Functions with `autoload`

```zsh
# Without autoload: all functions are parsed and stored at startup
source ~/.zsh/lib/large_library.zsh     # parses everything

# With autoload: function body loaded only on first call
fpath=("$HOME/.zsh/functions" $fpath)
autoload -Uz infrequent_function        # zero cost until called
```

### 8. Minimise External Command Calls

```zsh
# Identify hot paths with zprof, then replace external calls:
#   date      → strftime (zsh/datetime)
#   wc -l     → ${#array[@]} after mapfile
#   basename  → ${path:t}
#   dirname   → ${path:h}
#   tr        → ${(U)var} / ${(L)var}
#   head -1   → read -r line < file

zmodload zsh/datetime
timestamp=$(strftime "%Y%m%d_%H%M%S" $EPOCHSECONDS)   # no fork

path="/usr/local/bin/myscript.zsh"
print "${path:t}"    # myscript.zsh   (basename)
print "${path:h}"    # /usr/local/bin (dirname)
print "${path:e}"    # zsh            (extension)
print "${path:r}"    # /usr/local/bin/myscript (root, no extension)
```

### 9. Bulk-Read Files with `mapfile` / `(f)` Flag

```zsh
# Read file lines into array without a loop or fork
local -a lines
lines=("${(@f)$(<file.txt)}")      # split on newlines

# Or use mapfile (available when zsh/mapfile is loaded)
zmodload zsh/mapfile
local -A files
files[content]="${mapfile[file.txt]}"
```

### 10. Profile `zshrc` Startup Time

```zsh
# Add at the TOP of ~/.zshrc:
zmodload zsh/zprof

# Add at the BOTTOM of ~/.zshrc:
zprof

# Then open a new terminal; the profiling report shows startup costs.
# Remove both lines after optimisation is done.
```

---

## Performance Comparison Examples

### String-to-Uppercase Comparison

```zsh
#!/usr/bin/env zsh
zmodload zsh/datetime

iterations=10000
test_str="hello world from zsh"

# Method 1: external tr
t0=$EPOCHREALTIME
for (( i = 0; i < iterations; i++ )); do
    upper=$(echo "$test_str" | tr '[:lower:]' '[:upper:]')
done
printf "tr (fork):       %.4fs\n" $(( EPOCHREALTIME - t0 ))

# Method 2: Zsh built-in
t0=$EPOCHREALTIME
for (( i = 0; i < iterations; i++ )); do
    upper=${(U)test_str}
done
printf "Zsh \${(U)var}:   %.4fs\n" $(( EPOCHREALTIME - t0 ))
```

Expected output (typical):
```
tr (fork):       4.2130s
Zsh ${(U)var}:   0.0061s
```

### File-Read Comparison

```zsh
#!/usr/bin/env zsh
zmodload zsh/datetime

tmpfile=$(mktemp)
printf '%s\n' {1..500} > "$tmpfile"

iterations=1000

# Method 1: cat subshell
t0=$EPOCHREALTIME
for (( i = 0; i < iterations; i++ )); do
    content=$(cat "$tmpfile")
done
printf "cat fork:        %.4fs\n" $(( EPOCHREALTIME - t0 ))

# Method 2: Zsh built-in redirect
t0=$EPOCHREALTIME
for (( i = 0; i < iterations; i++ )); do
    content=$(<"$tmpfile")
done
printf "Zsh \$(<file):    %.4fs\n" $(( EPOCHREALTIME - t0 ))

rm -f "$tmpfile"
```

### Array Join Comparison

```zsh
#!/usr/bin/env zsh
zmodload zsh/datetime

local -a items=({a..z} {A..Z} {0..9})
iterations=5000

# Method 1: string concatenation loop
t0=$EPOCHREALTIME
for (( i = 0; i < iterations; i++ )); do
    result=""
    for item in "${items[@]}"; do result="${result},${item}"; done
    result="${result#,}"
done
printf "concat loop:     %.4fs\n" $(( EPOCHREALTIME - t0 ))

# Method 2: Zsh join flag
t0=$EPOCHREALTIME
for (( i = 0; i < iterations; i++ )); do
    result="${(j:,:)items}"
done
printf "Zsh \${(j:,:)arr}: %.4fs\n" $(( EPOCHREALTIME - t0 ))
```

---

## Profiling Common Patterns

### Identifying Slow `.zshrc` Plugins

```zsh
# ~/.zshrc — wrap plugin loads for individual timing
_profile_source() {
    local file="$1"
    zmodload zsh/datetime
    local -F t0=$EPOCHREALTIME
    source "$file"
    printf "[%.3fs] %s\n" $(( EPOCHREALTIME - t0 )) "$file" >&2
}

_profile_source "$ZSH/oh-my-zsh.sh"
_profile_source "$HOME/.zsh/plugins/my-plugin.zsh"
```

### Detecting Subshell Anti-Patterns

```zsh
# Use zprof to find functions that fork frequently.
# Look for high "calls" count combined with high "time" — this often
# indicates repeated $(command) inside loops.

# Automated hint: static grep for $( inside for/while
grep -n '\$(' your_script.zsh | grep -v '#'
```

### Memory and Descriptor Leaks

```zsh
# Check open file descriptors before and after a function
fd_count_before=$(ls /proc/$$/fd 2>/dev/null | wc -l)
your_function
fd_count_after=$(ls /proc/$$/fd 2>/dev/null | wc -l)
print "FDs leaked: $(( fd_count_after - fd_count_before ))"
```

### Startup Regression Test

```zsh
# Measure shell startup time; alert if >200 ms
startup_ms() {
    local -F t0 t1
    t0=$EPOCHREALTIME
    zsh -i -c exit
    t1=$EPOCHREALTIME
    printf "%.0f" $(( (t1 - t0) * 1000 ))
}

ms=$(startup_ms)
if (( ms > 200 )); then
    print "Warning: shell startup took ${ms}ms (threshold: 200ms)"
else
    print "Startup OK: ${ms}ms"
fi
```

---

<!-- related: sources/zsh-best-practices.md, sources/zsh-troubleshooting.md, sources/zsh-advanced.md -->
