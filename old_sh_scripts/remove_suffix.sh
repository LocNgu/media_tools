#!/bin/bash

# Dry run flag
dry_run=false

# Process command line options
while getopts ":n" opt; do
  case $opt in
    n)
      dry_run=true
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

# Remove processed options
shift $((OPTIND-1))

# Check if a directory path is provided
if [ $# -eq 0 ]; then
  echo "Usage: $0 [-n] <directory_path>"
  exit 1
fi

# Directory path from command line argument
directory="$1"
suffix="$2"
# Change into the specified directory
cd "$directory" || exit 1

# Iterate over files with names like "2023_1225_14095200 (1).jpg"
for file in *$suffix*; do
    # Extract the base filename without the " (1)"
    new_name="${file//$suffix/}"

    if [ "$dry_run" = true ]; then
        # Dry run: Show the changes without applying them
        echo "Dry run: Would rename '$file' to '$new_name'"
    else
        # Rename the file
        mv "$file" "$new_name"
        echo "Renamed '$file' to '$new_name'"
    fi
done
