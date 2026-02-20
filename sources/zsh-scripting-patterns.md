# Zsh Scripting Patterns

## Common Patterns

### Argument Parsing

```zsh
#!/usr/bin/env zsh

# Simple flag and option parsing
parse_args() {
    local verbose=0
    local output_file=""
    local input_files=()

    while [[ $# -gt 0 ]]; do
        case $1 in
            -v|--verbose)
                verbose=1
                shift
                ;;
            -o|--output)
                output_file="$2"
                shift 2
                ;;
            --)
                shift
                input_files+=("$@")
                break
                ;;
            -*)
                echo "Unknown option: $1" >&2
                return 1
                ;;
            *)
                input_files+=("$1")
                shift
                ;;
        esac
    done

    # Use parsed values
    (( verbose )) && echo "Verbose mode enabled"
    [[ -n "$output_file" ]] && echo "Output: $output_file"
    echo "Input files: ${input_files[@]}"
}
```

### Configuration File Loading

```zsh
# Load configuration from file with defaults
load_config() {
    local config_file="${1:-$HOME/.myapprc}"
    local -A config

    # Set defaults
    config[host]="localhost"
    config[port]="8080"
    config[debug]="false"

    # Load config file if it exists
    if [[ -f "$config_file" ]]; then
        while IFS='=' read -r key value; do
            # Skip comments and empty lines
            [[ "$key" =~ ^[[:space:]]*# ]] && continue
            [[ -z "$key" ]] && continue
            # Trim whitespace
            key="${key// /}"
            value="${value// /}"
            config[$key]="$value"
        done < "$config_file"
    fi

    # Export config values
    typeset -gA APP_CONFIG
    APP_CONFIG=("${(@kv)config}")
}
```

### Logging Pattern

```zsh
# Structured logging with levels
typeset -g LOG_LEVEL=${LOG_LEVEL:-INFO}

_log() {
    local level="$1"
    shift
    local timestamp
    timestamp=$(strftime "%Y-%m-%d %H:%M:%S" $EPOCHSECONDS)
    echo "[$timestamp] [$level] $*" >&2
}

log_debug() { [[ "$LOG_LEVEL" == "DEBUG" ]] && _log "DEBUG" "$@" }
log_info()  { _log "INFO"  "$@" }
log_warn()  { _log "WARN"  "$@" }
log_error() { _log "ERROR" "$@" }

# Usage
log_info "Starting process"
log_debug "Debug details: $var"
log_error "Something went wrong"
```

### Retry Pattern

```zsh
# Retry a command with exponential backoff
retry() {
    local max_attempts="${1:-3}"
    local delay="${2:-1}"
    shift 2
    local attempt=1

    while (( attempt <= max_attempts )); do
        if "$@"; then
            return 0
        fi
        log_warn "Attempt $attempt/$max_attempts failed, retrying in ${delay}s..."
        sleep "$delay"
        (( delay *= 2 ))
        (( attempt++ ))
    done

    log_error "All $max_attempts attempts failed"
    return 1
}

# Usage
retry 3 2 curl -s https://api.example.com/data
```

### Singleton / Lock File Pattern

```zsh
# Prevent multiple instances of a script
acquire_lock() {
    local lock_file="${1:-/tmp/${0:t}.lock}"

    if [[ -f "$lock_file" ]]; then
        local pid
        pid=$(<"$lock_file")
        if kill -0 "$pid" 2>/dev/null; then
            echo "Script already running (PID $pid)" >&2
            return 1
        fi
        # Stale lock
        rm -f "$lock_file"
    fi

    echo $$ > "$lock_file"
    trap "rm -f '$lock_file'" EXIT INT TERM
    return 0
}

acquire_lock || exit 1
```

### Pipeline Builder Pattern

```zsh
# Build and execute dynamic pipelines
build_pipeline() {
    local -a stages=()

    add_stage() { stages+=("$1") }
    run_pipeline() {
        local cmd="${stages[1]}"
        for stage in "${stages[@]:1}"; do
            cmd+=" | $stage"
        done
        eval "$cmd"
    }

    add_stage "cat /etc/passwd"
    add_stage "grep -v '^#'"
    add_stage "cut -d: -f1"
    add_stage "sort"
    run_pipeline
}
```

