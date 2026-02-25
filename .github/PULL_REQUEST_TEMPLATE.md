## Description

<!-- What does this PR change and why? -->

## Type of Change

- [ ] New documentation (source file in `sources/`)
- [ ] New example script (in `examples/`)
- [ ] Bug fix
- [ ] Feature addition
- [ ] Refactor / cleanup
- [ ] CI / tooling change

## Checklist

- [ ] `shellspec tests/` passes with no failures
- [ ] All `.zsh` files have a `#!/usr/bin/env zsh` shebang
- [ ] New scripts include a `Description:` and `Usage:` comment header
- [ ] Variables are quoted (`"$var"`)
- [ ] Functions use `local` for internal variables
- [ ] Sourced files use `return`, not `exit`
- [ ] No hardcoded absolute paths (use `$SCRIPT_DIR`, `$HOME`, or `command -v`)
- [ ] New example scripts have a corresponding test in `tests/unit/`
- [ ] New source documents are listed in `tests/docs/docs_structure_spec.sh`
- [ ] (Optional) Reviewed `shellcheck --shell=bash` output for any real issues

## Related Issues

<!-- Closes #... -->
