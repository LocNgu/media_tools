#!/bin/bash

# Check argument
if [ -z "$1" ]; then
  echo "Usage: $0 /Volumes/YourSDCard"
  exit 1
fi

VOLUME="$1"

# Check if path exists
if [ ! -d "$VOLUME" ]; then
  echo "Error: Path '$VOLUME' does not exist or is not a directory."
  exit 2
fi

echo "Starting f3write on $VOLUME..."
f3write "$VOLUME"

echo "Starting f3read on $VOLUME..."
f3read "$VOLUME"

echo "Cleaning up test files..."
rm "$VOLUME"/.f3write.*

echo "Test complete for $VOLUME."
