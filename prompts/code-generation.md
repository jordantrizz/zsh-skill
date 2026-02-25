# Code Generation Prompts

Prompt templates for generating Zsh functions and scripts with AI assistants.

---

## 📌 Usage Notes

Attach the indicated context files alongside each prompt for best results.
Replace every `[PLACEHOLDER]` before sending.

---

## 🔧 Template 1 — Basic Function

**When to use:** You need a single, reusable Zsh function.

**Context files to include:** `sources/zsh-best-practices.md`, `sources/zsh-basics.md`

---

[PROMPT START]

You are an expert Zsh developer. Write a Zsh function that does the following:

**Description:** [DESCRIPTION — e.g., "Checks whether a given port is open on a host"]

**Requirements:**
[REQUIREMENTS — bullet list, e.g.:]
- Accepts two arguments: hostname and port number
- Validates both arguments are provided and non-empty
- Returns 0 if the port is open, 1 otherwise
- Prints a clear success or failure message

**Constraints:**
- Use `local` for all variables inside the function
- Quote all variable expansions
- Write error messages to stderr (`>&2`)
- Follow Zsh best practices: `[[ ]]` for tests, no `$(...)` in loops where avoidable
- Include a brief usage comment at the top of the function
- Do not use external tools beyond standard Unix utilities

Provide only the function definition with a short usage example at the end (in a comment).

[PROMPT END]

---

## 🔧 Template 2 — Script with Argument Parsing

**When to use:** You need a standalone script with `--flag` style options.

**Context files to include:** `sources/zsh-best-practices.md`, `sources/zsh-scripting-patterns.md`

---

[PROMPT START]

You are an expert Zsh developer. Write a complete, production-quality Zsh script.

**Script purpose:** [DESCRIPTION — e.g., "Rotate log files in a given directory"]

**Arguments and flags:**
[REQUIREMENTS — e.g.:]
- Positional argument: path to the log directory (required)
- `-n / --dry-run`: print what would be done without making changes
- `-k / --keep N`: number of rotated copies to retain (default: 5)
- `-v / --verbose`: enable verbose output
- `-h / --help`: print usage and exit

**Behaviour:**
[ADDITIONAL REQUIREMENTS — e.g.:]
- Validate that the directory exists and is readable
- Rotate files matching `*.log` by appending a date suffix
- Delete the oldest copies when the count exceeds --keep
- Print a summary of actions taken

**Code standards:**
- Shebang: `#!/usr/bin/env zsh`
- Strict mode: `setopt ERR_EXIT NO_UNSET PIPE_FAIL`
- Use `readonly` for script-level constants
- Use `local` for all function-scoped variables
- Include a `cleanup` function registered with `trap ... EXIT`
- Include a `usage()` function that prints to stdout
- Wrap the main logic in a `main()` function called at the bottom of the script
- Quote all variable expansions
- Write all errors to stderr

[PROMPT END]

---

## 🔧 Template 3 — File Processing Script

**When to use:** You need a script that reads and transforms files.

**Context files to include:** `sources/zsh-best-practices.md`, `sources/zsh-advanced.md`

---

[PROMPT START]

You are an expert Zsh developer. Write a Zsh script that processes files.

**What the script processes:** [DESCRIPTION — e.g., "CSV files exported from a billing system"]

**Input:**
[INPUT DESCRIPTION — e.g.:]
- One or more CSV files passed as arguments
- Each file has a header row; subsequent rows are data
- Fields are comma-separated; values may be quoted

**Processing steps:**
[STEPS — e.g.:]
1. Validate each input file exists and is readable
2. Skip blank lines and lines beginning with `#`
3. For each data row, extract columns 1 (name) and 3 (amount)
4. Sum the amounts and print a per-name subtotal
5. Write the output to `[OUTPUT_PATH]`

**Output format:** [FORMAT — e.g., "Tab-separated: name<TAB>total, one per line, sorted by name"]

**Error handling:**
- Skip unreadable files with a warning; do not abort
- If no valid rows are found, print a warning to stderr and exit 0

**Code standards:**
- Use Zsh glob qualifiers to find files if a directory is given instead of file names
- Use a `while read` loop for line-by-line processing
- Prefer Zsh parameter expansion over `sed`/`awk` for simple transformations
- Do not use `cat file | command` — use redirection instead

[PROMPT END]

---

## 🔧 Template 4 — Automation / Workflow Script

**When to use:** You need a script that orchestrates multiple commands or services.

**Context files to include:** `sources/zsh-best-practices.md`, `sources/zsh-scripting-patterns.md`, `sources/zsh-troubleshooting.md`

---

[PROMPT START]

You are an expert Zsh developer. Write a Zsh automation script.

**Workflow description:** [DESCRIPTION — e.g., "Deploy a containerised application to a staging environment"]

**Steps to automate:**
[STEPS — numbered list, e.g.:]
1. Pull the latest Docker image for tag `[IMAGE_TAG]`
2. Stop the currently running container (ignore errors if not running)
3. Run the new container with environment variables from `.env.staging`
4. Wait up to 30 seconds for the health-check endpoint to return HTTP 200
5. Send a Slack notification with the result
6. On failure: roll back to the previous image and notify

**Environment / dependencies:** [DEPS — e.g., "docker, curl, jq must be installed"]

**Configuration:** [CONFIG — e.g.:]
- Read `SLACK_WEBHOOK_URL` from the environment (error if unset)
- Accept `--env [staging|production]` flag; default is `staging`

**Robustness requirements:**
- Check all required tools are installed before starting
- Use `trap` to perform rollback on unexpected exit
- Log each major step with a timestamp to both stdout and a log file
- Use a `run()` helper that respects a `--dry-run` flag

[PROMPT END]

---

## 📝 Customisation Tips

- Add "Use only features available in Zsh 5.0+" to restrict to older installs.
- Add "Avoid external commands; use only Zsh built-ins" for embedded/minimal environments.
- Add "Include `shellcheck` annotations for any constructs that may trigger false positives"
  when linting is part of your CI pipeline.
- Append "Provide a ShellSpec `_spec.sh` file with at least three test cases" to get specs alongside code.

---

Last Updated: 2025-01-01
