# Code Review Prompts

Prompt templates for reviewing Zsh code with AI assistants.

---

## 📌 Usage Notes

Paste your code where `[CODE]` appears. Attach the indicated context files for more
targeted feedback. The checklist at the end of this file summarises what the AI
should check in every review.

---

## 🔍 Template 1 — Quick Review

**When to use:** You want a fast sanity-check before committing.

**Context files to include:** `sources/zsh-best-practices.md`

---

[PROMPT START]

You are an expert Zsh code reviewer. Do a quick review of the following Zsh code.
Check for obvious bugs, unquoted variables, missing error handling, and any practices
that violate Zsh best practices.

Respond with:
1. A one-sentence overall verdict (looks good / needs minor fixes / needs major work).
2. A bullet list of issues found, ordered from most to least severe.
3. For each issue, show the original line and the corrected version.

Keep the review concise — focus on correctness and safety, not style.

```zsh
[CODE]
```

[PROMPT END]

---

## 🔍 Template 2 — Thorough Review

**When to use:** You want a comprehensive review of a complete script before merging.

**Context files to include:** `sources/zsh-best-practices.md`, `sources/zsh-scripting-patterns.md`, `sources/zsh-advanced.md`

---

[PROMPT START]

You are an expert Zsh developer performing a thorough code review. Review the following
Zsh script against the best practices guide provided as context.

Evaluate each of the following categories and give a rating (✅ Good / ⚠️ Needs work / ❌ Problem):

**Correctness**
- Logic errors or off-by-one issues
- Incorrect use of exit codes
- Conditions that are always true/false

**Safety and Robustness**
- Unquoted variable expansions that could cause word splitting or globbing
- Missing or incorrect error handling
- Failure to check command exit codes
- Insecure use of temporary files

**Zsh Best Practices** (per the attached guide)
- Strict mode (`setopt ERR_EXIT NO_UNSET PIPE_FAIL`)
- Local variable scoping with `local`
- `[[ ]]` instead of `[ ]` for tests
- `(( ))` for arithmetic instead of `[ $a -eq $b ]`
- Prefer Zsh built-ins over unnecessary external commands

**Readability and Maintainability**
- Function and variable naming conventions
- Appropriate use of comments
- Script structure (usage function, main function, argument parsing)

**Edge Cases**
- Empty input
- Files with spaces in their names
- Arguments with special characters

After the category ratings, provide:
- A prioritised list of specific changes to make (most critical first)
- One or two concrete code improvements as diffs or before/after blocks

```zsh
[CODE]
```

[PROMPT END]

---

## 🔍 Template 3 — Security Review

**When to use:** The script handles user input, external data, credentials, or runs with elevated privileges.

**Context files to include:** `sources/zsh-best-practices.md`, `sources/zsh-troubleshooting.md`

---

[PROMPT START]

You are a security-focused Zsh code reviewer. Review the following Zsh script for
security vulnerabilities and unsafe patterns.

Focus on:

**Input Validation**
- Are all arguments and environment variables validated before use?
- Is there protection against path traversal (e.g., `../../../etc/passwd`)?
- Are filenames from external sources sanitised before use in commands?

**Injection Risks**
- Could any variable expansion be used for command injection?
- Are there cases where user-controlled input is passed to `eval`, command substitution,
  or dynamic command construction without sanitisation?

**Credential Handling**
- Are secrets read from environment variables or files rather than command-line arguments?
- Are temporary files that may contain sensitive data created securely (`mktemp`)
  and cleaned up unconditionally?

**Privilege and Permissions**
- Does the script request more permissions than necessary?
- Are files created with appropriate permissions (not world-writable)?

**Race Conditions**
- Are there TOCTOU (time-of-check/time-of-use) issues with file operations?

For each finding, state:
- Severity: Critical / High / Medium / Low
- Location: line number or function name
- Description: what the vulnerability is
- Remediation: the specific code change needed

```zsh
[CODE]
```

[PROMPT END]

---

## 🔍 Template 4 — Performance Review

**When to use:** The script is slow or processes large amounts of data.

**Context files to include:** `sources/zsh-advanced.md`, `sources/zsh-best-practices.md`

---

[PROMPT START]

You are a performance-focused Zsh code reviewer. Review the following Zsh script for
performance issues and suggest optimisations.

Look for:

**Unnecessary Subshells and Forks**
- `$(command)` calls inside loops that could be hoisted or replaced with built-ins
- Pipes where redirection would suffice
- Use of `cat file | command` (useless-use-of-cat)

**Inefficient Loops**
- Line-by-line processing that could be handled by `awk`, `sort`, or `paste` in one pass
- Repeated glob expansions that could be stored in an array once

**Built-in vs. External Commands**
- Cases where Zsh parameter expansion could replace `sed`, `cut`, or `tr`
- Cases where `(( ))` arithmetic could replace `$(( $(expr ...) ))`

**I/O**
- Reading a file multiple times that could be read once
- Writing to a file inside a loop instead of buffering and writing once

**Startup Cost**
- Heavy `compinit` or `autoload` in a non-interactive script

For each finding, estimate the impact (High / Medium / Low) and provide the optimised code.

```zsh
[CODE]
```

[PROMPT END]

---

## ✅ Zsh Code Review Checklist

Use this checklist independently or ask the AI to evaluate each item explicitly.

### Script Structure
- [ ] Shebang is `#!/usr/bin/env zsh`
- [ ] Strict mode set: `setopt ERR_EXIT NO_UNSET PIPE_FAIL`
- [ ] Script-level constants use `readonly`
- [ ] `usage()` function present for scripts that accept arguments
- [ ] Main logic is in a `main()` function
- [ ] `main "$@"` called at the bottom

### Variables
- [ ] All function variables declared with `local`
- [ ] All variable expansions are quoted: `"$var"`, `"${array[@]}"`
- [ ] Arrays declared with `local -a`, associative arrays with `local -A`
- [ ] No use of unscoped globals where a local would suffice

### Conditionals and Tests
- [ ] `[[ ]]` used instead of `[ ]` for all tests
- [ ] `(( ))` used for arithmetic comparisons
- [ ] `-z`/`-n` used for empty/non-empty string checks
- [ ] File tests include appropriate guards (`-f`, `-d`, `-r`, `-x`)

### Error Handling
- [ ] Exit codes checked after critical commands
- [ ] Error messages written to stderr (`>&2`)
- [ ] `trap cleanup EXIT` registered when temporary files are created
- [ ] Graceful handling when commands are not found (`command -v`)

### Input Handling
- [ ] Argument count validated before accessing positional parameters
- [ ] Filenames and paths with spaces handled correctly (quoted)
- [ ] User-supplied input not passed to `eval` without sanitisation

### Best Practices from `sources/zsh-best-practices.md`
- [ ] Functions documented with purpose, arguments, and return value
- [ ] `print` / `printf` preferred over `echo` for portability
- [ ] Pipelines use `PIPE_FAIL` to detect mid-pipe failures
- [ ] `source` paths use `${0:A:h}` for reliable relative resolution
- [ ] No useless use of `cat` (`cat file | cmd` → `cmd < file`)

---

Last Updated: 2025-01-01
