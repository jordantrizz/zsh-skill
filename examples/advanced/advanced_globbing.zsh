#!/usr/bin/env zsh
# advanced_globbing.zsh - Demonstrates Zsh's powerful glob features

# Description: Advanced globbing and file filtering
# Usage: ./advanced_globbing.zsh [directory]

setopt EXTENDED_GLOB NULL_GLOB

readonly SEARCH_DIR="${1:-.}"

echo "=== Advanced Globbing Demo ==="
echo "Searching in: $SEARCH_DIR"

# --- Basic Glob Qualifiers ---
echo ""
echo "--- Glob Qualifiers ---"

# Regular files only (.)
local -a regular_files=("$SEARCH_DIR"/*(.N))
echo "  Regular files: ${#regular_files}"

# Directories only (/)
local -a dirs=("$SEARCH_DIR"/*(/N))
echo "  Directories: ${#dirs}"

# Executable files (*)
local -a executables=("$SEARCH_DIR"/*(*N))
echo "  Executables: ${#executables}"

# Symbolic links (@)
local -a symlinks=("$SEARCH_DIR"/*(@N))
echo "  Symlinks: ${#symlinks}"

# --- Size Qualifiers ---
echo ""
echo "--- Size Qualifiers ---"

# Files larger than 1 KB
local -a large_files=("$SEARCH_DIR"/*(.Lk+1N))
echo "  Files > 1KB: ${#large_files}"

# Empty files
local -a empty_files=("$SEARCH_DIR"/*(.L0N))
echo "  Empty files: ${#empty_files}"

# --- Time Qualifiers ---
echo ""
echo "--- Time Qualifiers ---"

# Files modified in last 24 hours
local -a recent=("$SEARCH_DIR"/*(.mh-24N))
echo "  Modified in last 24h: ${#recent}"

# Files accessed in last week
local -a accessed_recently=("$SEARCH_DIR"/*(.ah-168N))
echo "  Accessed in last 7 days: ${#accessed_recently}"

# --- Sorting Qualifiers ---
echo ""
echo "--- Sorting ---"

# Three newest files by modification time
local -a newest=("$SEARCH_DIR"/*(.NomON[1,3]))
echo "  3 newest files:"
for f in "${newest[@]}"; do
    echo "    ${f:t}"
done

# Three largest files
local -a largest=("$SEARCH_DIR"/*(.NLOoN[1,3]))
echo "  3 largest files:"
for f in "${largest[@]}"; do
    zmodload zsh/stat
    local -A stat_info
    zstat -H stat_info "$f"
    echo "    ${f:t} (${stat_info[size]} bytes)"
done

# --- Extended Glob Patterns ---
echo ""
echo "--- Extended Glob (EXTENDED_GLOB) ---"

# Negation: all files except .zsh
local -a non_zsh=("$SEARCH_DIR"/^*.zsh(.N))
echo "  Non-.zsh files: ${#non_zsh}"

# Recursive search
local -a all_zsh=("$SEARCH_DIR"/**/*.zsh(.N))
echo "  All .zsh files (recursive): ${#all_zsh}"
for f in "${all_zsh[@]}"; do
    echo "    ${f#$SEARCH_DIR/}"
done

# --- Pattern Alternation ---
echo ""
echo "--- Pattern Alternation ---"
local -a doc_files=("$SEARCH_DIR"/**/(*.md|*.txt)(.N))
echo "  Markdown and text files: ${#doc_files}"

# --- Combining Qualifiers ---
echo ""
echo "--- Combined Qualifiers ---"
# Writable regular files modified today, sorted by name
local -a writable_today=("$SEARCH_DIR"/*(.Wm0Non))
echo "  Writable files modified today: ${#writable_today}"
