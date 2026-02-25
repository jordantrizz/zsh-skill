#!/usr/bin/env sh
# arrays_and_maps_spec.sh - Unit tests for examples/basic/arrays_and_maps.zsh

Describe 'arrays_and_maps.zsh'
  arrays_and_maps() { zsh "${SHELLSPEC_SPECDIR}/../examples/basic/arrays_and_maps.zsh" "$@"; }

  It 'exits with status 0'
    When run arrays_and_maps
    The status should be success
  End

  It 'prints indexed array section'
    When run arrays_and_maps
    The output should include 'Indexed Arrays'
  End

  It 'demonstrates array append'
    When run arrays_and_maps
    The output should include 'After append'
  End

  It 'demonstrates element removal'
    When run arrays_and_maps
    The output should include "After removing 'banana'"
  End

  It 'prints associative array section'
    When run arrays_and_maps
    The output should include 'Associative Arrays'
  End

  It 'outputs associative array values'
    When run arrays_and_maps
    The output should include 'alice@example.com'
  End
End
