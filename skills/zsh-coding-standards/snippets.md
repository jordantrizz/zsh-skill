# Snippets for `zsh-coding-standards`

## Script Header

```zsh
#!/usr/bin/env zsh

set -euo pipefail

log_error() {
  print -u2 -- "error: $*"
}

usage() {
  print -- "Usage: ${0:t} <required-arg>"
}

main() {
  local required_arg="${1:-}"

  if [[ -z "$required_arg" ]]; then
    usage
    return 2
  fi

  # Script logic here
}

main "$@"
```

## Function Template

```zsh
do_work() {
  local input_path="${1:-}"

  if [[ -z "$input_path" ]]; then
    print -u2 -- "error: missing input path"
    return 2
  fi

  if [[ ! -e "$input_path" ]]; then
    print -u2 -- "error: path does not exist: $input_path"
    return 1
  fi

  # Function logic
}
```

## Safe Globbing Pattern

```zsh
setopt null_glob
local files=("$directory"/*.zsh(.N))

if (( ${#files[@]} == 0 )); then
  print -u2 -- "error: no matching files"
  return 1
fi
```