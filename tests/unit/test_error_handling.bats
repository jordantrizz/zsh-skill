#!/usr/bin/env bats
# test_error_handling.bats - Unit tests for examples/advanced/error_handling.zsh

setup() {
    SCRIPT="$BATS_TEST_DIRNAME/../../examples/advanced/error_handling.zsh"
}

@test "error_handling.zsh exits with status 0" {
    run zsh "$SCRIPT"
    [ "$status" -eq 0 ]
}

@test "error_handling.zsh prints demo header" {
    run zsh "$SCRIPT"
    [[ "$output" == *"Error Handling Demo"* ]]
}

@test "error_handling.zsh demonstrates trap-based cleanup" {
    run zsh "$SCRIPT"
    [[ "$output" == *"Trap-based Cleanup"* ]]
}

@test "error_handling.zsh prints demo complete message" {
    run zsh "$SCRIPT"
    [[ "$output" == *"Demo complete"* ]]
}

@test "error_handling.zsh demonstrates pipeline section" {
    run zsh "$SCRIPT"
    [[ "$output" == *"Pipeline"* ]]
}
