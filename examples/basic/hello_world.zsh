#!/usr/bin/env zsh
# hello_world.zsh - Basic Zsh script demonstrating variables, output, and user input

# Script metadata
# Description: Hello World demonstration script
# Usage: ./hello_world.zsh [name]

# --- Variables ---
readonly GREETING="Hello"
readonly DEFAULT_NAME="World"

name="${1:-$DEFAULT_NAME}"

# --- Output ---
echo "$GREETING, $name!"
print -P "%F{green}Welcome to Zsh scripting!%f"

# --- Simple Arithmetic ---
current_year=$(date +%Y)
birth_year=2000
age=$(( current_year - birth_year ))
echo "If born in $birth_year, you would be approximately $age years old."

# --- String Operations ---
upper_name="${(U)name}"
lower_name="${(L)name}"
echo "Upper: $upper_name"
echo "Lower: $lower_name"
echo "Length: ${#name} characters"
