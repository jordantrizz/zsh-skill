#!/usr/bin/env sh
# error_handling_spec.sh - Unit tests for examples/advanced/error_handling.zsh

Describe 'error_handling.zsh'
  error_handling() { zsh "${SHELLSPEC_SPECDIR}/../examples/advanced/error_handling.zsh" "$@"; }

  It 'exits with status 0'
    When run error_handling
    The status should be success
  End

  It 'prints demo header'
    When run error_handling
    The output should include 'Error Handling Demo'
  End

  It 'demonstrates trap-based cleanup'
    When run error_handling
    The output should include 'Trap-based Cleanup'
  End

  It 'prints demo complete message'
    When run error_handling
    The output should include 'Demo complete'
  End

  It 'demonstrates pipeline section'
    When run error_handling
    The output should include 'Pipeline'
  End
End
