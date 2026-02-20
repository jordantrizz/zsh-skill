#!/usr/bin/env zsh
# prompt_helpers.zsh - Reusable prompt and output formatting functions
#
# Usage: source this file in your scripts or .zshrc

# ============================================================
# Color and Style Helpers
# ============================================================

# Print colored text (uses Zsh print -P for prompt formatting)
# Usage: color_echo green "Success message"
# Colors: black red green yellow blue magenta cyan white
color_echo() {
    local color="$1"
    shift
    print -P "%F{$color}$*%f"
}

# Print bold text
bold_echo() {
    print -P "%B$*%b"
}

# Print with color and bold
color_bold_echo() {
    local color="$1"
    shift
    print -P "%B%F{$color}$*%f%b"
}

# Convenience wrappers
echo_success() { color_echo green   "✓ $*" }
echo_error()   { color_echo red     "✗ $*" >&2 }
echo_warning() { color_echo yellow  "⚠ $*" >&2 }
echo_info()    { color_echo cyan    "ℹ $*" }

# ============================================================
# Spinner / Progress Indicators
# ============================================================

# Show a spinner while a command runs
# Usage: with_spinner "Loading..." sleep 3
with_spinner() {
    local message="$1"
    shift
    local -a frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local -i frame=0

    "$@" &
    local pid=$!

    while kill -0 "$pid" 2>/dev/null; do
        printf "\r  %s %s  " "${frames[$((frame % ${#frames} + 1))]}" "$message"
        (( frame++ ))
        sleep 0.1
    done

    wait "$pid"
    local exit_code=$?
    printf "\r"

    if (( exit_code == 0 )); then
        echo_success "$message"
    else
        echo_error "$message (failed)"
    fi
    return $exit_code
}

# Simple progress bar
# Usage: progress_bar 30 100 "Downloading"
progress_bar() {
    local -i current="$1"
    local -i total="$2"
    local label="${3:-Progress}"
    local -i width=40

    local -i filled=$(( current * width / total ))
    local -i empty=$(( width - filled ))

    local bar=""
    bar+=$(printf '%*s' "$filled" | tr ' ' '█')
    bar+=$(printf '%*s' "$empty"  | tr ' ' '░')

    local pct=$(( current * 100 / total ))
    printf "\r  %s [%s] %d%% (%d/%d)" "$label" "$bar" "$pct" "$current" "$total"
    (( current == total )) && echo
}

# ============================================================
# Table / Column Formatting
# ============================================================

# Print a formatted table row
# Usage: table_row "Name" "Value" "Status"
table_row() {
    local -a cols=("$@")
    local -i col_width=20
    for col in "${cols[@]}"; do
        printf "%-${col_width}s" "$col"
    done
    echo
}

# Print a horizontal divider
table_divider() {
    local -i width="${1:-60}"
    printf '%*s\n' "$width" | tr ' ' '-'
}

# ============================================================
# Prompt / Confirmation Helpers
# ============================================================

# Ask yes/no question
# Usage: confirm "Delete file?" && rm file
confirm() {
    local prompt="${1:-Are you sure?}"
    local response
    printf "%s [y/N] " "$prompt"
    read -r response
    [[ "${response:l}" == "y" || "${response:l}" == "yes" ]]
}

# Prompt for a value with optional default
# Usage: value=$(prompt_value "Enter name" "default")
prompt_value() {
    local prompt="${1:-Enter value}"
    local default="${2:-}"
    local response

    if [[ -n "$default" ]]; then
        printf "%s [%s]: " "$prompt" "$default"
    else
        printf "%s: " "$prompt"
    fi

    read -r response
    echo "${response:-$default}"
}

# Prompt for a password (no echo)
# Usage: password=$(prompt_password "Enter password")
prompt_password() {
    local prompt="${1:-Password}"
    local password
    read -rs -p "$prompt: " password
    echo ""  # newline after hidden input
    echo "$password"
}

# ============================================================
# Demo when run directly
# ============================================================
if [[ "${(%):-%N}" == "${0}" ]]; then
    echo "=== Prompt Helpers Demo ==="
    echo ""

    echo "--- Color output ---"
    echo_success "Operation completed"
    echo_error   "Something went wrong"
    echo_warning "This might be an issue"
    echo_info    "Informational message"

    echo ""
    color_bold_echo blue "=== Section Header ==="

    echo ""
    echo "--- Table formatting ---"
    table_row "Name" "Value" "Status"
    table_divider 60
    table_row "hostname" "localhost" "active"
    table_row "port" "8080" "listening"
    table_row "workers" "4" "idle"

    echo ""
    echo "--- Progress bar demo ---"
    for i in {0..10}; do
        progress_bar $i 10 "Loading"
        sleep 0.1
    done

    echo ""
    echo "--- Spinner demo ---"
    with_spinner "Simulating work" sleep 2

    echo ""
    echo "Run interactively to test confirm/prompt functions"
fi
