#!/usr/bin/env zsh
# async_jobs.zsh - Demonstrates background jobs and parallel execution

# Description: Asynchronous job management in Zsh
# Usage: ./async_jobs.zsh

setopt NO_MONITOR   # suppress job notifications for cleaner output

echo "=== Async Jobs Demo ==="

# --- Background Jobs ---
echo ""
echo "--- Background Jobs ---"

# Simulate work function
do_work() {
    local name="$1"
    local duration="$2"
    sleep "$duration"
    echo "  Task '$name' completed (${duration}s)"
}

# Run jobs in background and capture PIDs
echo "  Starting background tasks..."
do_work "alpha"  1 &; local pid_alpha=$!
do_work "beta"   2 &; local pid_beta=$!
do_work "gamma"  1 &; local pid_gamma=$!

# Wait for specific job
wait $pid_alpha && echo "  alpha is done"
wait $pid_gamma && echo "  gamma is done"
wait $pid_beta  && echo "  beta is done"

# --- Parallel Execution with Exit Code Tracking ---
echo ""
echo "--- Parallel with exit codes ---"

run_parallel() {
    local -a pids=()
    local -a labels=()
    local -i failures=0

    for task in "$@"; do
        eval "$task" &
        pids+=($!)
        labels+=("$task")
    done

    for i in "${!pids[@]}"; do
        if wait "${pids[$i]}"; then
            echo "  [OK]   ${labels[$i]}"
        else
            echo "  [FAIL] ${labels[$i]}"
            (( failures++ ))
        fi
    done

    return $failures
}

# Define some quick tasks (using true/false for demo)
run_parallel \
    "true" \
    "true" \
    "false" \
    "true"
echo "  Failures: $?"

# --- Timeout Pattern ---
echo ""
echo "--- Command Timeout ---"

run_with_timeout() {
    local timeout="$1"
    shift

    "$@" &
    local pid=$!

    (
        sleep "$timeout"
        kill "$pid" 2>/dev/null
    ) &
    local watchdog=$!

    wait "$pid" 2>/dev/null
    local exit_code=$?
    kill "$watchdog" 2>/dev/null
    wait "$watchdog" 2>/dev/null

    return $exit_code
}

if run_with_timeout 2 sleep 1; then
    echo "  Command completed in time"
else
    echo "  Command timed out"
fi

# --- Background with zsh/zutil ---
echo ""
echo "--- Job Status ---"
sleep 3 &
local bg_pid=$!
echo "  Background job PID: $bg_pid"
echo "  Is running: $(kill -0 $bg_pid 2>/dev/null && echo yes || echo no)"
wait $bg_pid
echo "  Job finished with exit code: $?"
