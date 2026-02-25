#!/usr/bin/env zsh
# file_operations.zsh - Demonstrates common file operations in Zsh

# Description: File operations example
# Usage: ./file_operations.zsh [directory]

setopt ERR_EXIT NO_UNSET

readonly TARGET_DIR="${1:-.}"

echo "=== File Operations Demo ==="
echo "Target directory: $TARGET_DIR"

# --- List files by type ---
echo ""
echo "--- Regular files ---"
for f in "$TARGET_DIR"/*(.N); do
    echo "  FILE: ${f:t}"
done

echo ""
echo "--- Directories ---"
for d in "$TARGET_DIR"/*(/N); do
    echo "  DIR:  ${d:t}/"
done

# --- File checks ---
echo ""
echo "--- File checks ---"
check_file() {
    local file="$1"
    [[ -e "$file" ]] || { echo "  '$file' does not exist"; return }
    [[ -f "$file" ]] && echo "  '$file' is a regular file"
    [[ -d "$file" ]] && echo "  '$file' is a directory"
    [[ -r "$file" ]] && echo "  '$file' is readable"
    [[ -w "$file" ]] && echo "  '$file' is writable"
    [[ -x "$file" ]] && echo "  '$file' is executable"
}
check_file "$TARGET_DIR"
check_file "/etc/hosts"

# --- Glob patterns ---
echo ""
echo "--- Zsh glob examples ---"
echo "  Zsh files: ${#TARGET_DIR}/**/*.zsh(DN) items would match *.zsh"
echo "  Hidden files: use *(D.) to include dotfiles"

# --- Counting files ---
local -a all_files=("$TARGET_DIR"/*(.N))
echo ""
echo "Total files in '$TARGET_DIR': ${#all_files}"
