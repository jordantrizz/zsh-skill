# BUILD.md — Contributor & Development Guide

This document covers how to set up, contribute to, and extend the `zsh-skill` repository, including recommendations and common gotchas for each phase of development.

---

## 📋 Prerequisites

| Tool | Minimum Version | Purpose |
|------|----------------|---------|
| Zsh | 5.0+ | Running and testing all scripts |
| Git | 2.x | Version control |
| ShellCheck | 0.8+ | Optional static analysis (Bash-only; Zsh support is limited) |
| ShellSpec | 0.28+ | Automated test runner (native Zsh support) |
| GitHub CLI (`gh`) | 2.x | Issue/PR management |
| GNU `make` | Optional | Running helper targets (if added) |

### Verify Your Setup

```zsh
# Check Zsh version
zsh --version

# Check ShellCheck
shellcheck --version

# Check ShellSpec
shellspec --version

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
└── test-template.zsh        # Template for script tests (shellspec style)
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

- [ ] `shellspec tests/` passes with no failures
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

The repository uses **[ShellSpec](https://github.com/shellspec/shellspec)** for automated testing.
ShellSpec was chosen because it natively supports Zsh as the test runner, allowing spec files to
use Zsh syntax directly — unlike bats-core, which runs in Bash only.

| Framework | Decision | Reason |
|-----------|----------|--------|
| **ShellSpec** | ✅ Selected | Native Zsh support (`--shell zsh`), BDD-style DSL, actively maintained |
| bats-core | Replaced | Runs in Bash only; Zsh must be invoked as a subprocess |
| shunit2 | Considered | No TAP output; less CI-friendly |
| zunit | Considered | Zsh-native but smaller community and tooling |

Install ShellSpec:

```bash
# Download and install (Linux/macOS)
curl -fsSL https://github.com/shellspec/shellspec/releases/download/0.28.1/shellspec-dist.tar.gz \
  | tar -zxf - -C /tmp
sudo ln -s /tmp/shellspec/shellspec /usr/local/bin/shellspec

# macOS via Homebrew
brew install shellspec

# Verify installation
shellspec --version
```

### Test Suite Layout

```
tests/
├── README.md                            # Framework docs and conventions
├── unit/                                # Unit specs — one _spec.sh per example script
│   ├── hello_world_spec.sh
│   ├── arrays_and_maps_spec.sh
│   └── error_handling_spec.sh
├── integration/                         # End-to-end: all examples run without error
│   └── examples_run_spec.sh
└── docs/                                # Repository structure validation
    └── docs_structure_spec.sh
```

### Running the Tests

```bash
# All suites
shellspec tests/

# Single subdirectory
shellspec --shell zsh tests/unit/

# Single spec file
shellspec --shell zsh tests/unit/hello_world_spec.sh
```

**Recommendations:**
- Run the full test suite locally before pushing any changes.
- When adding a new example script, add a corresponding spec file in `tests/unit/`.
- When adding a new source document, add a file-existence check in
  `tests/docs/docs_structure_spec.sh`.

**Gotchas:**
- ShellSpec runs spec files with the shell specified via `--shell` (or the `.shellspec` config).
  Use `--shell zsh` to get native Zsh support in spec files.
- Spec files use ShellSpec's DSL (`Describe`, `It`, `When run`, `The status should be success`).
  Do not use Bash-specific syntax in spec files when running with `--shell zsh`.
- `$SHELLSPEC_SPECDIR` points to the spec root directory (the argument to `shellspec`, e.g.,
  `tests/`). Use it to build absolute paths to scripts under test:
  ```sh
  my_script() { zsh "${SHELLSPEC_SPECDIR}/../examples/basic/my_script.zsh" "$@"; }
  ```

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
| **ShellSpec Tests** | Yes | Runs all unit, integration, and documentation specs |
| **Documentation Validation** | Yes | Verifies required markdown files exist; checks shebangs |

The **ShellSpec Tests** and **Documentation Validation** jobs run independently — a ShellCheck
warning will not prevent tests from running.

**Gotcha:** The CI runner installs `zsh` and `shellspec` before running tests. If you add specs
that require additional system packages, add the install step to `ci.yml`.

---

## 🤖 Phase 5: AI Integration

### GitHub Copilot Configuration

Configuration lives in `.github/copilot/`:

```
.github/copilot/
├── copilot-instructions.md   # Custom Copilot coding instructions for this repo
└── snippets/
    └── zsh-snippets.md       # Reusable Zsh code snippets for Copilot suggestions
