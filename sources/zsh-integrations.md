# Zsh Integrations Guide

<!-- semantic-tags: integrations, git, docker, ci-cd, development-environments -->

This guide covers practical integration patterns for using Zsh scripts in common development workflows, including Git, Docker, CI/CD pipelines, and local development environments.

---

## Git Workflows

### Pre-commit Hook

Use a Zsh script as a Git pre-commit hook to enforce code quality before every commit.

```zsh
#!/usr/bin/env zsh
# .git/hooks/pre-commit
# Description: Run ShellCheck and ShellSpec before committing Zsh files
# Usage: Installed automatically by Git

setopt ERR_EXIT PIPE_FAIL

# Check only staged .zsh files
local -a staged_zsh
staged_zsh=("${(@f)$(git diff --cached --name-only --diff-filter=ACM | grep '\.zsh$')}")

if (( ${#staged_zsh} == 0 )); then
  exit 0
fi

echo "==> Running ShellCheck on staged .zsh files (informational)..."
for f in "${staged_zsh[@]}"; do
  shellcheck --shell=bash "$f" || true   # informational only
done

echo "==> Running ShellSpec tests..."
shellspec --shell zsh tests/ || {
  echo "ERROR: ShellSpec tests failed. Commit aborted."
  exit 1
}

echo "==> All checks passed."
```

**Install the hook:**

```zsh
cp .git/hooks/pre-commit.sample .git/hooks/pre-commit  # or create fresh
chmod +x .git/hooks/pre-commit
```

