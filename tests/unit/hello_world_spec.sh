#!/usr/bin/env sh
# hello_world_spec.sh - Unit tests for examples/basic/hello_world.zsh

Describe 'hello_world.zsh'
  hello_world() { zsh "${SHELLSPEC_SPECDIR}/../examples/basic/hello_world.zsh" "$@"; }

  It 'exits with status 0'
    When run hello_world
    The status should be success
  End

  It 'prints default greeting with no arguments'
    When run hello_world
    The output should include 'Hello, World!'
  End

  It 'accepts a custom name argument'
    When run hello_world Alice
    The output should include 'Hello, Alice!'
  End

  It 'includes welcome message'
    When run hello_world
    The output should include 'Welcome to Zsh scripting'
  End

  It 'outputs upper and lower case transformations'
    When run hello_world Alice
    The output should include 'Upper: ALICE'
    The output should include 'Lower: alice'
  End
End
