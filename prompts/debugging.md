# Debugging Prompts

Prompt templates for diagnosing and fixing Zsh script problems with AI assistants.

---

## 📌 Usage Notes

Always include the **exact** error message and the **exact** Zsh version when using
these templates — behaviour often differs across versions. Attach
`sources/zsh-troubleshooting.md` as context for all debugging sessions.

---

## 🐛 Template 1 — Generic Debugging

**When to use:** A script fails or behaves unexpectedly and you don't know why.

**Context files to include:** `sources/zsh-troubleshooting.md`, `sources/zsh-best-practices.md`

---

[PROMPT START]

You are an expert Zsh debugger. Help me diagnose and fix a problem in my Zsh script.

**Zsh version:** [ZSH_VERSION — run: `echo $ZSH_VERSION`]
**OS:** [OS — e.g., macOS 14, Ubuntu 22.04]

**What the script is supposed to do:**
[EXPECTED_BEHAVIOUR — one or two sentences]

**What actually happens:**
[ACTUAL_BEHAVIOUR — describe the unexpected behaviour]

**Error output (if any):**
```
[ERROR_MESSAGE — paste verbatim, including any line numbers]
```

**Script:**
```zsh
[CODE]
```

**What I have already tried:**
[ATTEMPTS — e.g., "I added `set -x` and saw that $file is empty on line 12"]

Please:
1. Identify the root cause.
2. Explain why the error occurs.
3. Provide a corrected version of the relevant section.
4. Suggest one or two preventive practices to avoid similar issues in the future.

[PROMPT END]

---

## 🐛 Template 2 — Specific Error Message

**When to use:** You have a specific Zsh error message and don't know what it means.

**Context files to include:** `sources/zsh-troubleshooting.md`

---

[PROMPT START]

You are an expert Zsh debugger. Explain the following Zsh error message and show me
how to fix it.

**Error message:**
```
[ERROR_MESSAGE — paste the complete error, e.g.:]
zsh: no matches found: *.txt
zsh: bad pattern: [abc
zsh: parse error near `fi'
```

**Context — the line(s) that produced this error:**
```zsh
[CODE_CONTEXT — paste the relevant lines, ideally ±5 lines around the error]
```

**Zsh version:** [ZSH_VERSION]

Please:
1. Explain what this error message means in plain language.
2. Identify the exact cause in the code shown.
3. Show the fixed code.
4. List any other common triggers for this error that I should watch out for.

[PROMPT END]

---

## 🐛 Template 3 — Performance Debugging

**When to use:** A script is slower than expected and you want to find the bottleneck.

**Context files to include:** `sources/zsh-advanced.md`, `sources/zsh-troubleshooting.md`

---

[PROMPT START]

You are a Zsh performance expert. Help me find and fix the performance bottleneck in
my script.

**What the script does:** [DESCRIPTION]

**Observed performance:** [PERF — e.g., "Takes 45 seconds to process 500 files; expected < 5 seconds"]

**Profiling data (if available):**
Run `zsh -x script.zsh 2>&1 | head -100` and paste relevant output, or if you have
`zprof` output, paste it here.
```
[PROFILING_OUTPUT or "not available"]
```

**Script:**
```zsh
[CODE]
```

Please:
1. Identify the most likely bottleneck(s) based on the code and profiling data.
2. Explain why each bottleneck is slow.
3. Provide optimised alternatives with an estimated improvement.
4. If possible, suggest how to verify the improvement (e.g., with `time`).

[PROMPT END]

---

## 🐛 Template 4 — Completion System Debugging

**When to use:** Tab-completion is broken, missing, or behaving unexpectedly.

**Context files to include:** `sources/zsh-troubleshooting.md`, `sources/zsh-advanced.md`

---

[PROMPT START]

You are a Zsh completion system expert. Help me debug a completion problem.

**Zsh version:** [ZSH_VERSION]
**Completion framework (if any):** [FRAMEWORK — e.g., Oh My Zsh, Prezto, plain compinit]

**Problem description:**
[DESCRIPTION — e.g., "Tab-completing `git` shows no suggestions after upgrading to macOS 14"]

**What I expect to happen:** [EXPECTED]

**What actually happens:** [ACTUAL]

**Relevant section of `.zshrc`:**
```zsh
[ZSHRC_EXCERPT]
```

**Output of `compaudit` (run it and paste output):**
```
[COMPAUDIT_OUTPUT]
```

**Output of `echo $fpath` (one path per line):**
```
[FPATH_OUTPUT]
```

Please:
1. Diagnose the likely cause.
2. Provide step-by-step fix instructions.
3. Explain any permissions or path issues that may be involved.
4. Suggest how to verify that completion is working correctly after the fix.

[PROMPT END]

---

## 🩺 Diagnostic Checklist

Before posting a debugging question to an AI assistant, work through this checklist.
The answers will help the AI give a much more precise diagnosis.

### Information to Gather

- [ ] **Exact error message** — copy verbatim, including file/line references
- [ ] **Zsh version** — `echo $ZSH_VERSION`
- [ ] **OS and version** — `uname -a` or `sw_vers` on macOS
- [ ] **How the script is invoked** — `zsh script.zsh`, `./script.zsh`, `source script.zsh`, etc.
- [ ] **Minimal reproducible example** — reduce to the smallest script that shows the problem

### Quick Self-Checks

```zsh
# 1. Enable tracing to see exactly what Zsh executes
zsh -x script.zsh 2>&1 | head -50

# 2. Check for syntax errors before running
zsh -n script.zsh

# 3. Print key variables at the point of failure
echo "DEBUG: file='$file' status='$?'" >&2

# 4. Check if a command exists
command -v the_command

# 5. Inspect an array or associative array
typeset -p my_array

# 6. Check options that are set
setopt

# 7. Verify file existence and permissions
ls -la "$file"
[[ -f $file ]] && echo "exists" || echo "missing"
```

### Common Causes by Symptom

| Symptom | First thing to check |
|---------|---------------------|
| `no matches found` | Add `(N)` glob qualifier or `setopt NULL_GLOB` |
| `bad pattern` | Escape special chars or wrap pattern in quotes |
| `command not found` | Check `$PATH`; use `whence -v cmd` |
| Variable is empty unexpectedly | Check quoting; run `typeset -p var` |
| Script exits without error | `setopt ERR_EXIT` may have triggered; add `trap 'echo line $LINENO' ERR` |
| Completion broken after update | Run `compaudit` and fix permissions; `rm ~/.zcompdump` then restart |
| Function not found in script | Functions in `.zshrc` are not available in non-interactive scripts |
| `parse error near EOF` | Missing `fi`, `done`, `esac`, or closing `}` |

### Reference

For more detailed solutions to common errors, see `sources/zsh-troubleshooting.md`.

---

Last Updated: 2025-01-01