```

`copilot-instructions.md` is automatically read by GitHub Copilot in any workspace that
includes this repository. It sets the language dialect (Zsh), code style, and error-handling
conventions so Copilot suggestions are idiomatic from the first completion.

**Recommendations:**
- Keep `copilot-instructions.md` concise (under 200 lines); Copilot truncates very long
  instruction files.
- Use fenced code blocks with the `zsh` language tag — Copilot uses them as exemplars.
- Update `snippets/zsh-snippets.md` whenever a new canonical pattern is established.

**Gotchas:**
- Copilot does not reload instructions mid-session; restart your IDE after editing
  `copilot-instructions.md`.
- Instructions apply repo-wide. If you have mixed-language scripts, add language guards
  ("when working with `.zsh` files") to avoid influencing Bash or Python suggestions.

---

### Cursor IDE Configuration

`.cursorrules` in the repository root is automatically loaded by Cursor IDE when you open
this folder. It configures the AI assistant with:

- Project context (Zsh knowledge base)
- Language rules (Zsh, not Bash)
- Code style conventions
- Links to the `sources/` knowledge base

**Recommendations:**
- Keep `.cursorrules` focused on conventions that differ from general coding standards.
- List the key source files so Cursor's AI can reference them with `@filename`.
- Update `.cursorrules` whenever the repository structure changes significantly.

**Gotchas:**
- `.cursorrules` is a flat text/markdown file; do not rely on JSON or YAML syntax.
- Cursor reads `.cursorrules` at project open time; changes require reopening the folder.

---

### Claude Integration

`sources/claude-guide.md` documents how to use this repository with Claude
(claude.ai, Claude Code, or the Anthropic API). It covers:

- Recommended context-loading strategies
- Structured prompt templates (using `<context>`, `<task>`, `<code>` delimiters)
- Worked examples for code generation, review, learning, and debugging
- Capabilities and limitations table

**Recommendations:**
- When sharing source files with Claude, use XML-like delimiters to separate context from
  the task:
  ```
  <context>
  [paste sources/zsh-best-practices.md]
  </context>

  <task>
  Review this script: [paste script]
  </task>
  ```
- For long review sessions, share only the relevant source sections rather than entire files
  to keep context window usage efficient.

**Gotchas:**
- Claude does not execute code. All script analysis is static. Always run reviewed scripts
  in a test environment before deploying.
- Context windows have token limits. If sharing multiple large source files, prefer the
  sections most relevant to the task.

---

### Prompt Templates

Reusable prompt templates live in `prompts/`:

```
prompts/
├── README.md              # Usage guide for the prompt templates
├── code-generation.md     # Prompts for generating new Zsh scripts/functions
├── code-review.md         # Prompts for reviewing Zsh code quality
├── learning.md            # Prompts for learning Zsh concepts
└── debugging.md           # Prompts for diagnosing Zsh script issues
```

Each template uses `[PLACEHOLDER]` syntax for parts you fill in. See `prompts/README.md`
for instructions on attaching context files for each AI platform.

**Recommendations:**
- When creating a new prompt template, add it as a new `##` section in the relevant file
  rather than a new file, unless the topic warrants its own document.
- Include a "Context files" note in each template specifying which `sources/` documents
  to provide as context.

**Gotchas:**
- Prompt templates are starting points. LLM responses vary between sessions; always review
  generated code before using it.
- Templates reference files in `sources/`. If a source file is renamed, update all prompt
  templates that reference it.

