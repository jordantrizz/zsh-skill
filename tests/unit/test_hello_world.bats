#!/usr/bin/env bats
# test_hello_world.bats - Unit tests for examples/basic/hello_world.zsh

setup() {
    SCRIPT="$BATS_TEST_DIRNAME/../../examples/basic/hello_world.zsh"
}

@test "hello_world.zsh exits with status 0" {
    run zsh "$SCRIPT"
    [ "$status" -eq 0 ]
}

@test "hello_world.zsh prints default greeting with no arguments" {
    run zsh "$SCRIPT"
    [[ "$output" == *"Hello, World!"* ]]
}

@test "hello_world.zsh accepts a custom name argument" {
    run zsh "$SCRIPT" "Alice"
    [[ "$output" == *"Hello, Alice!"* ]]
}

@test "hello_world.zsh includes welcome message" {
    run zsh "$SCRIPT"
    [[ "$output" == *"Welcome to Zsh scripting"* ]]
}

@test "hello_world.zsh outputs upper and lower case transformations" {
    run zsh "$SCRIPT" "Alice"
    [[ "$output" == *"Upper: ALICE"* ]]
    [[ "$output" == *"Lower: alice"* ]]
}
