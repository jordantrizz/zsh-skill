# `zsh-coding-standards` Skill

Canonical source for reusable Zsh coding standards skill files.

## Included Files

- `SKILL.md` - standards definition and behavior guidance
- `templates.md` - prompt templates for generation/review/refactor/debug
- `snippets.md` - starter code patterns

## Install Targets

### Project-local

Installs to:

`<project>/.copilot/skills/zsh-coding-standards/`

Use when you want versioned, repository-specific behavior.

### Global

Installs to:

`~/.copilot/skills/zsh-coding-standards/`

Use when you want your personal default across repositories.

## Sync Command

From repository root:

```bash
./sync-skill.sh --local
./sync-skill.sh --local /path/to/project
./sync-skill.sh --global
./sync-skill.sh --both /path/to/project
./sync-skill.sh --global --dry-run
```

## Versioning

Update `Version:` in `SKILL.md` when standards change. Keep changes documented in the repository changelog or release notes to track skill drift.