# Contributing to zsh-skill

Thank you for helping improve the `zsh-skill` knowledge base! This guide explains how to
contribute code, documentation, and tests.

---

## Getting Started

1. **Fork** the repository and clone your fork locally.
2. Install the prerequisites listed in [BUILD.md](BUILD.md).
3. Create a feature branch from `main`:
   ```bash
   git checkout -b feature/my-improvement
   ```
4. Make your changes following the guidelines below.
5. Run the test suite and linter before opening a PR (see [Running Tests](#running-tests)).
6. Open a pull request against `main`.

---

## Development Setup

```zsh
# Required
zsh --version          # 5.0+
shellspec --version    # 0.28+

# Optional static analysis (no tool fully supports Zsh)
shellcheck --version   # 0.8+ — bash-only; Zsh false positives expected

# Install ShellSpec (if not present)
curl -fsSL https://github.com/shellspec/shellspec/releases/download/0.28.1/shellspec-dist.tar.gz \
  | tar -zxf - -C /tmp
sudo ln -s /tmp/shellspec/shellspec /usr/local/bin/shellspec  # Linux
brew install shellspec                                         # macOS
```

---

## Code Style

### Shell Scripts (`.zsh` files)

- Use `#!/usr/bin/env zsh` as the shebang.
- Include a comment block at the top with `Description:` and `Usage:`.
- Prefer Zsh builtins over external commands where practical.
- Quote all variable expansions: `"$var"`, not `$var`.
- Use `local` for all function-internal variables.
- Use `return`, never `exit`, in sourced files and function libraries.
- Keep lines ≤ 100 characters.
- Use `typeset -A` for associative arrays (Zsh idiomatic over `declare -A`).

### Markdown (`.md` files)

- Use ATX headings (`#`, `##`, etc.).
- Wrap code examples in fenced code blocks with a language tag (` ```zsh `).
- Keep lines ≤ 120 characters where practical.
- Include a `---` separator before the final "Related" or "Last Updated" section.

---

## Running Tests

```bash
# Run the full test suite
shellspec

# Run a specific suite
shellspec --shell zsh tests/unit/
shellspec --shell zsh tests/integration/
shellspec --shell zsh tests/docs/

# Optional: run ShellCheck for best-effort hints (Zsh false positives are expected)
find . -name "*.zsh" -not -path "./.git/*" | xargs shellcheck --shell=bash
```

All ShellSpec specs must pass before a PR can be merged. ShellCheck output is informational
and will not block a PR. The CI pipeline (`.github/workflows/ci.yml`) runs these checks
automatically on every push and pull request.

---

## Adding New Content

### New Example Script

1. Place the file in the appropriate subdirectory under `examples/`:
   - `examples/basic/` — beginner-friendly demonstrations
   - `examples/advanced/` — advanced features
   - `examples/functions/` — reusable function libraries
   - `examples/config/` — `.zshrc` / `.zshenv` examples
2. Follow the existing script style (shebang, description comment, sections).
3. Add a corresponding unit spec in `tests/unit/<script_name>_spec.sh`.
4. Verify the script passes ShellCheck (with documented suppressions if needed).

### New Documentation

1. Add the `.md` file to the `sources/` directory.
2. Reference it from `README.md` and `BUILD.md` where appropriate.
3. Add a file-existence check to `tests/docs/docs_structure_spec.sh`.

---

## Pull Request Checklist

Before opening a PR, confirm **all** of the following:

- [ ] `shellspec` passes with no failures
- [ ] All `.zsh` files have a `#!/usr/bin/env zsh` shebang
- [ ] New scripts include a `Description:` and `Usage:` comment header
- [ ] Variables are quoted (`"$var"`)
- [ ] Functions use `local` for internal variables
- [ ] Sourced files use `return`, not `exit`
- [ ] No hardcoded absolute paths (use `$SCRIPT_DIR`, `$HOME`, or `command -v`)
- [ ] New example scripts have a corresponding test in `tests/unit/`
- [ ] New source documents are listed in `tests/docs/docs_structure_spec.sh`
- [ ] PR description explains *what* changed and *why*
- [ ] (Optional) Reviewed `shellcheck --shell=bash` output for any real issues

---

## Code Review Process

Pull requests require at least one review before merging.

Reviewers will check for:

1. **Correctness** — does the script behave as documented?
2. **Zsh idioms** — does it use Zsh features appropriately vs. POSIX/Bash fallbacks?
3. **Safety** — are variables quoted? Are error paths handled?
4. **Test coverage** — are the new/changed behaviours tested?
5. **Documentation** — are public functions/scripts documented?

### Automated Checks

The CI pipeline enforces:

| Check | Tool | Failure = block merge? |
|-------|------|------------------------|
| Static analysis | ShellCheck | No — informational only (no Zsh support) |
| Unit specs | ShellSpec | Yes |
| Integration specs | ShellSpec | Yes |
| Documentation structure | ShellSpec | Yes |
| Required file presence | bash | Yes |

---

## Reporting Issues

- **Bug reports** — include the Zsh version (`zsh --version`), OS, and a minimal
  reproducible example.
- **Feature requests** — describe the use case and how it fits the project goals in
  [TODO.md](TODO.md).
- **Documentation gaps** — open an issue with the section and what's unclear or missing.

---

## License

By contributing, you agree that your contributions will be licensed under the same license
as this repository. See [LICENSE](LICENSE) if present, or ask in the issue tracker.

---

**Last Updated:** 2026-02-20
