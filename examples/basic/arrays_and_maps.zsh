#!/usr/bin/env zsh
# arrays_and_maps.zsh - Demonstrates indexed and associative arrays

# Description: Arrays and associative arrays examples
# Usage: ./arrays_and_maps.zsh

echo "=== Arrays and Maps Demo ==="

# --- Indexed Arrays ---
echo ""
echo "--- Indexed Arrays ---"
fruits=(apple banana cherry)
echo "  Array: ${fruits[@]}"
echo "  Length: ${#fruits}"
echo "  First:  ${fruits[1]}"
echo "  Last:   ${fruits[-1]}"
echo "  Slice [1,2]: ${fruits[1,2]}"

# Append to array
fruits+=(date elderberry)
echo "  After append: ${fruits[@]}"

# Remove element (filter out 'banana')
fruits=("${(@)fruits:#banana}")
echo "  After removing 'banana': ${fruits[@]}"

# Sort array
sorted_fruits=("${(@o)fruits}")
echo "  Sorted: ${sorted_fruits[@]}"

# Unique elements
words=(apple banana apple cherry banana)
unique_words=("${(@u)words}")
echo "  Unique from (${words[@]}): ${unique_words[@]}"

# --- Array Operations ---
echo ""
echo "--- Array Operations ---"
local -a numbers=(5 3 8 1 9 2 7 4 6)
echo "  Numbers: ${numbers[@]}"
echo "  Count:   ${#numbers}"

# Find max value
max=${numbers[1]}
for n in "${numbers[@]}"; do
    (( n > max )) && max=$n
done
echo "  Max:     $max"

# Sum all values
local -i total=0
for n in "${numbers[@]}"; do
    (( total += n ))
done
echo "  Sum:     $total"

# --- Associative Arrays (Hash Maps) ---
echo ""
echo "--- Associative Arrays ---"
typeset -A user
user[name]="Alice"
user[email]="alice@example.com"
user[role]="admin"
user[active]="true"

echo "  Name:  $user[name]"
echo "  Email: $user[email]"

# Check if key exists
if (( ${+user[role]} )); then
    echo "  Role:  $user[role]"
fi

# Iterate over keys
echo ""
echo "  All entries:"
for key in "${(@k)user}"; do
    echo "    $key = $user[$key]"
done

# Keys and values sorted by key
echo ""
echo "  Sorted keys:"
for key in "${(@ko)user}"; do
    echo "    $key = $user[$key]"
done

# Delete a key
unset 'user[active]'
echo ""
echo "  After deleting 'active', keys: ${(@k)user}"

# --- Nested Data (simulated) ---
echo ""
echo "--- Simulated nested structure ---"
typeset -A servers
servers[web]="192.168.1.10"
servers[db]="192.168.1.20"
servers[cache]="192.168.1.30"

for name in "${(@ko)servers}"; do
    echo "  $name -> $servers[$name]"
done