---

### Knowledge Base Optimization

Source documents in `sources/` follow these conventions for optimal AI parsing:

1. **Semantic tags** — `<!-- semantic-tags: topic1, topic2 -->` comments after headings help
   AI models identify relevant sections during retrieval.
2. **Knowledge graph links** — `<!-- related: file.md#section -->` comments at the bottom of
   each file create explicit cross-document relationships.
3. **FAQ sections** — `sources/zsh-faq.md` provides question-and-answer pairs that match
   natural language queries from AI chat interfaces.
4. **Structured headings** — `#` / `##` / `###` hierarchy makes sections easy to reference
   and quote (`@docs sources/zsh-advanced.md#glob-qualifiers`).

**Gotchas:**
- HTML comments (`<!-- ... -->`) are invisible in rendered markdown but are included in the
  raw text that AI models receive. Do not put sensitive information in them.
- Very long documents may be chunked or truncated by AI retrieval systems. Keep each
  `sources/` file focused on a single topic domain.

---

## 🚀 Phase 6: Advanced Features

Three new source documents cover the Phase 6 topics.

### `sources/zsh-version-compatibility.md`

Covers the version compatibility matrix, Zsh 5.x feature highlights, Zsh 5.9+
additions (`private` keyword, `WARN_NESTED_VAR`, `TYPESET_SILENT`), and
migration guides for Bash → Zsh and across Zsh minor versions.

**Recommendations:**
- Use `autoload -Uz is-at-least` (provided by `zsh/compinit`) for portable
  version guards; avoid manual string parsing of `$ZSH_VERSION`.
- Guard 5.9+ features with `is-at-least 5.9` and provide a `local`-based
  fallback for older environments.
- Document the minimum version requirement in every script's header comment.

**Gotchas:**
- `is-at-least` is part of the completion system (`autoload -Uz is-at-least`).
  It is **not** available until `autoload` is called; do not rely on it before
  completion initialisation.
- `${ZSH_VERSION%%.*}` gives only the major version (e.g., `5`). To extract
  the minor version you need `${${ZSH_VERSION#*.}%%.*}`.
- `zmodload zsh/param/private` silently fails on pre-5.9 systems; always
  guard the `zmodload` call with `is-at-least 5.9`.

---

### `sources/zsh-performance.md`

Covers performance benchmarking (`zsh/zprof`, `$EPOCHREALTIME`), ten
optimisation techniques, side-by-side comparison examples, and patterns for
profiling startup time and identifying subshell anti-patterns.

**Recommendations:**
- Use `zsh/zprof` for function-level profiling; use `$EPOCHREALTIME` for
  wall-clock benchmarks of specific blocks.
- Replace the most common performance regressions first:
  1. `$(cat file)` → `$(<file)`
  2. `$(echo … | tr …)` → `${(U)var}` / `${(L)var}`
  3. `$(basename …)` → `${path:t}`
  4. Subshell `$(wc -l …)` inside loops → array size `${#lines}`
- Profile `.zshrc` startup with `zprof` after every significant plugin change.

**Gotchas:**
- `zmodload zsh/zprof` **must** be the very first statement in `~/.zshrc` (or
  the script under test). Loading it after other code gives incomplete results.
- `$EPOCHREALTIME` requires `zmodload zsh/datetime`. It is a floating-point
  scalar; use `local -F` to declare receiving variables to avoid truncation.
- Micro-benchmarks inside a tight loop may be skewed by CPU frequency scaling
  and OS scheduling. Run benchmarks under realistic load conditions and average
  many iterations.
- `$(command)` inside a `for` loop is the single most common Zsh performance
  regression. Flag it during code review.

---

### `sources/zsh-security.md`

Covers the full security lifecycle: input validation, quoting, `eval` avoidance,
secure temporary files, `PATH` hardening, `IFS` protection, `umask` usage,
secret handling, seven common vulnerability classes with fix examples, two
secure coding templates, and a pre-deployment security checklist.

