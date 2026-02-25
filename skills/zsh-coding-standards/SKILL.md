# Zsh Coding Standards Skill

Version: 1.0.0

## Purpose

Provide a reusable standards profile for writing, reviewing, and refactoring Zsh scripts with consistent quality, safety, and maintainability.

## Scope

Use this skill for:
- New Zsh scripts and function libraries
- Review of existing `.zsh` and shell utility files
- Migration toward consistent style across projects

Primary references in this repository:
- `sources/zsh-best-practices.md`
- `sources/zsh-security.md`
- `sources/zsh-troubleshooting.md`
- `sources/zsh-version-compatibility.md`

## Core Standards

1. Use explicit shebang for scripts: `#!/usr/bin/env zsh`
2. Prefer local scope in functions: `local var="value"`
3. Quote parameter expansions unless intentional splitting is required
4. Prefer Zsh built-ins and parameter expansion over unnecessary external commands
5. Validate function/script inputs early and fail fast with clear error messages
6. Use consistent error handling (`set -euo pipefail` where appropriate, guarded command handling where not)
7. Use predictable naming for functions and constants
8. Keep side effects explicit (cwd changes, env mutations, file writes)
9. Document compatibility assumptions when using newer Zsh features
10. Keep functions focused and testable

## Review Checklist

- Are variables quoted correctly?
- Are function variables `local` unless global is intentional?
- Is argument validation present?
- Is error output sent to stderr?
- Are glob patterns safe and intentional?
- Are shell options and traps used deliberately?
- Are there security concerns (word splitting, unsafe eval, unchecked paths)?
- Is script behavior covered by existing tests where possible?

## Response Behavior for AI Agents

When generating or reviewing Zsh code with this skill:
- Prioritize correctness and safety over brevity
- Explain tradeoffs when choosing between compatibility and modern Zsh features
- Suggest minimal, targeted changes for existing codebases
- Avoid introducing non-essential dependencies

## Suggested Prompt Prefix

"Apply the `zsh-coding-standards` skill from this repository. Follow `sources/zsh-best-practices.md` and enforce quoting, local scope, input validation, and safe error handling."