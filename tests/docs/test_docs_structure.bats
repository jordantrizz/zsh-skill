#!/usr/bin/env bats
# test_docs_structure.bats - Documentation validation tests

REPO_ROOT="$BATS_TEST_DIRNAME/../.."
SOURCES_DIR="$REPO_ROOT/sources"

# --- Required top-level files ---

@test "README.md exists" {
    [ -f "$REPO_ROOT/README.md" ]
}

@test "TODO.md exists" {
    [ -f "$REPO_ROOT/TODO.md" ]
}

@test "BUILD.md exists" {
    [ -f "$REPO_ROOT/BUILD.md" ]
}

@test "AGENTS.md exists" {
    [ -f "$REPO_ROOT/AGENTS.md" ]
}

@test "CONTRIBUTING.md exists" {
    [ -f "$REPO_ROOT/CONTRIBUTING.md" ]
}

# --- Required sources/ documents ---

@test "sources/zsh-basics.md exists" {
    [ -f "$SOURCES_DIR/zsh-basics.md" ]
}

@test "sources/zsh-advanced.md exists" {
    [ -f "$SOURCES_DIR/zsh-advanced.md" ]
}

@test "sources/zsh-best-practices.md exists" {
    [ -f "$SOURCES_DIR/zsh-best-practices.md" ]
}

@test "sources/zsh-scripting-patterns.md exists" {
    [ -f "$SOURCES_DIR/zsh-scripting-patterns.md" ]
}

@test "sources/zsh-troubleshooting.md exists" {
    [ -f "$SOURCES_DIR/zsh-troubleshooting.md" ]
}

@test "sources/zsh-ecosystem.md exists" {
    [ -f "$SOURCES_DIR/zsh-ecosystem.md" ]
}

@test "sources/zsh-reference.md exists" {
    [ -f "$SOURCES_DIR/zsh-reference.md" ]
}

# --- Required examples/ scripts ---

@test "examples/basic/ directory exists" {
    [ -d "$REPO_ROOT/examples/basic" ]
}

@test "examples/advanced/ directory exists" {
    [ -d "$REPO_ROOT/examples/advanced" ]
}

@test "examples/functions/ directory exists" {
    [ -d "$REPO_ROOT/examples/functions" ]
}

@test "examples/config/ directory exists" {
    [ -d "$REPO_ROOT/examples/config" ]
}

# --- Source document content checks ---

@test "zsh-basics.md contains non-empty content" {
    [ -s "$SOURCES_DIR/zsh-basics.md" ]
}

@test "zsh-best-practices.md contains non-empty content" {
    [ -s "$SOURCES_DIR/zsh-best-practices.md" ]
}

@test "zsh-advanced.md contains non-empty content" {
    [ -s "$SOURCES_DIR/zsh-advanced.md" ]
}

# --- All .zsh example files are non-empty ---

@test "all .zsh files in examples/ are non-empty" {
    local empty_files
    empty_files=$(find "$REPO_ROOT/examples" -name "*.zsh" -empty)
    [ -z "$empty_files" ]
}

# --- All .zsh example files have a shebang ---

@test "all .zsh files in examples/ have a shebang line" {
    local missing
    missing=$(find "$REPO_ROOT/examples" -name "*.zsh" | while read -r f; do
        head -1 "$f" | grep -qE "^#!" || echo "$f"
    done)
    [ -z "$missing" ]
}
