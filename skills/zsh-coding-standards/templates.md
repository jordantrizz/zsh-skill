# Templates for `zsh-coding-standards`

## Code Generation Template

Use the `zsh-coding-standards` skill from this repository.

Task:
- Build a Zsh script/function that does: <describe task>

Requirements:
- Use local variables in functions
- Quote all expansions unless intentional splitting is required
- Validate all user inputs and arguments
- Provide clear stderr error messages
- Prefer Zsh built-ins over external commands when practical
- Note any Zsh version compatibility assumptions

Output format:
- Final script
- Short explanation of safety and standards choices

## Code Review Template

Review this Zsh code with the `zsh-coding-standards` skill.

Focus on:
- Quoting and word-splitting safety
- Local vs global scope
- Error handling patterns and exit behavior
- Input/path validation
- Security pitfalls (unsafe eval, globbing, unchecked expansion)

Output format:
- Findings grouped by severity
- Minimal patch suggestions
- Optional improved code block

## Refactor Template

Refactor this script to match `zsh-coding-standards` while preserving behavior.

Refactor goals:
- Reduce external process usage where possible
- Improve function boundaries and naming
- Add robust argument validation
- Keep portability notes for non-default Zsh options

Output format:
- Updated script
- Behavior-preservation notes
- Any edge cases to retest

## Debugging Template

Debug this Zsh issue using `zsh-coding-standards`:

Problem:
- <symptom>

Context:
- Zsh version: <version>
- Environment: <os/shell setup>
- Repro steps: <steps>

Output format:
- Most likely root cause
- Minimal fix
- Quick validation commands/tests