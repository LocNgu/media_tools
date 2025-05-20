#!/bin/bash

source ./check_for_duplicates.sh

setup_test_environment() {
    mkdir -p test_folder1 test_folder2
    echo "test content" > test_folder1/test_file.txt
    echo "test content" > test_folder2/test_file.txt
}

cleanup_test_environment() {
    rm -rf test_folder1 test_folder2
}

test_should_exit_if_first_argument_is_not_directory() {
    setup_test_environment

    output=$(./check_for_duplicates.sh not_a_directory test_folder2 2>&1)
    status=$?

    cleanup_test_environment

    if [ $status -ne 1 ]; then
        echo "Expected exit status 1, got $status"
        exit 1
    fi

    expected_output="Both arguments must be directories."
    if [[ "$output" != *"$expected_output"* ]]; then
        echo "Expected output to contain '$expected_output', got '$output'"
        exit 1
    fi

    echo "Test passed"
}
