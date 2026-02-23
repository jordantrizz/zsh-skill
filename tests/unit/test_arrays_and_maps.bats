#!/usr/bin/env bats
# test_arrays_and_maps.bats - Unit tests for examples/basic/arrays_and_maps.zsh

setup() {
    SCRIPT="$BATS_TEST_DIRNAME/../../examples/basic/arrays_and_maps.zsh"
}

@test "arrays_and_maps.zsh exits with status 0" {
    run zsh "$SCRIPT"
    [ "$status" -eq 0 ]
}

@test "arrays_and_maps.zsh prints indexed array section" {
    run zsh "$SCRIPT"
    [[ "$output" == *"Indexed Arrays"* ]]
}

@test "arrays_and_maps.zsh demonstrates array append" {
    run zsh "$SCRIPT"
    [[ "$output" == *"After append"* ]]
}

@test "arrays_and_maps.zsh demonstrates element removal" {
    run zsh "$SCRIPT"
    [[ "$output" == *"After removing 'banana'"* ]]
}

@test "arrays_and_maps.zsh prints associative array section" {
    run zsh "$SCRIPT"
    [[ "$output" == *"Associative Arrays"* ]]
}

@test "arrays_and_maps.zsh outputs associative array values" {
    run zsh "$SCRIPT"
    [[ "$output" == *"alice@example.com"* ]]
}
