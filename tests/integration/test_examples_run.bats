#!/usr/bin/env bats
# test_examples_run.bats - Integration tests: verify all example scripts run without error

EXAMPLES_DIR="$BATS_TEST_DIRNAME/../../examples"

@test "basic/hello_world.zsh runs without error" {
    run zsh "$EXAMPLES_DIR/basic/hello_world.zsh"
    [ "$status" -eq 0 ]
}

@test "basic/arrays_and_maps.zsh runs without error" {
    run zsh "$EXAMPLES_DIR/basic/arrays_and_maps.zsh"
    [ "$status" -eq 0 ]
}

@test "basic/control_flow.zsh runs without error" {
    run zsh "$EXAMPLES_DIR/basic/control_flow.zsh"
    [ "$status" -eq 0 ]
}

@test "basic/file_operations.zsh runs without error" {
    run zsh "$EXAMPLES_DIR/basic/file_operations.zsh"
    [ "$status" -eq 0 ]
}

@test "advanced/error_handling.zsh runs without error" {
    run zsh "$EXAMPLES_DIR/advanced/error_handling.zsh"
    [ "$status" -eq 0 ]
}

@test "advanced/advanced_globbing.zsh runs without error" {
    run zsh "$EXAMPLES_DIR/advanced/advanced_globbing.zsh"
    [ "$status" -eq 0 ]
}

@test "advanced/async_jobs.zsh runs without error" {
    run zsh "$EXAMPLES_DIR/advanced/async_jobs.zsh"
    [ "$status" -eq 0 ]
}

@test "functions/function_library.zsh runs without error" {
    run zsh "$EXAMPLES_DIR/functions/function_library.zsh"
    [ "$status" -eq 0 ]
}

@test "functions/prompt_helpers.zsh runs without error" {
    run zsh "$EXAMPLES_DIR/functions/prompt_helpers.zsh"
    [ "$status" -eq 0 ]
}