## Real-World Examples

### Batch File Processor

```zsh
#!/usr/bin/env zsh
# Process multiple files with progress tracking

batch_process() {
    local input_dir="${1:?Input directory required}"
    local output_dir="${2:?Output directory required}"
    local -i total processed failed=0

    [[ -d "$input_dir" ]]  || { echo "Not a directory: $input_dir" >&2;  return 1 }
    mkdir -p "$output_dir" || { echo "Cannot create: $output_dir" >&2; return 1 }

    local -a files=("$input_dir"/**/*(.))
    total=${#files}

    for file in "${files[@]}"; do
        local relative="${file#$input_dir/}"
        local outfile="$output_dir/$relative"

        mkdir -p "${outfile:h}"

        if process_single_file "$file" "$outfile"; then
            (( processed++ ))
        else
            (( failed++ ))
            log_warn "Failed to process: $file"
        fi

        # Progress display
        printf "\rProcessed: %d/%d (failed: %d)" $processed $total $failed
    done
    echo  # newline

    log_info "Done: $processed succeeded, $failed failed out of $total"
    return $(( failed > 0 ))
}
```

### Interactive Menu

```zsh
#!/usr/bin/env zsh
# Display an interactive selection menu

show_menu() {
    local prompt="${1:-Select an option}"
    shift
    local -a options=("$@")
    local choice

    while true; do
        echo "$prompt:"
        local i=1
        for opt in "${options[@]}"; do
            printf "  %d) %s\n" $i "$opt"
            (( i++ ))
        done
        printf "  q) Quit\n"
        printf "Choice: "
        read -r choice

        case $choice in
            q|Q) return 1 ;;
            ''|*[!0-9]*) echo "Invalid choice" ; continue ;;
        esac

        if (( choice >= 1 && choice <= ${#options} )); then
            echo "${options[$choice]}"
            return 0
        fi
        echo "Choice out of range"
    done
}

# Usage
selected=$(show_menu "Choose action" "Deploy" "Rollback" "Status")
echo "You chose: $selected"
```

### Git Repository Helper

```zsh
#!/usr/bin/env zsh
# Common git workflow helpers

# Check if inside a git repo
in_git_repo() {
    git rev-parse --git-dir &>/dev/null
}

# Get current branch name
current_branch() {
    git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD
}

# Safely stash, run command, and restore
with_stash() {
    local stash_msg="auto-stash-$(date +%s)"
    local stashed=0

    if ! git diff --quiet || ! git diff --cached --quiet; then
        git stash push -m "$stash_msg"
        stashed=1
    fi

    "$@"
    local exit_code=$?

    if (( stashed )); then
        git stash pop
    fi

    return $exit_code
}

# Usage
in_git_repo || { echo "Not in a git repository" >&2; exit 1 }
echo "On branch: $(current_branch)"
with_stash git pull --rebase origin main
```

### Environment Setup / Teardown

```zsh
#!/usr/bin/env zsh
# Manage environment setup and teardown

setup_environment() {
    local env_name="${1:?Environment name required}"

    # Save current state
    typeset -gA _SAVED_ENV
    _SAVED_ENV[PATH]="$PATH"
    _SAVED_ENV[VIRTUAL_ENV]="${VIRTUAL_ENV:-}"

    # Set up new environment
    export PATH="/opt/$env_name/bin:$PATH"
    export APP_ENV="$env_name"

    # Register teardown
    add-zsh-hook zshexit teardown_environment
}

teardown_environment() {
    # Restore saved state
    export PATH="${_SAVED_ENV[PATH]}"
    if [[ -n "${_SAVED_ENV[VIRTUAL_ENV]}" ]]; then
        export VIRTUAL_ENV="${_SAVED_ENV[VIRTUAL_ENV]}"
    else
        unset VIRTUAL_ENV
    fi
    unset APP_ENV
}
```