**Recommendations:**
- Treat all data that crosses a trust boundary (user input, environment
  variables, file contents, network responses) as untrusted.
- Use `:A` (absolute path with symlink resolution) whenever validating that a
  user-supplied path stays within an allowed directory.
- Prefer `${(P)varname}` over `eval "echo \$$varname"` for indirect variable
  expansion; it does not execute arbitrary code.
- Add the security checklist to your PR template so reviewers explicitly sign
  off on each item for scripts that handle credentials or elevated privileges.

**Gotchas:**
- `setopt ERR_EXIT` alone is not a security measure — it only aborts on
  unexpected errors. Validation of untrusted data must be explicit.
- The `[[ =~ ]]` regex operator in Zsh does **not** anchor the pattern by
  default. Always include `^` and `$` anchors when validating full-string
  inputs (e.g., `[[ "$input" =~ '^[0-9]+$' ]]`).
- `eval` with `${(P)var}` is **not** the same as using `${(P)var}` directly.
  `${(P)var}` expands to the *value* of the variable named by `$var`; it never
  executes code, making it safe for indirect lookups.
- Calling `unset secret` removes the variable from the current scope but does
  not guarantee the value is zeroed in memory. For high-security environments,
  consider using a dedicated secrets manager rather than shell variables.
- `mktemp` behaviour differs slightly between Linux (`-p DIR`) and macOS
  (`-d`). Use `mktemp` without platform-specific flags for portability, and
  always capture the output: `tmp=$(mktemp) || exit 1`.

---

## 🌐 Phase 7: Community & Ecosystem

### Community Files

Phase 7 adds the following community and ecosystem files:

```
zsh-skill/
├── CHANGELOG.md                          # Project history (Keep a Changelog format)
├── CODE_OF_CONDUCT.md                    # Contributor Covenant v2.1
├── sources/zsh-integrations.md           # Git, Docker, CI/CD, and dev environment guide
└── .github/
    ├── PULL_REQUEST_TEMPLATE.md          # PR checklist presented to contributors
    └── ISSUE_TEMPLATE/
        ├── bug_report.yml                # Structured bug report form
        └── feature_request.yml           # Structured feature request form
```

### CHANGELOG.md

Follows the [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) format.

**Recommendations:**
- Record every user-visible change in `[Unreleased]` as you work. Move the section
  to a versioned heading (`## [1.0.0] — YYYY-MM-DD`) when tagging a release.
- Use the standard change categories: `Added`, `Changed`, `Deprecated`, `Removed`,
  `Fixed`, `Security`.
- Link each versioned heading to a GitHub compare URL for easy diffing.

**Gotchas:**
- Do not record internal refactors or whitespace-only commits unless they affect
  behaviour. Changelogs are for users and contributors, not for git history.

---

### CODE_OF_CONDUCT.md

