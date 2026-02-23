# Prompts — AI-Assisted Zsh Development

This directory contains ready-to-use prompt templates for common Zsh development tasks.
Each template is designed to work with AI assistants such as GitHub Copilot, Claude,
ChatGPT, and similar tools.

---

## 📂 Contents

| File | Purpose |
|------|---------|
| [code-generation.md](./code-generation.md) | Generate new Zsh functions and scripts |
| [code-review.md](./code-review.md) | Review existing Zsh code for quality and correctness |
| [learning.md](./learning.md) | Learn Zsh concepts, compare with Bash, build exercises |
| [debugging.md](./debugging.md) | Diagnose and fix Zsh script problems |

---

## 🚀 How to Use These Templates

### 1. Choose the right template

Pick the file that matches your goal:
- Writing new code → `code-generation.md`
- Reviewing existing code → `code-review.md`
- Understanding a concept → `learning.md`
- Fixing a broken script → `debugging.md`

### 2. Copy the prompt

Each template contains one or more prompt blocks. Copy the entire block into your AI
assistant's chat input.

### 3. Replace placeholders

Placeholders look like `[THIS]`. Replace them with your specific content:

```
[DESCRIPTION]    → Brief description of what you want
[REQUIREMENTS]   → Bullet list of specific requirements
[CODE]           → Paste your Zsh code here
[ERROR_MESSAGE]  → Paste the exact error output
```

### 4. Attach context files

Many templates recommend attaching source files from `../sources/` as context.
The more relevant context you provide, the better the AI's output.

**Example with GitHub Copilot:**
```
# Add a comment reference at the top of your file
# @see sources/zsh-best-practices.md
```

**Example with Claude:**
```
I'm attaching the Zsh best practices guide as context.
[attach sources/zsh-best-practices.md]
```

**Example with ChatGPT:**
```
Here is a Zsh best practices guide to inform your answer:
[paste relevant sections from sources/zsh-best-practices.md]
```

---

## 📋 Template Format

Each template follows this structure:

```
### Template Name

**When to use:** Short description of the use case.

**Context files to include:** Which source docs to attach.

---

[PROMPT START]

...prompt text with [PLACEHOLDERS]...

[PROMPT END]

---
```

The `[PROMPT START]` / `[PROMPT END]` markers are not part of the prompt — copy only
the text between them.

---

## 🔗 Related Resources

- `../sources/zsh-basics.md` — Zsh fundamentals
- `../sources/zsh-best-practices.md` — Coding standards
- `../sources/zsh-advanced.md` — Advanced features
- `../sources/zsh-troubleshooting.md` — Common errors and fixes
- `../sources/zsh-faq.md` — Frequently asked questions
- `../AGENTS.md` — AI platform integration guide

---

Last Updated: 2025-01-01
