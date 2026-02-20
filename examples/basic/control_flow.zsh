#!/usr/bin/env zsh
# control_flow.zsh - Demonstrates conditionals, loops, and control structures

# Description: Control flow examples
# Usage: ./control_flow.zsh

echo "=== Control Flow Demo ==="

# --- If/elif/else ---
check_number() {
    local n="${1:?Number required}"
    if (( n > 0 )); then
        echo "$n is positive"
    elif (( n < 0 )); then
        echo "$n is negative"
    else
        echo "$n is zero"
    fi
}
check_number 5
check_number -3
check_number 0

# --- Case statement ---
echo ""
echo "--- Case statement ---"
describe_file() {
    local file="$1"
    case "$file" in
        *.zsh|*.sh)  echo "$file: shell script" ;;
        *.md)        echo "$file: markdown document" ;;
        *.txt)       echo "$file: text file" ;;
        *.log)       echo "$file: log file" ;;
        */*)         echo "$file: file with path separator" ;;
        *)           echo "$file: unknown type" ;;
    esac
}
describe_file "script.zsh"
describe_file "readme.md"
describe_file "data.csv"

# --- For loops ---
echo ""
echo "--- For loops ---"
fruits=(apple banana cherry date elderberry)
for fruit in "${fruits[@]}"; do
    echo "  Fruit: $fruit"
done

echo ""
echo "  Numeric range (C-style):"
for (( i = 1; i <= 5; i++ )); do
    printf "  %d" $i
done
echo

echo ""
echo "  Brace expansion:"
for n in {1..5}; do
    printf "  %d" $n
done
echo

# --- While loop ---
echo ""
echo "--- While loop (countdown) ---"
count=5
while (( count > 0 )); do
    printf "  %d..." $count
    (( count-- ))
done
echo " Go!"

# --- Until loop ---
echo ""
echo "--- Until loop ---"
x=0
until (( x >= 3 )); do
    echo "  x = $x"
    (( x++ ))
done

# --- Loop control ---
echo ""
echo "--- Break and continue ---"
for i in {1..10}; do
    (( i % 2 == 0 )) && continue   # skip even
    (( i > 7 )) && break            # stop at 7
    echo "  Odd number: $i"
done

# --- Repeat ---
echo ""
echo "--- Repeat command ---"
repeat 3 echo "  Repeated!"