## Use Cases and Solutions

### Finding and Processing Files

```zsh
# Find files modified in the last N days and process them
process_recent_files() {
    local days="${1:-7}"
    local dir="${2:-.}"

    # Files modified in last N days, not in .git
    for file in "$dir"/**/*(D.mh-$(( days * 24 ))); do
        [[ "$file" == */.git/* ]] && continue
        echo "Processing: $file"
        # your processing here
    done
}

# Find duplicate files by size then checksum
find_duplicates() {
    local dir="${1:-.}"
    local -A seen_checksums

    for file in "$dir"/**/*(.L+0); do
        local checksum
        checksum=$(md5sum "$file" | cut -d' ' -f1)
        if [[ -n "${seen_checksums[$checksum]}" ]]; then
            echo "Duplicate: $file"
            echo "  Original: ${seen_checksums[$checksum]}"
        else
            seen_checksums[$checksum]="$file"
        fi
    done
}
```

### Network Operations

```zsh
# Wait for a service to become available
wait_for_service() {
    local host="${1:?Host required}"
    local port="${2:?Port required}"
    local timeout="${3:-30}"
    local -i elapsed=0

    while (( elapsed < timeout )); do
        if zmodload zsh/net/tcp 2>/dev/null; then
            if ztcp "$host" "$port" 2>/dev/null; then
                ztcp -c
                return 0
            fi
        else
            # Fallback using /dev/tcp
            if exec 3<>"/dev/tcp/$host/$port" 2>/dev/null; then
                exec 3>&-
                return 0
            fi
        fi
        sleep 1
        (( elapsed++ ))
    done

    echo "Timeout waiting for $host:$port" >&2
    return 1
}

# Usage
wait_for_service localhost 5432 60 && psql -h localhost mydb
```

### String Processing

```zsh
# Parse CSV data
parse_csv_line() {
    local line="$1"
    local -a fields=()
    local field="" in_quotes=0

    for (( i = 1; i <= ${#line}; i++ )); do
        local char="${line[$i]}"
        if [[ "$char" == '"' ]]; then
            (( in_quotes = !in_quotes ))
        elif [[ "$char" == ',' && $in_quotes -eq 0 ]]; then
            fields+=("$field")
            field=""
        else
            field+="$char"
        fi
    done
    fields+=("$field")

    echo "${fields[@]}"
}

# Template substitution
render_template() {
    local template="$1"
    shift
    local output="$template"

    while [[ $# -ge 2 ]]; do
        local key="$1" value="$2"
        output="${output//\{\{$key\}\}/$value}"
        shift 2
    done

    echo "$output"
}

# Usage
render_template "Hello, {{name}}! You have {{count}} messages." \
    name "Alice" count "5"
# Output: Hello, Alice! You have 5 messages.
```

### Process Management

```zsh
# Run tasks in parallel with a concurrency limit
parallel_run() {
    local max_jobs="${1:-4}"
    shift
    local -a pids=()

    for task in "$@"; do
        # Wait if at max concurrency
        while (( ${#pids} >= max_jobs )); do
            local -a remaining=()
            for pid in "${pids[@]}"; do
                kill -0 "$pid" 2>/dev/null && remaining+=("$pid")
            done
            pids=("${remaining[@]}")
            (( ${#pids} >= max_jobs )) && sleep 0.1
        done

        # Start task in background
        eval "$task" &
        pids+=($!)
    done

    # Wait for all remaining tasks
    local exit_code=0
    for pid in "${pids[@]}"; do
        wait "$pid" || (( exit_code = 1 ))
    done
    return $exit_code
}

# Usage
parallel_run 4 \
    "process_file file1.txt" \
    "process_file file2.txt" \
    "process_file file3.txt"
```

## Resources
- Zsh FAQ: https://zsh.sourceforge.io/FAQ/
- Bash Patterns (many apply to Zsh): https://mywiki.wooledge.org/BashPatterns
- Advanced Bash-Scripting Guide: https://tldp.org/LDP/abs/html/
