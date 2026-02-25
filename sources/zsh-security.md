# Zsh Security Best Practices

<!-- semantic-tags: security, vulnerabilities, secure-coding, hardening -->

## Security Best Practices Guide

### Principle of Least Privilege

Scripts should request and use only the permissions they need.

```zsh
#!/usr/bin/env zsh

# Never run scripts as root unless explicitly required.
# Check and abort early if elevated privileges are unneeded:
if (( EUID == 0 )); then
    print -u2 "Error: do not run this script as root"
    exit 1
fi

# When root is required, drop privileges as soon as possible:
escalated_task() {
    sudo chown root:root /etc/myapp/config
    # All subsequent work uses the original user
}
```

### Input Validation

Always validate external input before using it in commands, file paths, or
variable assignments.

```zsh
# Validate a username (alphanumeric + underscore only)
validate_username() {
    local name="$1"
    if [[ ! "$name" =~ '^[a-zA-Z0-9_]{1,32}$' ]]; then
        print -u2 "Invalid username: ${name}"
        return 1
    fi
}

# Validate a file path stays within an allowed directory
validate_path() {
    local base_dir="$1"
    local user_path="$2"
    # Resolve to absolute path; :A resolves symlinks and ..
    local resolved="${user_path:A}"
    if [[ "$resolved" != "${base_dir}"/* ]]; then
        print -u2 "Path traversal detected: ${user_path}"
        return 1
    fi
}

# Usage
validate_path "/var/data" "$user_supplied_path" || exit 1
```

### Variable Quoting

Unquoted variables are the most common source of injection bugs in shell scripts.

```zsh
# Dangerous: word-splitting and glob expansion on unquoted variable
rm $user_file           # If user_file="* /etc/passwd", deletes everything

# Safe: always quote variables
rm -- "$user_file"

# Dangerous: variable in arithmetic context can execute code via (( ))
(( result = $user_input ))    # user_input="1; rm -rf /" executes rm

# Safe: validate numeric input before arithmetic
if [[ "$user_input" =~ '^-?[0-9]+$' ]]; then
    (( result = user_input ))
else
    print -u2 "Non-numeric input rejected"
    exit 1
fi
```

### Avoid `eval`

`eval` executes arbitrary code and should be avoided wherever possible.

```zsh
# Dangerous: eval with user-supplied data
eval "echo $user_message"       # user_message="\$(rm -rf /)" causes RCE

# Safe alternatives:

# 1. Use arrays for dynamic command construction
local -a cmd=(grep -r "$pattern" "$directory")
"${cmd[@]}"

# 2. Use parameter expansion instead of eval for dynamic variable names
local prefix="LOG"
local varname="${prefix}_LEVEL"
# Dangerous:
eval "level=\$$varname"
# Safe (Zsh-specific):
level=${(P)varname}             # indirect expansion, no eval

# 3. Use zformat for structured output instead of eval-based templates
zmodload zsh/zutil
local output
zformat -f output "%h:%p" h:"$host" p:"$port"
```

### Secure Temporary Files

```zsh
# Dangerous: predictable temp file name allows symlink attacks
tmp="/tmp/myscript.$$"
echo "data" > "$tmp"

# Safe: use mktemp for unpredictable names
tmp=$(mktemp)                   # e.g. /tmp/tmp.Xk3j9A
tmp_dir=$(mktemp -d)            # secure temp directory

# Always clean up, even on error
cleanup() { rm -f "$tmp"; rm -rf "$tmp_dir"; }
trap cleanup EXIT INT TERM
```

### Safe `PATH` Handling

```zsh
# Dangerous: relative paths in PATH allow command hijacking
export PATH=".:$PATH"           # attacker places "ls" in current dir

# Safe: use only absolute paths; audit PATH in scripts
sanitize_path() {
    # Remove . and empty entries from PATH
    local -a path_parts=("${(@s/:/)PATH}")
    local -a safe_parts
    for p in "${path_parts[@]}"; do
        [[ "$p" == "." || -z "$p" ]] && continue
        [[ "$p" == /* ]] || continue   # skip relative entries
        safe_parts+=("$p")
    done
    export PATH="${(j/:/)safe_parts}"
}

# For scripts that must run in untrusted environments, set PATH explicitly:
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
```

### `IFS` Protection

```zsh
# Restoring IFS prevents word-splitting attacks from modified environments
safe_split() {
    local old_ifs="$IFS"
    IFS=":"                     # controlled separator
    local -a parts=($PATH)
    IFS="$old_ifs"
    print -l "${parts[@]}"
}

# Or use Zsh parameter expansion — unaffected by IFS:
local -a parts=("${(@s/:/)PATH}")   # always splits on : regardless of IFS
```

