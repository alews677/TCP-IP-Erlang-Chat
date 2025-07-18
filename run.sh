#!/bin/bash

PROJECT_DIR="$(pwd)"
SOURCE_DIR="$PROJECT_DIR/src"
OUTPUT_DIR="$PROJECT_DIR/bin"

mkdir -p "$OUTPUT_DIR"

# Find .erl file and compile it
find "$SOURCE_DIR" -name '*.erl' -print0 | while IFS= read -r -d '' file; do
    erlc -o "$OUTPUT_DIR" "$file"
done

echo "Compilation complete $OUTPUT_DIR"

cd bin
erl
cd ..