#!/bin/bash

# Set the base Git directory (default to current .git directory)
BASE_DIR="${1:-.git}"
HEAD_PATH="$BASE_DIR/HEAD"

# Function to get the current commit SHA
if [[ ! -f "$HEAD_PATH" ]]; then
    echo "HEAD file not found: $HEAD_PATH" >&2
    exit 1
fi

# Read the content of HEAD
ref=$(<"$HEAD_PATH")
ref=$(echo "$ref" | tr -d '\n')

if [[ "$ref" == ref:\ * ]]; then
    # It's a symbolic ref
    ref_path="$BASE_DIR/${ref#ref: }"
    if [[ -f "$ref_path" ]]; then
        commit_hash=$(<"$ref_path")
        echo "$commit_hash"
    else
        echo "Ref file not found: $ref_path" >&2
        exit 1
    fi
else
    # Detached HEAD
    echo "$ref"
fi