Adopts the [Contributor Covenant v2.1](https://www.contributor-covenant.org/version/2/1/code_of_conduct.html).

**Recommendations:**
- Report enforcement contacts should be updated to a real email address or issue
  tracker link before the project reaches a wider audience.

---

### Issue Templates

Structured YAML-based GitHub issue forms in `.github/ISSUE_TEMPLATE/`:

| File | Purpose |
|------|---------|
| `bug_report.yml` | Collects Zsh version, OS, affected file, repro steps, and expected behaviour |
| `feature_request.yml` | Collects use case, proposed solution, and alternatives |

**Recommendations:**
- Add a `config.yml` to `.github/ISSUE_TEMPLATE/` if you want to add a link to
  discussions or a contact link, or to disable blank issues:
  ```yaml
  # .github/ISSUE_TEMPLATE/config.yml
  blank_issues_enabled: false
  contact_links:
    - name: "💬 Ask a question"
      url: https://github.com/jordantrizz/zsh-skill/discussions
      about: "Use Discussions for questions and general help"
  ```

**Gotchas:**
- GitHub renders YAML issue forms only on github.com. If you add `config.yml`
  with `blank_issues_enabled: false`, contributors will not be able to open
  freeform issues — ensure the templates cover all common issue types first.

---

### Pull Request Template

`.github/PULL_REQUEST_TEMPLATE.md` is automatically pre-filled into the PR
description when a contributor opens a new pull request.

**Recommendations:**
- Keep the checklist short (under 15 items). Long templates are often left
  unchecked by contributors.
- Mirror the checklist in `CONTRIBUTING.md` so both documents stay in sync.

---

### sources/zsh-integrations.md

Covers integration of Zsh scripts into common development workflows:

1. **Git** — pre-commit hook, commit-msg hook, git aliases
2. **Docker** — development container, single-script runner, multi-version Compose setup
3. **CI/CD** — GitHub Actions, GitLab CI, Jenkins
4. **Development environments** — VS Code/Cursor tasks, Dev Containers, Makefile

**Recommendations:**
- When adding new integrations, follow the pattern: show the config/script, then
  provide a "Build and run" or "Install" command, then add a "Gotchas" callout.
- Link back to `sources/zsh-security.md` for any integration that involves
  credentials or elevated permissions.

**Gotchas:**
- Git hooks live in `.git/hooks/` which is **not** tracked by version control.
  Document how to install hooks in `CONTRIBUTING.md` and consider adding a
  setup script (`scripts/install-hooks.zsh`) that contributors can run once.
- Docker `RUN` instructions use `/bin/sh` by default. When running Zsh scripts
  inside a `RUN` instruction, invoke them explicitly:
  ```dockerfile
  RUN zsh my-script.zsh
  ```
  or change the shell for the entire stage:
  ```dockerfile
  SHELL ["/usr/bin/zsh", "-c"]
  ```
- ShellSpec's `--format junit` output goes to stdout. Redirect it to a file
  (`> report.xml`) after the normal run; running with JUnit format suppresses
  human-readable output, making local debugging harder.

---

## 🔄 Phase 8: Maintenance & Updates

Phase 8 establishes the ongoing processes that keep the repository accurate, relevant, and
community-driven after the initial build phases are complete.

---

### Regular Updates

**Recommendations:**
- Schedule a **quarterly documentation review** — pick one calendar quarter-start (e.g. the
  first Monday of January, April, July, October) to skim every file in `sources/` for
  outdated version references, broken links, or stale examples.
- When a new Zsh minor version ships, add its notable changes to
  `sources/zsh-version-compatibility.md` and update the version matrix table.  Open a
  dedicated issue titled `Quarterly review — QN YYYY` to track the work.
- When updating best-practice recommendations (e.g. preferred quoting style, a new builtin
  that replaces a common external command), **also** update the corresponding prompt
  templates in `prompts/` and the example scripts in `examples/` so all surfaces stay
  consistent.
- After updating any `sources/` file referenced by an AI platform config (`.cursorrules`,
  `.github/copilot/copilot-instructions.md`, `sources/claude-guide.md`), review the config
  to ensure examples and file paths are still accurate.

**Gotchas:**
- Zsh version numbers follow a `MAJOR.MINOR.PATCH` pattern (`5.9.0`).  The CI matrix in
  `.github/workflows/ci.yml` pins a specific version; bump it alongside documentation
  updates so the tests actually exercise the documented version.
- `is-at-least` (from `zsh/compinit`) is the canonical guard for version-specific features.
  Do **not** use string comparisons like `[[ $ZSH_VERSION > "5.9" ]]` — lexicographic
  ordering gives wrong results for double-digit minor versions (e.g. `5.10`).
- HTML comment semantic tags (`<!-- semantic-tags: ... -->`) in source files are invisible
  in rendered markdown.  Review them during quarterly passes — they accumulate stale tags
  after section renames.

---

### Community Feedback

**Recommendations:**
- Add a `## Feedback` section to `README.md` pointing contributors to GitHub Discussions
  for general questions and GitHub Issues (using the structured templates in
  `.github/ISSUE_TEMPLATE/`) for bug reports and feature requests.
- During quarterly reviews, triage open issues: close stale ones (no response in 90 days),
  label recurring themes (e.g. `documentation`, `examples`, `ai-integration`), and promote
  popular requests to the `TODO.md` roadmap.
- When a community contribution is merged, add the contributor to the `## Contributors`
  section of `README.md` (or use the all-contributors bot if the project grows).
- Collect success stories (e.g. "this knowledge base helped me write X") in a
  `TESTIMONIALS.md` or a pinned GitHub Discussion — they provide motivation for maintainers
  and social proof for new users.

**Gotchas:**
- GitHub Discussions must be **enabled** in the repository settings before any links to
  `github.com/jordantrizz/zsh-skill/discussions` will work.  Verify this before advertising
  the Discussions URL.
- The YAML issue templates in `.github/ISSUE_TEMPLATE/` render only on github.com — they
  display as plain YAML in other interfaces (e.g. the GitHub mobile app's plain issue
  form).  Keep template descriptions brief enough to be useful even when unrendered.
- If `blank_issues_enabled: false` is set in `.github/ISSUE_TEMPLATE/config.yml`,
  contributors **cannot** open freeform issues at all — ensure the structured templates
  cover every common scenario before enabling this restriction.

---

### Analytics & Improvement

**Recommendations:**
- Use **GitHub Insights** (Traffic → Popular content) to identify which `sources/` pages
  are viewed most — these are the highest-leverage targets for quality improvements.
- Track common questions by reviewing Discussions and issues monthly, tagging recurring
  topics.  Recurring questions that are not answered by any existing document indicate a
  documentation gap — open a `documentation gap` issue for each one.
- Monitor AI assistant effectiveness indirectly: if users report that Copilot / Claude /
  Cursor gives wrong Zsh advice in issues or discussions, note the pattern and add a
  counter-example or clarification to the relevant `sources/` file.
- Add a `## Known Limitations` section to `AGENTS.md` listing constructs or scenarios
  where current AI platforms are known to give suboptimal Zsh suggestions, so users know
  what to verify manually.

**Gotchas:**
- GitHub's built-in traffic data has a **14-day rolling window** — export it regularly
  (or use a third-party analytics integration) if you want long-term trends.
- "AI assistant effectiveness" is inherently hard to measure quantitatively in an open
  repository.  Proxy metrics (issue close time, PR quality, repeat contributors) are more
  actionable than trying to instrument AI completions directly.
- Do not add client-side tracking (e.g. Google Analytics snippets) to markdown files — AI
  models will include the tracking code in their training and may reproduce it in generated
  scripts.

---

## 🔗 Related Documents

- [README.md](README.md) — Project overview and quick start
- [AGENTS.md](AGENTS.md) — AI platform integration guide
- [CONTRIBUTING.md](CONTRIBUTING.md) — Contribution guide and code review standards
- [TODO.md](TODO.md) — Full development roadmap
- [tests/README.md](tests/README.md) — Test suite documentation
- [sources/zsh-best-practices.md](sources/zsh-best-practices.md) — Coding standards
- [sources/zsh-troubleshooting.md](sources/zsh-troubleshooting.md) — Debugging techniques
- [sources/claude-guide.md](sources/claude-guide.md) — Claude AI integration guide
- [sources/zsh-integrations.md](sources/zsh-integrations.md) — Git, Docker, CI/CD, and dev environment integration
- [CHANGELOG.md](CHANGELOG.md) — Project history
- [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) — Community standards
- [sources/zsh-faq.md](sources/zsh-faq.md) — Frequently asked questions
- [sources/zsh-version-compatibility.md](sources/zsh-version-compatibility.md) — Version matrix and migration guides
- [sources/zsh-performance.md](sources/zsh-performance.md) — Performance benchmarking and optimisation
- [sources/zsh-security.md](sources/zsh-security.md) — Security best practices and checklist
- [prompts/README.md](prompts/README.md) — Prompt template usage guide

---

**Last Updated:** 2026-02-25 (Phase 8 added)
