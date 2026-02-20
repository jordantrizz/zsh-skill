#!/usr/bin/env zsh
# error_handling.zsh - Demonstrates robust error handling patterns in Zsh

# Description: Error handling and recovery patterns
# Usage: ./error_handling.zsh

echo "=== Error Handling Demo ==="

# --- Strict Mode ---
setopt ERR_EXIT NO_UNSET PIPE_FAIL LOCAL_OPTIONS LOCAL_TRAPS

# --- Trap-based Cleanup ---
echo ""
echo "--- Trap-based Cleanup ---"

cleanup() {
    local exit_code=$?
    echo "  Cleanup running (exit=$exit_code)"
    [[ -n "${TEMP_FILE:-}" ]] && rm -f "$TEMP_FILE"
}
trap cleanup EXIT

# Create a temp file (will be cleaned up automatically)
TEMP_FILE=$(mktemp)
echo "  Temp file created: $TEMP_FILE"
echo "data" > "$TEMP_FILE"
echo "  Temp file will be removed on exit"

# --- Error Trapping ---
echo ""
echo "--- Error Trapping ---"
trap 'echo "  ERROR on line $LINENO (exit=$?)"' ERR

try_command() {
    local cmd="$1"
    local allow_fail="${2:-0}"

    if ! eval "$cmd" 2>/dev/null; then
        if (( allow_fail )); then
            echo "  Command failed (allowed): $cmd"
            return 0
        fi
        echo "  Command failed (fatal): $cmd" >&2
        return 1
    fi
    echo "  Command succeeded: $cmd"
}

# Clear ERR trap for this demo
trap - ERR
try_command "true"
try_command "false" 1   # allowed failure
echo "  Continuing after allowed failure"

# --- Checking Return Codes ---
echo ""
echo "--- Return Code Patterns ---"

check_return() {
    # Method 1: if/then
    if command -v zsh > /dev/null 2>&1; then
        echo "  Method 1: zsh is available"
    fi

    # Method 2: || inline
    command -v bash > /dev/null 2>&1 || echo "  Method 2: bash not found (or not in PATH)"

    # Method 3: explicit check
    command -v python3 > /dev/null 2>&1
    local rc=$?
    echo "  Method 3: python3 check exit code = $rc"
}
check_return

# --- Pipeline Error Handling ---
echo ""
echo "--- Pipeline Errors (PIPE_FAIL) ---"

# With PIPE_FAIL, the pipeline exits with the first non-zero code
pipeline_demo() {
    setopt LOCAL_OPTIONS PIPE_FAIL
    # This will detect if any stage fails
    if echo "hello world" | grep "hello" | cat > /dev/null; then
        echo "  Pipeline succeeded"
    fi

    # Check $pipestatus for individual codes
    echo "line1" | grep "line" | wc -l > /dev/null
    echo "  Pipe statuses: ${pipestatus[@]}"
}
pipeline_demo

# --- Nested Error Handling ---
echo ""
echo "--- Nested Scopes ---"

outer() {
    setopt LOCAL_OPTIONS LOCAL_TRAPS
    trap 'echo "  outer cleanup"' EXIT
    echo "  in outer()"
    inner
    echo "  back in outer() after inner()"
}

inner() {
    setopt LOCAL_OPTIONS
    trap 'echo "  inner cleanup"' EXIT
    echo "  in inner()"
    # inner's EXIT trap fires, then outer's
}

outer

echo ""
echo "=== Demo complete ==="