### `umask` for File Creation

```zsh
# Default umask may allow group/world read of created files
# Set a restrictive umask before creating sensitive files
old_umask=$(umask)
umask 0077                    # owner read/write only
print "secret_token=$token" > ~/.config/app/token
umask "$old_umask"            # restore original mask
```

### Avoid Storing Secrets in Scripts or Environment Variables

```zsh
# Dangerous: secret in script source (committed to VCS)
db_password="super_secret_123"

# Dangerous: secret in environment (visible in /proc/*/environ)
export DB_PASSWORD="super_secret_123"

# Better: read from a restricted file at runtime
read -r db_password < ~/.config/app/db_password   # file mode 0600

# Best: use a secrets manager or prompt at runtime
if [[ -z "$DB_PASSWORD" ]]; then
    read -rs "db_password?Database password: "
    print ""   # newline after hidden input
fi

# Scrub secrets from memory when done (Zsh 5+)
db_password=""
unset db_password
```

---

## Common Vulnerabilities

### 1. Command Injection via Unquoted Variables

```zsh
# Vulnerable
search_files() { find /data -name $1; }   # $1 unquoted

# Exploit: search_files "*.log; rm -rf /data"

# Fixed: quote all variables
search_files() { find /data -name "$1"; }
```

### 2. Path Traversal

```zsh
# Vulnerable
serve_file() { cat "/var/www/$1"; }       # $1 uncontrolled

# Exploit: serve_file "../../etc/passwd"

# Fixed: resolve and validate path
serve_file() {
    local resolved="${1:A}"
    [[ "$resolved" == /var/www/* ]] || { print -u2 "Forbidden"; return 1; }
    cat "$resolved"
}
```

### 3. Privilege Escalation via `sudo` Misconfiguration

```zsh
# Dangerous: script accepts arbitrary command from user and runs it with sudo
run_privileged() { sudo "$@"; }           # Never do this

# Safe: only allow a predefined set of actions
run_privileged() {
    case "$1" in
        reload) sudo systemctl reload nginx ;;
        status) sudo systemctl status nginx ;;
        *)      print -u2 "Disallowed action: $1"; return 1 ;;
    esac
}
```

### 4. Glob Injection

```zsh
# Vulnerable: user controls glob pattern
delete_logs() { rm /var/log/$1/*.log; }

# Exploit: delete_logs "../../etc"

# Fixed: disable glob expansion for user data + validate
delete_logs() {
    local service="$1"
    [[ "$service" =~ '^[a-zA-Z0-9_-]+$' ]] || return 1
    setopt LOCAL_OPTIONS NO_GLOB
    rm -- "/var/log/${service}/"*.log    # glob on fixed prefix only
}
```

### 5. Symlink Attacks on Temp Files

```zsh
# Vulnerable: predictable temp file; attacker pre-creates symlink
echo "data" > /tmp/script_output_$$      # attacker links to /etc/cron.d/evil

# Fixed: use mktemp (atomically creates a unique, non-existent file)
local tmp; tmp=$(mktemp) || exit 1
echo "data" > "$tmp"
trap "rm -f $tmp" EXIT
```

### 6. `PROMPT_SUBST` Injection

```zsh
# If PROMPT_SUBST is set, a malicious directory name can execute code:
# cd into a dir named "$(evil_command)" and the prompt evaluates it

# Safe: use %~ (percent-expansion) in prompts, not $PWD
setopt PROMPT_SUBST
# Dangerous:
PROMPT="$PWD %# "          # PWD evaluated at assignment; OK but static
RPROMPT='$(git_branch)'    # Fine if git_branch is a trusted function

# Truly safe: disable PROMPT_SUBST and use percent sequences only:
unsetopt PROMPT_SUBST
PROMPT='%n@%m %~%# '       # percent sequences, never executes code
```

### 7. `source` / `.` with Untrusted Files

```zsh
# Dangerous: sourcing untrusted content executes arbitrary code
source "$user_config"

# Safe: validate the file before sourcing
load_config() {
    local cfg="$1"
    [[ -f "$cfg" && -r "$cfg" ]] || return 1
    # Only allow simple KEY=VALUE lines; reject anything else
    if grep -qvE '^[A-Z_]+=.*$|^#|^$' "$cfg"; then
        print -u2 "Config contains disallowed content: $cfg"
        return 1
    fi
    source "$cfg"
}
```

---

## Secure Coding Examples

### Secure File Processing Script