> **Gotcha:** `.git/hooks/` is not version-controlled. Use a tool like
> [pre-commit](https://pre-commit.com/) or a setup script to distribute hooks
> across your team.

---

### commit-msg Hook

Enforce conventional commit message format with a Zsh hook.

```zsh
#!/usr/bin/env zsh
# .git/hooks/commit-msg
# Description: Validate conventional commit message format
# Usage: Installed automatically by Git

local msg_file="$1"
local msg
msg=$(<"$msg_file")

# Conventional commit pattern: type(scope): description
local pattern='^(feat|fix|docs|style|refactor|test|chore|ci|perf)(\(.+\))?: .{1,72}$'

if [[ ! "$msg" =~ $pattern ]]; then
  cat <<EOF
ERROR: Commit message does not follow Conventional Commits format.

Expected:  type(scope): short description
Examples:
  feat(sources): add zsh-integrations.md
  fix(examples): correct quoting in hello_world.zsh
  docs(readme): update quick-start section
  test(unit): add specs for error_handling example

Valid types: feat, fix, docs, style, refactor, test, chore, ci, perf
EOF
  exit 1
fi
```

---

### Git Alias for Running Tests

Add these aliases to `~/.gitconfig` for quick test runs during development:

```ini
[alias]
  spec  = !shellspec --shell zsh tests/
  lint  = !find . -name "*.zsh" -not -path "./.git/*" | sort | xargs shellcheck --shell=bash
  check = !git spec && git lint
```

Usage:

```zsh
git spec    # run the full ShellSpec test suite
git lint    # run ShellCheck across all .zsh files
git check   # run both
```

---

## Docker Usage

### Development Container

Run the test suite in a reproducible Docker environment without installing Zsh or ShellSpec locally.

```dockerfile
# Dockerfile.dev
FROM ubuntu:22.04

ARG SHELLSPEC_VERSION=0.28.1

RUN apt-get update -q && \
    apt-get install -y --no-install-recommends \
      zsh \
      shellcheck \
      curl \
      ca-certificates && \
    rm -rf /var/lib/apt/lists/*

RUN curl -fsSL \
      "https://github.com/shellspec/shellspec/releases/download/${SHELLSPEC_VERSION}/shellspec-dist.tar.gz" \
    | tar -zxf - -C /tmp && \
    ln -s /tmp/shellspec/shellspec /usr/local/bin/shellspec

WORKDIR /workspace
COPY . .

CMD ["shellspec", "--shell", "zsh", "tests/"]
```

**Build and run:**

```zsh
docker build -f Dockerfile.dev -t zsh-skill-test .
docker run --rm zsh-skill-test
```

> **Gotcha:** Docker's default shell is `/bin/sh` (Dash), not Zsh. Scripts inside
> `RUN` instructions use `sh` unless the shebang or `SHELL` directive overrides this.
> The Zsh scripts are *run by Zsh* inside the container, not by Docker's shell.

---

### Running a Single Script in Docker

Test a specific example script in isolation without modifying your host environment:

```zsh
docker run --rm \
  -v "$(pwd)/examples:/scripts:ro" \
  zsh:latest \
  zsh /scripts/basic/hello_world.zsh
```

---

### Docker Compose for Multi-Shell Testing

Test against multiple Zsh versions simultaneously:

```yaml
# docker-compose.test.yml
version: "3.9"

x-test-base: &test-base
  volumes:
    - .:/workspace:ro
  working_dir: /workspace
  command: shellspec --shell zsh tests/

services:
  test-zsh-5-8:
    <<: *test-base
    image: buildpack-deps:focal          # ships with zsh 5.8
    entrypoint: ["/bin/sh", "-c"]
    command:
      - "apt-get install -yq zsh shellspec 2>/dev/null; shellspec --shell zsh tests/"

  test-zsh-5-9:
    <<: *test-base
    image: buildpack-deps:jammy          # ships with zsh 5.9
    entrypoint: ["/bin/sh", "-c"]
    command:
      - "apt-get install -yq zsh shellspec 2>/dev/null; shellspec --shell zsh tests/"
```

```zsh
docker compose -f docker-compose.test.yml up --abort-on-container-exit
```

---

## CI/CD Pipelines

### GitHub Actions

The repository ships a production-ready workflow at `.github/workflows/ci.yml`.
Key patterns to reuse in your own pipelines:

```yaml
# .github/workflows/ci.yml (excerpt)
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install Zsh
        run: sudo apt-get update -q && sudo apt-get install -y zsh

      - name: Install ShellSpec
        run: |
          curl -fsSL \
            https://github.com/shellspec/shellspec/releases/download/0.28.1/shellspec-dist.tar.gz \
          | tar -zxf - -C /tmp
          sudo ln -s /tmp/shellspec/shellspec /usr/local/bin/shellspec

      - name: Run tests
        run: shellspec --shell zsh tests/
```

**Recommendations:**
- Pin ShellSpec to a specific version (e.g., `0.28.1`) to ensure reproducible builds.
- Cache the ShellSpec installation using `actions/cache` if build time matters.
- Run ShellCheck with `continue-on-error: true` — it does not support Zsh natively
  and its failures should be informational only.

**Gotchas:**
- GitHub-hosted runners use `bash` as the default shell. Pass `--shell zsh`
  explicitly to ShellSpec so specs run under Zsh.
- The `ubuntu-latest` runner ships with an older Zsh (typically 5.8). Use a
  matrix strategy to test against multiple versions when compatibility matters.

---

### GitLab CI

```yaml
# .gitlab-ci.yml
default:
  image: ubuntu:22.04
  before_script:
    - apt-get update -q && apt-get install -y zsh curl ca-certificates
    - |
      curl -fsSL \
        https://github.com/shellspec/shellspec/releases/download/0.28.1/shellspec-dist.tar.gz \
      | tar -zxf - -C /tmp
      ln -s /tmp/shellspec/shellspec /usr/local/bin/shellspec

stages:
  - lint
  - test

shellcheck:
  stage: lint
  allow_failure: true
  script:
    - apt-get install -y shellcheck
    - find . -name "*.zsh" -not -path "./.git/*" | xargs shellcheck --shell=bash

shellspec:
  stage: test
  script:
    - shellspec --shell zsh tests/
  artifacts:
    when: always
    reports:
      junit: report.xml
    paths:
      - report.xml
  after_script:
    - shellspec --shell zsh --format junit tests/ > report.xml 2>/dev/null || true
```

---

### Jenkins Pipeline

```groovy
// Jenkinsfile
pipeline {
    agent {
        docker { image 'ubuntu:22.04' }
    }

    environment {
        SHELLSPEC_VERSION = '0.28.1'
    }

    stages {
        stage('Setup') {
            steps {
                sh '''
                    apt-get update -q
                    apt-get install -y zsh curl ca-certificates shellcheck
                    curl -fsSL \
                      "https://github.com/shellspec/shellspec/releases/download/${SHELLSPEC_VERSION}/shellspec-dist.tar.gz" \
                    | tar -zxf - -C /tmp
                    ln -s /tmp/shellspec/shellspec /usr/local/bin/shellspec
                '''
            }
        }

        stage('Lint') {
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'UNSTABLE') {
                    sh 'find . -name "*.zsh" -not -path "./.git/*" | xargs shellcheck --shell=bash'
                }
            }
        }

        stage('Test') {
            steps {
                sh 'shellspec --shell zsh --format tap tests/ | tee test-results.tap'
            }
            post {
                always {
                    archiveArtifacts artifacts: 'test-results.tap', allowEmptyArchive: true
                }
            }
        }
    }
}
```

---

## Development Environments

### VS Code / Cursor

Add a `.vscode/tasks.json` to run tests from the IDE command palette:

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Run ShellSpec Tests",
      "type": "shell",
      "command": "shellspec --shell zsh tests/",
      "group": {
        "kind": "test",
        "isDefault": true
      },
      "presentation": {
        "reveal": "always",
        "panel": "shared"
      },
      "problemMatcher": []
    },
    {
      "label": "ShellCheck Lint",
      "type": "shell",
      "command": "find . -name '*.zsh' -not -path './.git/*' | sort | xargs shellcheck --shell=bash",
      "group": "build",
      "presentation": {
        "reveal": "always",
        "panel": "shared"
      },
      "problemMatcher": []
    }
  ]
}
```

> **Recommendation:** Install the [ShellCheck](https://marketplace.visualstudio.com/items?itemName=timonwong.shellcheck)
> VS Code extension for inline linting. Set `"shellcheck.shell": "bash"` in your
> workspace settings to avoid Zsh false positives.

---

### Dev Container (VS Code / GitHub Codespaces)

Add a `.devcontainer/devcontainer.json` for a fully reproducible environment:

```json
{
  "name": "zsh-skill",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu-22.04",
  "features": {
    "ghcr.io/devcontainers/features/common-utils:2": {
      "installZsh": true,
      "configureZshAsDefaultShell": true
    }
  },
  "postCreateCommand": "bash .devcontainer/install-tools.sh",
  "customizations": {
    "vscode": {
      "extensions": [
        "timonwong.shellcheck",
        "foxundermoon.shell-format"
      ],
      "settings": {
        "shellcheck.shell": "bash",
        "terminal.integrated.defaultProfile.linux": "zsh"
      }
    }
  }
}
```

```bash
#!/usr/bin/env bash
# .devcontainer/install-tools.sh
set -euo pipefail

