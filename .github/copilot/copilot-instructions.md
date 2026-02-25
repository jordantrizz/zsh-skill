# GitHub Copilot Instructions — zsh-skill

This repository is a comprehensive Zsh scripting knowledge base designed for AI-assisted development. The following instructions help GitHub Copilot provide accurate, idiomatic Zsh suggestions.

## Language & Dialect

- Always generate **Zsh** (not Bash) code unless explicitly asked for Bash.
- Use `#!/usr/bin/env zsh` as the shebang for executable scripts.
- Target **Zsh 5.0+** compatibility.

## Code Style

- Quote all variable expansions: `"$var"`, not `$var`.
- Use `local` for all variables inside functions.
- Use `typeset -A` for associative arrays (not `declare -A`).
- Use `[[ ... ]]` for conditionals (not `[ ... ]`).
- Use `(( ... ))` for arithmetic expressions.
- Use `print` instead of `echo` for formatted output in scripts.
- Use `return` (never `exit`) inside sourced functions/libraries.
- Use `readonly SCRIPT_DIR="${0:A:h}"` for script-relative paths.

## Error Handling

Always include error handling in scripts:

```zsh
setopt ERR_EXIT PIPE_FAIL NO_UNSET

function cleanup() {
    # cleanup logic here
}
trap cleanup EXIT INT TERM
```

## Function Conventions

```zsh
## Brief one-line description of what the function does.
## @param $1 description of first argument
## @return 0 on success, 1 on error
function my_function() {
    local arg1="${1:?arg1 is required}"
    local result
    # implementation
}
```

## Array Usage

```zsh
# Indexed arrays (1-based in Zsh)
local -a files=()
files+=("file1.txt")
print "${files[1]}"      # first element
print "${files[@]}"      # all elements
print "${#files[@]}"     # count

# Associative arrays
local -A config=()
config[key]="value"
```

## Glob Patterns

Prefer Zsh glob qualifiers over `find`:

```zsh
# Files only (not directories)
local -a files=(*(.) )

# Directories only
local -a dirs=(*(/))

# Files modified in last 24 hours
local -a recent=(*(mh-24))

# Recursive glob
local -a all_zsh=(**/*.zsh)
```

## Knowledge Base References

When generating Zsh code, reference these source documents:

| Topic | Source File |
|-------|------------|
| Basics & syntax | `sources/zsh-basics.md` |
| Advanced features | `sources/zsh-advanced.md` |
| Best practices | `sources/zsh-best-practices.md` |
| Scripting patterns | `sources/zsh-scripting-patterns.md` |
| Troubleshooting | `sources/zsh-troubleshooting.md` |
| Ecosystem & plugins | `sources/zsh-ecosystem.md` |
| Quick reference | `sources/zsh-reference.md` |
| FAQ | `sources/zsh-faq.md` |

## Common Pitfalls to Avoid

1. **Don't use `echo` for scripts** — use `print` or `printf`.
2. **Don't use `$array[0]`** — Zsh arrays are 1-indexed.
3. **Don't use `declare`** — use `typeset` or `local`.
4. **Don't `exit` from sourced files** — use `return`.
5. **Don't forget `NULL_GLOB`** when globs might match nothing:
   ```zsh
   setopt NULL_GLOB
   rm *.tmp
   unsetopt NULL_GLOB
   ```
6. **Don't split variables with spaces** — use `${=var}` explicitly when word-splitting is needed.

## Testing

New scripts should have corresponding ShellSpec specs in `tests/unit/`. Follow the pattern:

```sh
#!/usr/bin/env sh
# tests/unit/my_script_spec.sh

Describe 'my_script.zsh'
  my_script() { zsh "${SHELLSPEC_SPECDIR}/../examples/basic/my_script.zsh" "$@"; }

  It 'exits with status 0'
    When run my_script
    The status should be success
  End
End
```
