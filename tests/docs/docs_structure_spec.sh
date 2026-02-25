#!/usr/bin/env sh
# docs_structure_spec.sh - Documentation validation tests

Describe 'required top-level files'
  It 'README.md exists'
    The file "${SHELLSPEC_SPECDIR}/../README.md" should be exist
  End

  It 'TODO.md exists'
    The file "${SHELLSPEC_SPECDIR}/../TODO.md" should be exist
  End

  It 'BUILD.md exists'
    The file "${SHELLSPEC_SPECDIR}/../BUILD.md" should be exist
  End

  It 'AGENTS.md exists'
    The file "${SHELLSPEC_SPECDIR}/../AGENTS.md" should be exist
  End

  It 'CONTRIBUTING.md exists'
    The file "${SHELLSPEC_SPECDIR}/../CONTRIBUTING.md" should be exist
  End
End

Describe 'required sources/ documents'
  It 'sources/zsh-basics.md exists'
    The file "${SHELLSPEC_SPECDIR}/../sources/zsh-basics.md" should be exist
  End

  It 'sources/zsh-advanced.md exists'
    The file "${SHELLSPEC_SPECDIR}/../sources/zsh-advanced.md" should be exist
  End

  It 'sources/zsh-best-practices.md exists'
    The file "${SHELLSPEC_SPECDIR}/../sources/zsh-best-practices.md" should be exist
  End

  It 'sources/zsh-scripting-patterns.md exists'
    The file "${SHELLSPEC_SPECDIR}/../sources/zsh-scripting-patterns.md" should be exist
  End

  It 'sources/zsh-troubleshooting.md exists'
    The file "${SHELLSPEC_SPECDIR}/../sources/zsh-troubleshooting.md" should be exist
  End

  It 'sources/zsh-ecosystem.md exists'
    The file "${SHELLSPEC_SPECDIR}/../sources/zsh-ecosystem.md" should be exist
  End

  It 'sources/zsh-reference.md exists'
    The file "${SHELLSPEC_SPECDIR}/../sources/zsh-reference.md" should be exist
  End

  It 'sources/zsh-version-compatibility.md exists'
    The file "${SHELLSPEC_SPECDIR}/../sources/zsh-version-compatibility.md" should be exist
  End

  It 'sources/zsh-performance.md exists'
    The file "${SHELLSPEC_SPECDIR}/../sources/zsh-performance.md" should be exist
  End

  It 'sources/zsh-security.md exists'
    The file "${SHELLSPEC_SPECDIR}/../sources/zsh-security.md" should be exist
  End
End

Describe 'required examples/ directories'
  It 'examples/basic/ directory exists'
    The directory "${SHELLSPEC_SPECDIR}/../examples/basic" should be exist
  End

  It 'examples/advanced/ directory exists'
    The directory "${SHELLSPEC_SPECDIR}/../examples/advanced" should be exist
  End

  It 'examples/functions/ directory exists'
    The directory "${SHELLSPEC_SPECDIR}/../examples/functions" should be exist
  End

  It 'examples/config/ directory exists'
    The directory "${SHELLSPEC_SPECDIR}/../examples/config" should be exist
  End
End

Describe 'source document content checks'
  It 'zsh-basics.md contains non-empty content'
    The file "${SHELLSPEC_SPECDIR}/../sources/zsh-basics.md" should be present
  End

  It 'zsh-best-practices.md contains non-empty content'
    The file "${SHELLSPEC_SPECDIR}/../sources/zsh-best-practices.md" should be present
  End

  It 'zsh-advanced.md contains non-empty content'
    The file "${SHELLSPEC_SPECDIR}/../sources/zsh-advanced.md" should be present
  End
End

Describe 'example scripts'
  It 'all .zsh files in examples/ are non-empty'
    check_nonempty() {
      find "${SHELLSPEC_SPECDIR}/../examples" -name "*.zsh" -empty | wc -l
    }
    When run check_nonempty
    The output should eq '0'
  End

  It 'all .zsh files in examples/ have a shebang line'
    check_shebang() {
      find "${SHELLSPEC_SPECDIR}/../examples" -name "*.zsh" | while read -r f; do
        head -1 "$f" | grep -qE "^#!" || echo "$f"
      done
    }
    When run check_shebang
    The output should eq ''
  End
End
