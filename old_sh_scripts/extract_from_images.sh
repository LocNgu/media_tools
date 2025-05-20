#!/bin/bash

# Dry run and interactive mode flags
dry_run=false
interactive=false

# Process command line options
while getopts ":niv" opt; do
  case $opt in
    n)
      dry_run=true
      ;;
    i)
      interactive=true
      ;;
    v)
      verbose=true
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
if [ $# -eq 2 ]; then
  directory="$1"
  extension="*.$2"
else
  echo "Usage: $0 [-n] [-i] <directory> <extension>"
  exit 1
fi

# Validate that the directory exists
if [ ! -d "$directory" ]; then
  echo "Error: Directory '$directory' does not exist."
  exit 1
fi

# Change into the specified directory
cd "$directory" || exit 1

# Iterate over photo files (dng, jpg, and jpeg)
for file in $extension; do
    # if [[ $file =~ ^[0-9]{8}_[0-9]{6}.*\. ]]; then
    #    echo "File '$file' is already in the correct format. Skipping."
    #    continue
    # fi
    # Extract the timestamp using exiftool
    # timestamp=$(exiftool -s -s -s -d "%Y%m%d_%H%M%S" -DateTimeOriginal "$file")
    timestamp=$(exiftool -s -s -s -createDate -d "%Y%m%d_%H%M%S"  "$file")

    # Fallback to FileModifyDate if DateTimeOriginal is missing
    if [ -z "$timestamp" ]; then
        echo "DateTimeOriginal not found, falling back to FileModifyDate for '$file'"
        timestamp=$(exiftool -s -s -s -d "%Y%m%d_%H%M%S" -FileModifyDate "$file")
    fi

    if [ -n "$timestamp" ]; then
    # Check if the file is already in the correct format
        # check if timestamp is already in the filename
        if [[ $file =~ $timestamp ]]; then
            if [ "$verbose" = true ]; then
                echo "File '$file' already contains the timestamp '$timestamp'. Skipping."
            fi
            continue
        fi
        # get timezone from the exif data
        



        # if [[ $file =~ ^[0-9]{8}_[0-9]{6}.*\. ]]; then
        #     if [ "$verbose" = true ]; then
        #         echo "File '$file' is already in the correct format. Skipping."
        #     fi
        #     continue
        # fi
        # Construct the new filename
        new_filename="${timestamp}.${file##*.}"
        counter=1
        while [ -e "$new_filename" ]; do
            new_filename="${timestamp}-${counter}.${file##*.}"
            counter=$((counter + 1))
        done

        if [ "$dry_run" = true ]; then
            # Dry run: Show the changes without applying them
            echo "Dry run: Would rename '$file' to '$new_filename'"
        elif [ "$interactive" = true ]; then
            # Interactive mode: Prompt the user before renaming
            read -p "Rename '$file' to '$new_filename'? (y/n): " response
            if [ "$response" = "y" ]; then
                mv "$file" "$new_filename"
                echo "Renamed '$file' to '$new_filename'"
            else
                echo "Skipped renaming '$file'"
            fi
        else
            # Rename the file
            mv "$file" "$new_filename"
            echo "Renamed '$file' to '$new_filename'"

        fi
    else
        echo "Failed to extract timestamp from '$file'"
    fi
done
