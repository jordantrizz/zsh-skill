# Claude Integration Guide — Zsh Skill

This guide explains how to use Claude (claude.ai, Claude Code, or the Anthropic API) with the `zsh-skill` knowledge base for Zsh scripting assistance.

<!-- semantic-tags: claude, anthropic, ai-integration, zsh, documentation -->

## Overview

Claude is well-suited for Zsh scripting tasks because it can:

- Read and reason over multiple source documents simultaneously
- Perform multi-step code review against a checklist
- Generate idiomatic Zsh with explanations
- Debug complex shell scripting issues
- Explain Zsh concepts in depth

## Recommended Context Loading

### Minimal Context (Quick Questions)

For simple Zsh syntax questions, share the relevant section from a single source file:

```
[Paste content from sources/zsh-basics.md]

Q: How do I iterate over an associative array in Zsh?
```

### Standard Context (Code Generation)

For generating production-quality scripts, share two files:

```
--- sources/zsh-best-practices.md ---
[paste content]

--- sources/zsh-scripting-patterns.md ---
[paste content]

Task: Create a script that watches a directory for new .log files and rotates them.
Use idiomatic Zsh following the best practices above.
```

### Full Context (Code Review)

For thorough code review, share the best practices and troubleshooting guides:

```
--- sources/zsh-best-practices.md ---
[paste content]

--- sources/zsh-troubleshooting.md ---
[paste content]

Review the following script for correctness, best practices, and potential bugs:
[paste script]
```

## Prompt Templates

Use the templates in the `prompts/` directory:

| Template | File | Use Case |
|----------|------|----------|
| Code Generation | `prompts/code-generation.md` | Creating new scripts/functions |
| Code Review | `prompts/code-review.md` | Reviewing existing code |
| Learning | `prompts/learning.md` | Understanding Zsh concepts |
| Debugging | `prompts/debugging.md` | Diagnosing script problems |

## Formatting for Claude

Claude parses markdown well. When sharing source documents:

1. **Use headers** to separate sections: `## Section Name`
2. **Wrap code in fenced blocks** with the `zsh` language tag
3. **Use XML-like delimiters** to clearly separate context from your question:

```xml
<context>
[paste source document content here]
</context>

<task>
Write a Zsh function that validates an email address using regex.
</task>
```

## Example Interactions

### Example 1: Generating a Function

**Prompt:**

```
<context>
[contents of sources/zsh-best-practices.md]
</context>

<task>
Write a Zsh function called `backup_files` that:
- Accepts a source directory and a destination directory as arguments
- Validates both arguments exist
- Copies files newer than 24 hours from source to destination
- Logs each copied file
- Returns 0 on success, 1 on any error
Follow all coding standards in the context above.
</task>
```

### Example 2: Code Review

**Prompt:**

```
<context>
[contents of sources/zsh-best-practices.md]
</context>

<code>
#!/bin/zsh
for f in $(ls /tmp/*.log); do
  cat $f | grep ERROR >> errors.txt
done
</code>

<task>
Review this script and identify all violations of Zsh best practices.
For each issue, explain why it is a problem and provide a corrected version.
</task>
```

**Expected Claude response will identify:**
- Wrong shebang (`#!/bin/zsh` should be `#!/usr/bin/env zsh`)
- `ls` parsing (use glob directly)
- `$()` subshell in loop
- Unquoted `$f`
- Useless use of `cat` (`grep` can read directly)
- No error handling

### Example 3: Debugging

**Prompt:**

```
<context>
[contents of sources/zsh-troubleshooting.md]
</context>

<problem>
My script exits unexpectedly when I add `setopt ERR_EXIT`.
The problematic line is:
  grep "pattern" /var/log/syslog

The script exits even when grep runs successfully (the pattern exists in the log).
Why does this happen, and how do I fix it?
</problem>
```

### Example 4: Learning

**Prompt:**

```
<context>
[contents of sources/zsh-advanced.md — glob qualifiers section]
</context>

<task>
I'm a Bash developer learning Zsh. Explain how glob qualifiers work, why they are
more powerful than using `find`, and give me 5 practical examples comparing Bash
`find` commands with their Zsh glob qualifier equivalents.
</task>
```

## Claude Code Agent Integration

When using Claude Code (claude.ai with code execution or the `claude` CLI), you can reference files directly:

```bash
# Using Claude CLI
claude --context sources/zsh-best-practices.md \
       --context sources/zsh-scripting-patterns.md \
       "Review the scripts in examples/advanced/ for best practice violations"
```

Or reference the repository in a Claude Code session:

```
I'm working in the zsh-skill repository. The sources/ directory contains 
Zsh documentation. Please:
1. Read sources/zsh-best-practices.md
2. Review examples/advanced/advanced_scripting.zsh
3. List all best practice violations you find
```

## Documentation Format Guidelines

When writing or updating `sources/` markdown files for optimal Claude parsing:

### Structure

```markdown
# Title

<!-- semantic-tags: topic1, topic2, topic3 -->

## Overview
Brief description (1-3 sentences).

## Key Concepts

### Concept Name
Explanation.

**Syntax:**
```zsh
# example code
```

**When to use:** explanation
**Gotcha:** warning

## FAQ
<!-- See sources/zsh-faq.md for the dedicated FAQ document -->

## See Also
- [Related topic](other-file.md)
```

### Semantic Tags

Add `<!-- semantic-tags: ... -->` comments after each major heading to help Claude's retrieval. Tags should be lowercase, comma-separated keywords:

```markdown
<!-- semantic-tags: arrays, associative-arrays, typeset, indexed-arrays -->
```

### Knowledge Graph Links

Use standard markdown links to create relationships between documents:

```markdown
<!-- related: zsh-advanced.md#glob-qualifiers, zsh-best-practices.md#error-handling -->
```

## Capabilities & Limitations

| Capability | Claude | Notes |
|-----------|--------|-------|
| Zsh syntax generation | ✅ Excellent | Understands Zsh-specific constructs |
| Code review against checklist | ✅ Excellent | Methodical multi-point review |
| Explaining concepts | ✅ Excellent | Detailed explanations with examples |
| Debugging complex scripts | ✅ Good | May need full script context |
| Completion system (`compsys`) | ⚠️ Fair | Complex area; validate output |
| Running/executing code | ❌ None | Cannot run scripts; static analysis only |
| Accessing live system state | ❌ None | Cannot check installed packages, etc. |

## Tips for Best Results

1. **Be specific about Zsh version** when compatibility matters: "I need this to work on Zsh 5.2+".
2. **Provide error messages verbatim** when debugging: copy the exact output of `zsh -x`.
3. **Use structured prompts** with `<context>`, `<task>`, `<code>` delimiters.
4. **Reference source files explicitly**: "Following the conventions in `sources/zsh-best-practices.md`…"
5. **Ask for explanations**: Claude's explanations help you learn, not just copy-paste.
6. **Request step-by-step reasoning** for complex debugging: "Think through this step by step."

---

**Last Updated:** 2026-02-23
