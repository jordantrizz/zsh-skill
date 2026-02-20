#!/usr/bin/env zsh
# function_library.zsh - A reusable library of common Zsh functions
#
# Usage: source this file in your scripts
#   source /path/to/function_library.zsh

# ============================================================
# String Utilities
# ============================================================

# str_trim - Remove leading and trailing whitespace
# Usage: str_trim "  hello  "
str_trim() {
    local str="${1}"
    str="${str#"${str%%[! ]*}"}"   # remove leading whitespace
    str="${str%"${str##*[! ]}"}"   # remove trailing whitespace
    echo "$str"
}

# str_repeat - Repeat a string N times
# Usage: str_repeat "-" 40
str_repeat() {
    local str="$1"
    local -i count="${2:-1}"
    printf "%${count}s" | tr ' ' "$str"
}

# str_pad_right - Pad a string to width (right-pad with spaces)
# Usage: str_pad_right "label" 20
str_pad_right() {
    local str="$1"
    local -i width="${2:-20}"
    printf "%-${width}s" "$str"
}

# str_contains - Check if string contains substring
# Usage: str_contains "hello world" "world" && echo "yes"
str_contains() {
    [[ "$1" == *"$2"* ]]
}

# str_starts_with - Check if string starts with prefix
# Usage: str_starts_with "hello" "hel" && echo "yes"
str_starts_with() {
    [[ "$1" == "$2"* ]]
}

# str_ends_with - Check if string ends with suffix
# Usage: str_ends_with "hello.txt" ".txt" && echo "yes"
str_ends_with() {
    [[ "$1" == *"$2" ]]
}

# ============================================================
# File Utilities
# ============================================================

# file_size_human - Print file size in human-readable format
# Usage: file_size_human /path/to/file
file_size_human() {
    local file="$1"
    [[ -e "$file" ]] || { echo "0B"; return 1 }
    local -i size
    zmodload zsh/stat 2>/dev/null && {
        local -A stat
        zstat -H stat "$file"
        size=$stat[size]
    } || size=$(wc -c < "$file")

    if (( size < 1024 )); then
        echo "${size}B"
    elif (( size < 1048576 )); then
        printf "%.1fKB\n" $(( size / 1024.0 ))
    elif (( size < 1073741824 )); then
        printf "%.1fMB\n" $(( size / 1048576.0 ))
    else
        printf "%.1fGB\n" $(( size / 1073741824.0 ))
    fi
}

# file_extension - Get file extension (without dot)
# Usage: ext=$(file_extension "archive.tar.gz")
file_extension() {
    local file="${1:t}"
    echo "${file##*.}"
}

# file_basename - Get basename without extension
# Usage: base=$(file_basename "path/to/hello.txt")
file_basename() {
    local file="${1:t}"
    echo "${file%.*}"
}

# ensure_dir - Create directory if it doesn't exist
# Usage: ensure_dir /path/to/dir
ensure_dir() {
    local dir="$1"
    [[ -d "$dir" ]] || mkdir -p "$dir" || return 1
}

# ============================================================
# Logging Utilities
# ============================================================

# Logging configuration
typeset -g _LOG_LEVEL="${LOG_LEVEL:-INFO}"
typeset -g _LOG_FILE="${LOG_FILE:-}"

_log_write() {
    local level="$1"
    shift
    local msg="$*"
    local timestamp
    zmodload zsh/datetime 2>/dev/null && \
        timestamp=$(strftime "%Y-%m-%d %H:%M:%S" $EPOCHSECONDS) || \
        timestamp=$(date "+%Y-%m-%d %H:%M:%S")

    local line="[$timestamp] [$level] $msg"
    echo "$line" >&2
    [[ -n "$_LOG_FILE" ]] && echo "$line" >> "$_LOG_FILE"
}

log_debug() { [[ "$_LOG_LEVEL" == "DEBUG" ]] && _log_write "DEBUG" "$@" || true }
log_info()  { _log_write "INFO"  "$@" }
log_warn()  { _log_write "WARN"  "$@" }
log_error() { _log_write "ERROR" "$@" }

# ============================================================
# Validation Utilities
# ============================================================

# is_integer - Check if value is an integer
# Usage: is_integer "42" && echo "yes"
is_integer() {
    [[ "$1" =~ ^-?[0-9]+$ ]]
}

# is_float - Check if value is a float
# Usage: is_float "3.14" && echo "yes"
is_float() {
    [[ "$1" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]
}

# is_email - Basic email validation
# Usage: is_email "user@example.com" && echo "valid"
is_email() {
    [[ "$1" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]
}

# is_url - Basic URL validation
# Usage: is_url "https://example.com" && echo "valid"
is_url() {
    [[ "$1" =~ ^https?://[a-zA-Z0-9.-]+(/.*)?$ ]]
}

# require_arg - Exit with error if argument is empty
# Usage: require_arg "$1" "first argument required"
require_arg() {
    local value="$1"
    local message="${2:-Argument required}"
    if [[ -z "$value" ]]; then
        log_error "$message"
        return 1
    fi
}

# ============================================================
# System Utilities
# ============================================================

# command_exists - Check if command is available
# Usage: command_exists git && echo "git found"
command_exists() {
    (( $+commands[$1] ))
}

# require_commands - Fail if any required commands are missing
# Usage: require_commands git curl jq
require_commands() {
    local missing=()
    for cmd in "$@"; do
        command_exists "$cmd" || missing+=("$cmd")
    done
    if (( ${#missing} )); then
        log_error "Required commands not found: ${missing[*]}"
        return 1
    fi
}

# get_os - Get operating system name
# Returns: linux, macos, windows, or unknown
get_os() {
    case "${OSTYPE:-}" in
        linux*)   echo "linux"   ;;
        darwin*)  echo "macos"   ;;
        cygwin*|msys*|mingw*) echo "windows" ;;
        *)        echo "unknown" ;;
    esac
}

# is_root - Check if running as root
# Usage: is_root && echo "running as root"
is_root() {
    (( EUID == 0 ))
}

# ============================================================
# Demo / self-test when run directly
# ============================================================
if [[ "${(%):-%N}" == "${0}" ]]; then
    echo "=== Function Library Demo ==="

    echo ""
    echo "--- String utilities ---"
    echo "  trim:         '$(str_trim "  hello world  ")'"
    echo "  repeat '-' 5: '$(str_repeat "-" 5)'"
    echo "  pad_right:    '$(str_pad_right "label:" 15)value'"
    str_contains "hello world" "world" && echo "  str_contains: yes"
    str_starts_with "hello.txt" "hello" && echo "  str_starts_with: yes"
    str_ends_with "hello.txt" ".txt" && echo "  str_ends_with: yes"

    echo ""
    echo "--- File utilities ---"
    echo "  extension of 'archive.tar.gz': $(file_extension 'archive.tar.gz')"
    echo "  basename  of 'path/hello.txt': $(file_basename 'path/hello.txt')"
    echo "  size of /etc/hosts: $(file_size_human /etc/hosts)"

    echo ""
    echo "--- Validation ---"
    is_integer "42"       && echo "  '42' is integer"
    is_float "3.14"       && echo "  '3.14' is float"
    is_email "u@example.com" && echo "  'u@example.com' is email"
    is_url "https://example.com" && echo "  'https://example.com' is url"

    echo ""
    echo "--- System ---"
    echo "  OS: $(get_os)"
    echo "  Is root: $(is_root && echo yes || echo no)"
    require_commands zsh ls && echo "  Required commands (zsh, ls): found"
fi
