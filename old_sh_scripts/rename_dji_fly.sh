#!/bin/bash

# Dry run flag
dry_run=false

# Specify the directory containing the MP4 files
directory="/path/to/your/directory"

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
if [ $# -eq 1 ]; then
  directory="$1"
fi

# Change into the specified directory
cd "$directory" || exit 1

# Iterate over MP4 files starting with dji_fly_
for file in dji_fly_*.mp4; do
    # Extract components from the filename
    parts_count=$(echo "$file" | awk -F '_' '{print NF}')
    date=$(echo "$file" | awk -F '_' '{print $3}')
    time=$(echo "$file" | awk -F '_' '{print $4}')
    sequence_number=$(echo "$file" | awk -F '_' '{print $5}')
    if [ "$parts_count" -eq 7 ]; then
        additional_number=$(echo "$file" | awk -F '_' '{print $6}')
        type=$(echo "$file" | awk -F '_' '{print $7}')
        new_name="${date}_${time}_dji_fly_${sequence_number}_${additional_number}_${type}"
    else
        type=$(echo "$file" | awk -F '_' '{print $6}')
        new_name="${date}_${time}_dji_fly_${sequence_number}_${type}"
    fi
    # Create the new filename

    if [ "$dry_run" = true ]; then
        # Dry run: Show the changes without applying them
        echo "Dry run: Would rename '$file' to '$new_name'"
    else
        # Rename the file
        mv "$file" "$new_name"
        echo "Renamed '$file' to '$new_name'"
    fi
done
