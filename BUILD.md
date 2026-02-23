# BUILD.md — Contributor & Development Guide

This document covers how to set up, contribute to, and extend the `zsh-skill` repository, including recommendations and common gotchas for each phase of development.

---

## 📋 Prerequisites

| Tool | Minimum Version | Purpose |
|------|----------------|---------|
| Zsh | 5.0+ | Running and testing all scripts |
| Git | 2.x | Version control |
| ShellCheck | 0.8+ | Optional static analysis (Bash-only; Zsh support is limited) |
| bats-core | any recent | Automated test runner |
| GitHub CLI (`gh`) | 2.x | Issue/PR management |
| GNU `make` | Optional | Running helper targets (if added) |

### Verify Your Setup

```zsh
# Check Zsh version
zsh --version

# Check ShellCheck
shellcheck --version

# Check bats
bats --version

# Check GitHub CLI authentication
gh auth status
```

> **Gotcha:** ShellCheck defaults to POSIX `sh` analysis. Always pass `--shell=bash`
> explicitly. ShellCheck does **not** support Zsh and will produce false positives for many
> valid Zsh constructs. Use it as a complementary hint tool, not a hard gate. See the
> **Phase 4 Linting** section below for recommendations.

---

## 🗂️ Repository Structure

```
zsh-skill/
├── sources/          # Core documentation (primary AI knowledge base)
├── examples/         # Runnable Zsh script examples
│   ├── basic/
│   ├── advanced/
│   ├── functions/
│   └── config/
├── exercises/        # (Phase 3) Practice exercises with solutions
├── templates/        # (Phase 3) Reusable script/function templates
├── tools/            # (Phase 3) Validation, checking, and generator tools
├── AGENTS.md         # AI platform integration guide
├── BUILD.md          # This file
├── README.md         # Project overview
└── TODO.md           # Development roadmap
```

---

## 🔧 Working with Scripts

### Running an Example

```zsh
cd examples/basic
chmod +x hello_world.zsh
./hello_world.zsh
```

### Static Analysis (optional)

Neither ShellCheck nor any other widely-used tool fully supports the Zsh language.
Use these tools as a best-effort hint — do not treat their output as authoritative for Zsh:

