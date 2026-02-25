#!/usr/bin/env sh
# examples_run_spec.sh - Integration tests: verify all example scripts run without error

Describe 'basic examples'
  It 'hello_world.zsh runs without error'
    When run zsh "${SHELLSPEC_SPECDIR}/../examples/basic/hello_world.zsh"
    The status should be success
  End

  It 'arrays_and_maps.zsh runs without error'
    When run zsh "${SHELLSPEC_SPECDIR}/../examples/basic/arrays_and_maps.zsh"
    The status should be success
  End

  It 'control_flow.zsh runs without error'
    When run zsh "${SHELLSPEC_SPECDIR}/../examples/basic/control_flow.zsh"
    The status should be success
  End

  It 'file_operations.zsh runs without error'
    When run zsh "${SHELLSPEC_SPECDIR}/../examples/basic/file_operations.zsh"
    The status should be success
  End
End

Describe 'advanced examples'
  It 'error_handling.zsh runs without error'
    When run zsh "${SHELLSPEC_SPECDIR}/../examples/advanced/error_handling.zsh"
    The status should be success
  End

  It 'advanced_globbing.zsh runs without error'
    When run zsh "${SHELLSPEC_SPECDIR}/../examples/advanced/advanced_globbing.zsh"
    The status should be success
  End

  It 'async_jobs.zsh runs without error'
    When run zsh "${SHELLSPEC_SPECDIR}/../examples/advanced/async_jobs.zsh"
    The status should be success
  End
End

Describe 'function examples'
  It 'function_library.zsh runs without error'
    When run zsh "${SHELLSPEC_SPECDIR}/../examples/functions/function_library.zsh"
    The status should be success
  End

  It 'prompt_helpers.zsh runs without error'
    When run zsh "${SHELLSPEC_SPECDIR}/../examples/functions/prompt_helpers.zsh"
    The status should be success
  End
End
