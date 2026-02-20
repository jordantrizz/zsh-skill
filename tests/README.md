# Tests — zsh-skill

This directory contains the automated test suite for the `zsh-skill` repository,
implemented with **[bats-core](https://github.com/bats-core/bats-core)** (Bash Automated
Testing System).

---

## Framework: bats-core

**Why bats?**
After evaluating the three main Zsh/shell testing frameworks:

| Framework | Verdict |
|-----------|---------|
| **bats-core** | ✅ Selected — actively maintained, TAP output, widely used in CI |
| shunit2 | ⚠️ Simpler API but less CI-friendly; no TAP output |
| zunit | ⚠️ Zsh-native but less widely supported; smaller community |

bats tests run in Bash but can invoke `zsh` as a sub-process, making them suitable for
testing Zsh scripts without requiring Zsh as the test runner itself.

---

## Directory Layout

```
tests/
├── README.md                    # This file
├── unit/                        # Unit tests — one .bats file per example script
│   ├── test_hello_world.bats
│   ├── test_arrays_and_maps.bats
│   └── test_error_handling.bats
├── integration/                 # Integration tests — run all examples end-to-end
│   └── test_examples_run.bats
└── docs/                        # Documentation tests — validate repo structure
    └── test_docs_structure.bats
```

---

## Running the Tests

### Prerequisites

```bash
# Install bats-core (Ubuntu/Debian)
sudo apt-get install bats

# Install bats-core (macOS via Homebrew)
brew install bats-core

# Install Zsh (required to run example scripts)
sudo apt-get install zsh     # Ubuntu/Debian
brew install zsh             # macOS
```

### Run All Tests

```bash
bats tests/
```

### Run a Specific Suite

```bash
bats tests/unit/
bats tests/integration/
bats tests/docs/
```

### Run a Single File

```bash
bats tests/unit/test_hello_world.bats
```

### TAP Output (for CI)

```bash
bats --tap tests/
```

---

## Writing Tests

Each `.bats` file follows this pattern:

```bash
#!/usr/bin/env bats

setup() {
    SCRIPT="$BATS_TEST_DIRNAME/../../examples/basic/my_script.zsh"
}

@test "script exits successfully" {
    run zsh "$SCRIPT"
    [ "$status" -eq 0 ]
}

@test "script produces expected output" {
    run zsh "$SCRIPT"
    [[ "$output" == *"expected text"* ]]
}
```

### Conventions

- File names must start with `test_` and end with `.bats`.
- Each test description should be a plain-English sentence.
- Use `run` before any command whose exit code or output you want to assert.
- Prefer `[[ ... ]]` over `[ ... ]` for string matching inside bats tests.
- Use `skip "reason"` to mark tests that require optional tooling (e.g., `shellcheck`).

---

## Related

- [BUILD.md](../BUILD.md) — Full contributor guide including CI/CD details
- [CONTRIBUTING.md](../CONTRIBUTING.md) — How to contribute and code review standards
- [.github/workflows/ci.yml](../.github/workflows/ci.yml) — Automated CI pipeline