| Tool | Zsh support | Notes |
|------|-------------|-------|
| [ShellCheck](https://github.com/koalaman/shellcheck) | ❌ None | Use `--shell=bash`; many false positives |
| [mvdan/sh (shfmt)](https://github.com/mvdan/sh) | ⚠️ Partial | Formats and parses some Zsh constructs |

```zsh
# ShellCheck — use bash dialect, suppress known Zsh false positives via .shellcheckrc
shellcheck --shell=bash examples/basic/hello_world.zsh

# shfmt — check formatting (partial Zsh support)
shfmt -ln bash examples/basic/hello_world.zsh
```

### Testing Scripts Manually

```zsh
# Run with verbose tracing to debug unexpected behaviour
zsh -x examples/basic/hello_world.zsh

# Run with strict-mode flags without editing the file
zsh -o ERR_EXIT -o NO_UNSET -o PIPE_FAIL examples/basic/hello_world.zsh
```

---

## 📁 Phase 3: Interactive Components

### exercises/ Directory

Each exercise file should follow this layout:

```
exercises/
├── beginner/
│   ├── 01-variables.zsh          # Exercise prompt as comments
│   └── solutions/
│       └── 01-variables.zsh      # Reference solution
├── intermediate/
│   ├── 01-arrays.zsh
│   └── solutions/
│       └── 01-arrays.zsh
└── advanced/
    ├── 01-completion.zsh
    └── solutions/
        └── 01-completion.zsh
```

**Recommendations:**
- Put the exercise prompt and constraints entirely in comments at the top of the file.
- Leave a clearly marked `# --- YOUR CODE HERE ---` block for learners.
- Solutions must be self-contained runnable scripts, not diffs.
- Include expected output in a comment block at the bottom of each solution.

**Gotchas:**
- Do not `setopt ERR_EXIT` in exercise files — learners will hit unintended exits while
  working through them.
- Avoid relying on system-specific paths (e.g., `/usr/local/bin`) in exercises; use
  `command -v` checks instead.

---

### templates/ Directory

```
templates/
├── script-basic.zsh         # Minimal script with shebang and usage()
├── script-full.zsh          # Full template with error handling and logging
├── function-library.zsh     # Template for sourced function collections
├── config-file.zsh          # .zshrc / .zshenv snippet template
└── test-template.zsh        # Template for script tests (shunit2 / bats style)
```

**Recommendations:**
- Every template must include a `usage()` function and an `--help` flag handler.
- Use `readonly SCRIPT_DIR="${0:A:h}"` for portable script-relative paths.
- Mark all placeholder text with `<PLACEHOLDER>` so users can `grep` for incomplete spots.

**Gotchas:**
- `${0:A}` (absolute path expansion) requires `zsh 5.0+` and does **not** work in plain
  `sh`. Add a version guard if Zsh version matters:
  ```zsh
  [[ ${ZSH_VERSION%%.*} -ge 5 ]] || { echo "Requires Zsh 5+"; exit 1; }
  ```
- Sourced function libraries should **never** call `exit` — use `return` instead, otherwise
  they will terminate the parent shell session.

---

### tools/ Directory

```
tools/
├── validate.zsh          # Runs ShellCheck + custom Zsh rules on a target file/dir
├── check-practices.zsh   # Compares a script against zsh-best-practices.md rules
├── perf-analyzer.zsh     # Times common patterns and reports slow operations
└── doc-generator.zsh     # Extracts ## comments from .zsh files into Markdown
```

**Recommendations:**
- Each tool must accept a `--help` flag and exit `0` on success, non-zero on failure.
- `validate.zsh` should return a machine-readable summary (e.g., JSON) in addition to
  human-readable output so it can be used in CI pipelines.
- `doc-generator.zsh` should follow the [Zsh docstring convention](sources/zsh-best-practices.md):
  `##` lines above a function are treated as its documentation.

**Gotchas:**
- `zsh/zprof` (used by `perf-analyzer.zsh`) must be loaded **before** the code under test:
  ```zsh
  zmodload zsh/zprof
  source ./script_to_profile.zsh
  zprof
  ```
- Spawning subshells (`$(...)`) inside loops is the most common performance regression.
  The performance analyzer should flag this pattern.
- The documentation generator must handle here-docs and multi-line strings correctly;
  naive line-by-line parsing will misidentify `##` inside strings as docstrings.

---

## ✅ Quality Checklist for New Content

Before opening a PR, confirm:

- [ ] `bats tests/` passes with no failures
- [ ] Scripts execute without errors under `zsh -o ERR_EXIT -o NO_UNSET`
- [ ] No hardcoded absolute paths (use `$SCRIPT_DIR` or `$HOME` variables)
- [ ] Variables are quoted: `"$var"`, not `$var`
- [ ] Functions use `local` for all internal variables
- [ ] Sourced files use `return`, not `exit`
- [ ] New directories include a `README.md` explaining the contents
- [ ] Exercise solutions include expected output in comments
- [ ] (Optional) Review `shellcheck --shell=bash` output for any real Bash-portable issues

---

## ⚠️ Common Gotchas

### Zsh vs Bash Compatibility

| Feature | Zsh | Bash | Note |
|---------|-----|------|------|
| Arrays (1-indexed) | `$array[1]` | `${array[0]}` | Arrays start at **1** in Zsh |
| Associative arrays | `typeset -A` | `declare -A` | Both work but `typeset` is Zsh idiomatic |
| String flags | `${(U)var}` | N/A | Zsh-only; no Bash equivalent |
| Glob qualifiers | `*(.)` | N/A | Zsh-only extended globbing |
| `[[ ]]` tests | Full support | Full support | Prefer over `[ ]` for safety |

### `.zshrc` vs `.zshenv` vs `.zprofile`

- `.zshenv` — loaded for **every** Zsh invocation (interactive, non-interactive, scripts).
  Keep it minimal (just `PATH`, `ZDOTDIR`).
- `.zprofile` — login shell only; use for `PATH` additions that aren't needed in scripts.
- `.zshrc` — interactive shells only; **not** sourced when running scripts.

> **Gotcha:** Aliases and functions defined in `.zshrc` are **not** available in scripts
> unless explicitly sourced. Move shared utilities to a library file.

### `setopt ERR_EXIT` Pitfalls

```zsh
setopt ERR_EXIT

# This WILL exit if grep finds no matches (exit code 1)
grep "pattern" file.txt

# Safe alternatives:
grep "pattern" file.txt || true
grep "pattern" file.txt || { echo "not found"; return 0 }
if grep -q "pattern" file.txt; then ...; fi
```

### Word Splitting

Zsh does **not** perform word splitting on unquoted variables by default (unlike Bash).
This is generally safer but can surprise users coming from Bash:

```zsh
args="-l -a"
ls $args      # Passes as a single argument in Zsh (broken)
ls ${=args}   # Use ${=var} to force word splitting
ls $=args     # Shorthand equivalent
```

### Glob Expansion Failure

```zsh
# Fails if no .log files exist (unlike Bash, which would pass the literal string)
rm *.log

# Safe patterns:
setopt NULL_GLOB
rm *.log        # silently does nothing if no matches

# Or check explicitly:
local -a logs=(*.log(N))
(( ${#logs} )) && rm "${logs[@]}"
```

---

## 🧪 Phase 4: Testing & Quality

### Testing Framework

The repository uses **bats-core** (Bash Automated Testing System) for automated testing.
Bats was selected after evaluating the three main Zsh/shell testing frameworks:

| Framework | Decision | Reason |
|-----------|----------|--------|
| **bats-core** | ✅ Selected | Actively maintained, TAP output, works on CI runners |
| shunit2 | Considered | Simpler but no TAP output; less CI-friendly |
| zunit | Considered | Zsh-native but smaller community and tooling |

Install bats:

```bash
# Ubuntu/Debian
sudo apt-get install bats

# macOS
brew install bats-core
```

### Test Suite Layout

```
tests/
├── README.md                        # Framework docs and conventions
├── unit/                            # One .bats file per example script
│   ├── test_hello_world.bats
│   ├── test_arrays_and_maps.bats
│   └── test_error_handling.bats
├── integration/                     # End-to-end: all examples run without error
│   └── test_examples_run.bats
└── docs/                            # Repository structure validation
    └── test_docs_structure.bats
```

### Running the Tests

```bash
# All suites
bats tests/

# Single suite
bats tests/unit/
bats tests/integration/
bats tests/docs/

# TAP output (for CI/CD integration)
bats --tap tests/
```

**Recommendations:**
- Run the full test suite locally before pushing any changes.
- When adding a new example script, add a corresponding test file in `tests/unit/`.
- When adding a new source document, add a file-existence check in
  `tests/docs/test_docs_structure.bats`.

**Gotchas:**
- Bats runs in Bash, not Zsh. Tests invoke `zsh` as a subprocess to execute `.zsh` scripts.
  Ensure Zsh is installed in your environment (`sudo apt-get install zsh` on Ubuntu).
- Avoid using Zsh-specific syntax inside `.bats` test files — use portable Bash syntax.
- The `$BATS_TEST_DIRNAME` variable points to the directory of the test file; use it to
  construct absolute paths to the scripts under test.

### Static Analysis (optional — not a CI gate)

No tool fully supports the Zsh language. Use static analysis as a best-effort hint only:

| Tool | Zsh support | How to use |
|------|-------------|-----------|
| [ShellCheck](https://github.com/koalaman/shellcheck) | ❌ None (Bash only) | `shellcheck --shell=bash <file>` |
| [mvdan/sh (shfmt)](https://github.com/mvdan/sh) | ⚠️ Partial | `shfmt -ln bash <file>` |

**ShellCheck** with `--shell=bash` will report false positives for many valid Zsh constructs.
Common Zsh-specific codes are suppressed in `.shellcheckrc`. Running ShellCheck is optional
and will not block CI — the lint job is configured with `continue-on-error: true`.

```bash
# Run ShellCheck locally (informational)
find . -name "*.zsh" -not -path "./.git/*" | xargs shellcheck --shell=bash
```

**Gotcha:** Do not add `# shellcheck disable=...` comments purely to silence Zsh-specific
false positives in example scripts — it reduces readability. Prefer adding the code to
`.shellcheckrc` instead, with a clear comment explaining the Zsh construct.

### CI/CD Pipeline

The repository includes a GitHub Actions workflow at `.github/workflows/ci.yml` with three jobs:

| Job | Blocks merge? | Steps |
|-----|--------------|-------|
| **ShellCheck Lint** | No (`continue-on-error: true`) | Runs ShellCheck informally on all `.zsh` files |
| **Bats Tests** | Yes | Runs unit, integration, and documentation test suites |
| **Documentation Validation** | Yes | Verifies required markdown files exist; checks shebangs |

The **Bats Tests** and **Documentation Validation** jobs run independently — a ShellCheck
warning will not prevent tests from running.

**Gotcha:** The CI runner does not have Zsh pre-installed. The workflow installs `zsh` and
`bats` via `apt-get` before running tests. If you add tests that require additional system
packages, add the install step to `ci.yml`.

---

## 🔗 Related Documents

- [README.md](README.md) — Project overview and quick start
- [AGENTS.md](AGENTS.md) — AI platform integration guide
- [CONTRIBUTING.md](CONTRIBUTING.md) — Contribution guide and code review standards
- [TODO.md](TODO.md) — Full development roadmap
- [tests/README.md](tests/README.md) — Test suite documentation
- [sources/zsh-best-practices.md](sources/zsh-best-practices.md) — Coding standards
- [sources/zsh-troubleshooting.md](sources/zsh-troubleshooting.md) — Debugging techniques

---

**Last Updated:** 2026-02-20