```zsh
#!/usr/bin/env zsh
# secure_process.zsh — demonstrates secure coding patterns

setopt ERR_EXIT NO_UNSET PIPE_FAIL

readonly ALLOWED_DIR="/var/data/uploads"
readonly MAX_FILE_SIZE=$(( 10 * 1024 * 1024 ))   # 10 MB

# Ensure cleanup on any exit
tmp_work=$(mktemp -d)
trap "rm -rf ${(q)tmp_work}" EXIT INT TERM

# Validate file path
check_file() {
    local file="${1:A}"   # resolve symlinks and ..
    [[ "$file" == "${ALLOWED_DIR}/"* ]]  || { print -u2 "Path out of bounds"; return 1; }
    [[ -f "$file" ]]                      || { print -u2 "Not a regular file"; return 1; }
    [[ -r "$file" ]]                      || { print -u2 "Not readable"; return 1; }
    local size
    size=$(stat -c %s "$file" 2>/dev/null || stat -f %z "$file")
    (( size <= MAX_FILE_SIZE ))           || { print -u2 "File too large"; return 1; }
}

# Process validated file
process_file() {
    local src="$1"
    check_file "$src" || return 1

    local dest="${tmp_work}/${src:t}"
    cp -- "$src" "$dest"
    chmod 0600 "$dest"

    # ... processing logic here ...
    print "Processed: ${src:t}"
}

process_file "${1:?Usage: $0 <file>}"
```

### Secure Credential Handling

```zsh
#!/usr/bin/env zsh
# credentials.zsh — safely reading and scrubbing secrets

# Read a secret from a restricted file
read_secret_file() {
    local secret_file="$1"
    [[ -f "$secret_file" ]]           || { print -u2 "Secret file missing"; return 1; }
    local perms
    perms=$(stat -c %a "$secret_file" 2>/dev/null || stat -f %Lp "$secret_file")
    # Warn if group or world readable
    if [[ "$perms" != "600" && "$perms" != "400" ]]; then
        print -u2 "Warning: secret file $secret_file has loose permissions ($perms)"
    fi
    read -r REPLY < "$secret_file"
}

# Prompt for a password without echoing
read_password() {
    local prompt="${1:-Password: }"
    local pass
    read -rs "pass?${prompt}"
    print ""   # newline after hidden input
    print -n "$pass"
}

# Scrub secret after use
scrub_secret() {
    local varname="$1"
    eval "${varname}=''"
    unset "$varname"
}
```

---

## Security Checklist

Use this checklist before deploying any Zsh script that handles external input,
sensitive data, or elevated privileges.

### Input Handling
- [ ] All external inputs are validated against an allowlist before use
- [ ] File paths are resolved (`:A`) and checked against an allowed base directory
- [ ] Numeric inputs are validated with a regex before arithmetic operations
- [ ] `eval` is not used with any data that originates outside the script

### Variable and Quoting Safety
- [ ] All variables are quoted (`"$var"`) in command arguments
- [ ] `--` is used before variable file arguments (`rm -- "$file"`)
- [ ] `${(P)varname}` is used instead of `eval "echo \$$varname"` for indirect expansion
- [ ] `IFS` is not modified globally; changes are localised with `setopt LOCAL_OPTIONS`

### Privilege and Process Isolation
- [ ] Script does not run as root unless required; drops privileges early
- [ ] `sudo` calls are limited to specific, hardcoded commands
- [ ] Child processes do not inherit unnecessary environment variables
- [ ] `PATH` is set explicitly to known-good absolute directories

### Temporary Files and Resources
- [ ] All temporary files are created with `mktemp` (not predictable names)
- [ ] Temporary files/directories are cleaned up with a `trap ... EXIT` handler
- [ ] Sensitive files are created with `umask 0077` (or equivalent `chmod 0600`)
- [ ] File descriptors are closed after use (`exec {fd}>&-`)

### Secrets and Credentials
- [ ] No secrets are hardcoded in the script source
- [ ] Secrets are not exported as environment variables unless required by a child process
- [ ] Secrets are scrubbed (`unset`) from memory after use
- [ ] Credential files are checked for overly permissive modes before reading

### Code Sourcing and Dynamic Execution
- [ ] `source`/`.` is used only on trusted, validated files
- [ ] Dynamic config files are validated (allowlist of `KEY=VALUE` patterns) before sourcing
- [ ] `PROMPT_SUBST` prompts use only percent-sequences or trusted function calls

### Error Handling
- [ ] `setopt ERR_EXIT NO_UNSET PIPE_FAIL` (or equivalent) is set at script top
- [ ] Errors are reported to `stderr` (`print -u2` or `>&2`), not `stdout`
- [ ] Non-zero exit codes propagate correctly; partial success states are handled explicitly

---

<!-- related: sources/zsh-best-practices.md, sources/zsh-scripting-patterns.md, sources/zsh-troubleshooting.md -->