SHELLSPEC_VERSION=0.28.1

# Install ShellCheck
sudo apt-get update -q && sudo apt-get install -y shellcheck

# Install ShellSpec
curl -fsSL \
  "https://github.com/shellspec/shellspec/releases/download/${SHELLSPEC_VERSION}/shellspec-dist.tar.gz" \
| tar -zxf - -C /tmp
sudo ln -s /tmp/shellspec/shellspec /usr/local/bin/shellspec

echo "==> Tools installed:"
shellcheck --version | head -1
shellspec --version
```

> **Gotcha:** The `devcontainer.json` `postCreateCommand` runs in `bash` by default.
> Write the install script as a Bash script (`.sh`), not a Zsh script, to avoid
> a chicken-and-egg problem if Zsh is not yet configured when the command runs.

---

### Makefile

A simple `Makefile` provides consistent entry points for common tasks:

```makefile
.PHONY: test lint check clean help

SHELL := /bin/bash

help:          ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*## "}; {printf "  %-12s %s\n", $$1, $$2}'

test:          ## Run the full ShellSpec test suite
	shellspec --shell zsh tests/

lint:          ## Run ShellCheck across all .zsh files (informational)
	find . -name "*.zsh" -not -path "./.git/*" | sort | xargs shellcheck --shell=bash || true

check: lint test  ## Run lint then tests

clean:         ## Remove generated reports
	rm -f report.xml test-results.tap
```

Usage:

```zsh
make test    # run ShellSpec
make lint    # run ShellCheck
make check   # run both
make help    # list all targets
```

---

## Summary

| Integration | Key Tool | Notes |
|-------------|----------|-------|
| Git pre-commit hook | ShellSpec | Prevents broken commits |
| Git commit-msg hook | Zsh regex | Enforces Conventional Commits |
| Docker | `zsh:latest` or `ubuntu:22.04` | Reproducible isolated testing |
| GitHub Actions | ShellSpec, ShellCheck | See `.github/workflows/ci.yml` |
| GitLab CI | ShellSpec | JUnit report for pipeline UI |
| Jenkins | ShellSpec TAP | TAP output for build artifacts |
| VS Code / Cursor | Tasks, ShellCheck extension | Inline lint + test runner |
| Dev Containers | devcontainer.json | One-click consistent environment |
| Makefile | ShellSpec, ShellCheck | Consistent CLI entry points |

---

<!-- related: zsh-best-practices.md#testing, zsh-security.md, zsh-performance.md -->

**Last Updated:** 2026-02-25
