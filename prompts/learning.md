# Learning Prompts

Prompt templates for learning Zsh concepts with AI assistants.

---

## 📌 Usage Notes

Replace `[TOPIC]` and other placeholders with your specific subject.
Attach the indicated context files so the AI grounds its explanation in the
patterns used in this repository.

---

## 📖 Template 1 — Concept Explanation

**When to use:** You want to understand a Zsh feature from scratch.

**Context files to include:** `sources/zsh-basics.md`, `sources/zsh-advanced.md`

---

[PROMPT START]

You are an expert Zsh teacher. Explain the following Zsh concept clearly and concisely.

**Concept:** [TOPIC — e.g., "Glob qualifiers"]

Structure your explanation as follows:

1. **What it is** — one or two sentences defining the concept.
2. **Why it matters** — when and why you'd use it over alternatives.
3. **Basic syntax** — the simplest possible example with a short comment.
4. **Common patterns** — three to five practical, runnable examples covering typical use cases.
5. **Gotchas** — one or two common mistakes and how to avoid them.
6. **Quick reference** — a compact table or list of the most useful variants.

Use `zsh` fenced code blocks for all examples. Keep explanations concise — favour
working code over lengthy prose.

[PROMPT END]

---

## 📖 Template 2 — Comparison with Bash

**When to use:** You know Bash and want to understand how Zsh differs on a specific topic.

**Context files to include:** `sources/zsh-basics.md`, `sources/zsh-advanced.md`, `sources/zsh-best-practices.md`

---

[PROMPT START]

You are an expert in both Bash and Zsh. I know Bash and want to understand how Zsh
handles the following topic differently.

**Topic:** [TOPIC — e.g., "Arrays and associative arrays"]

For each significant difference, show:
- The Bash way (labelled `# Bash`)
- The Zsh equivalent (labelled `# Zsh`)
- A brief note on why the difference exists or which is preferable

Cover:
1. Syntax differences
2. Behavioural differences (e.g., indexing, quoting rules)
3. Features that exist in Zsh but not Bash
4. Features that exist in Bash but work differently in Zsh
5. Any migration pitfalls to watch out for when converting a Bash script to Zsh

End with a concise "migration checklist" — a bullet list of things to check when
porting Bash code to Zsh.

[PROMPT END]

---

## 📖 Template 3 — Hands-On Exercise

**When to use:** You want to practise a concept with guided exercises.

**Context files to include:** `sources/zsh-basics.md`, `sources/zsh-best-practices.md`

---

[PROMPT START]

You are a Zsh instructor creating a hands-on exercise.

**Concept to practise:** [TOPIC — e.g., "Parameter expansion and string manipulation"]
**My current level:** [LEVEL — beginner / intermediate / advanced]

Create an exercise with the following structure:

1. **Setup** — any files or variables to create before starting (provide the exact
   Zsh commands to run).
2. **Tasks** — five to eight numbered tasks, progressing from simple to complex.
   Each task should be a clear instruction: "Write a command that...".
3. **Hints** — one-line hints for the two or three hardest tasks, collapsed behind
   a "Hint:" label so I can choose to read them.
4. **Solutions** — full working solutions for every task, each in its own
   `zsh` fenced code block with a brief explanation.
5. **Extension challenge** — one harder task that combines multiple concepts.

Make the tasks practical — use realistic file names, data, and scenarios rather
than abstract `x`/`y` variables.

[PROMPT END]

---

## 📖 Template 4 — Progressive Learning Path

**When to use:** You want a structured study plan for a topic or for Zsh in general.

**Context files to include:** `sources/zsh-basics.md`, `sources/zsh-advanced.md`, `sources/zsh-best-practices.md`, `sources/zsh-scripting-patterns.md`

---

[PROMPT START]

You are a Zsh curriculum designer. Create a progressive learning path for the
following goal.

**Learning goal:** [GOAL — e.g., "Become proficient at Zsh scripting for DevOps automation"]

Structure the path into three stages:

### Stage 1 — Beginner (0–2 hours)
- Core concepts to understand first
- Two or three essential commands/features to learn
- A simple practice project (describe it in one sentence)
- What "done" looks like: a concrete skill checkpoint

### Stage 2 — Intermediate (2–8 hours)
- Concepts that build on Stage 1
- Key Zsh-specific features that differ from Bash
- A medium-complexity practice project
- Skill checkpoint

### Stage 3 — Advanced (8+ hours)
- Advanced patterns and Zsh internals
- Topics that enable production-quality scripting
- A challenging project that demonstrates mastery
- Skill checkpoint

For each stage, list the specific sections in `sources/zsh-basics.md`,
`sources/zsh-advanced.md`, and `sources/zsh-best-practices.md` that are most relevant.

End with a list of five real-world scripts to write that would solidify the full
learning path.

[PROMPT END]

---

## 🎓 Learning Paths at a Glance

Use these as starting points when you don't know where to begin.

### Beginner Path
1. Read `sources/zsh-basics.md` — variables, arrays, conditionals, loops, functions
2. Try the exercises in `examples/basic/`
3. Use **Template 3** above to practise: variables, arrays, string manipulation
4. Write a script that accepts one argument and validates it

### Intermediate Path
1. Read `sources/zsh-advanced.md` — glob qualifiers, parameter expansion flags, completion
2. Read `sources/zsh-best-practices.md` — script structure, strict mode, error handling
3. Use **Template 2** to compare Zsh and Bash on: arrays, parameter expansion, traps
4. Write a file-processing script using glob qualifiers and `while read`

### Advanced Path
1. Read `sources/zsh-scripting-patterns.md` — reusable patterns and idioms
2. Study `sources/zsh-ecosystem.md` — tools, frameworks, and integrations
3. Use **Template 4** to create a learning plan focused on completion system and modules
4. Write a library of reusable functions with autoloading via `fpath`

---

Last Updated: 2025-01-01
