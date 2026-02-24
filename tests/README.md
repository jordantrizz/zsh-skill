# Tests — zsh-skill

This directory contains the automated test suite for the `zsh-skill` repository,
implemented with **[ShellSpec](https://github.com/shellspec/shellspec)** — a BDD-style
testing framework with native Zsh support.

---

## Framework: ShellSpec

**Why ShellSpec?**
After evaluating the available Zsh/shell testing frameworks:

| Framework | Verdict |
|-----------|---------|
| **ShellSpec** | ✅ Selected — native Zsh support (`--shell zsh`), BDD DSL, actively maintained |
| bats-core | ❌ Bash only; Zsh must be invoked as a subprocess |
| shunit2 | ⚠️ Simpler API but less CI-friendly; no TAP output |
| zunit | ⚠️ Zsh-native but less widely supported; smaller community |

Running specs with `--shell zsh` means spec files execute natively in Zsh, eliminating
the Bash/Zsh mismatch that bats-core requires.

---

## Directory Layout

```
tests/
├── README.md                        # This file
├── unit/                            # Unit specs — one _spec.sh per example script
│   ├── hello_world_spec.sh
│   ├── arrays_and_maps_spec.sh
│   └── error_handling_spec.sh
├── integration/                     # Integration specs — run all examples end-to-end
│   └── examples_run_spec.sh
└── docs/                            # Documentation specs — validate repo structure
    └── docs_structure_spec.sh
```

---

## Running the Tests

### Prerequisites

```bash
# Install ShellSpec
curl -fsSL https://github.com/shellspec/shellspec/releases/download/0.28.1/shellspec-dist.tar.gz \
  | tar -zxf - -C /tmp
sudo ln -s /tmp/shellspec/shellspec /usr/local/bin/shellspec

# Install ShellSpec (macOS via Homebrew)
brew install shellspec

# Install Zsh (required to run example scripts)
sudo apt-get install zsh     # Ubuntu/Debian
brew install zsh             # macOS
```

### Run All Tests

```bash
shellspec
```

### Run a Specific Suite

```bash
shellspec --shell zsh tests/unit/
shellspec --shell zsh tests/integration/
shellspec --shell zsh tests/docs/
```

### Run a Single File

```bash
shellspec --shell zsh tests/unit/hello_world_spec.sh
```

### TAP Output (for CI)

```bash
shellspec --shell zsh --format tap tests/
```

---

## Writing Tests

Each `_spec.sh` file follows this pattern:

```sh
#!/usr/bin/env sh
# my_script_spec.sh - Unit tests for examples/basic/my_script.zsh

Describe 'my_script.zsh'
  my_script() { zsh "${SHELLSPEC_SPECDIR}/../examples/basic/my_script.zsh" "$@"; }

  It 'exits with status 0'
    When run my_script
    The status should be success
  End

  It 'produces expected output'
    When run my_script
    The output should include 'expected text'
  End
End
```

### Conventions

- File names must end with `_spec.sh`.
- Wrap each script-under-test in a helper function using `$SHELLSPEC_SPECDIR` for path resolution.
- Each `It` block should describe one observable behaviour.
- Use `The status should be success` for exit code 0; `The status should be failure` for non-zero.
- Use `The output should include 'text'` for partial output matching.
- Use `Skip "reason"` to mark specs that require optional tooling.

---

## Related

- [BUILD.md](../BUILD.md) — Full contributor guide including CI/CD details
- [CONTRIBUTING.md](../CONTRIBUTING.md) — How to contribute and code review standards
- [.github/workflows/ci.yml](../.github/workflows/ci.yml) — Automated CI pipeline
