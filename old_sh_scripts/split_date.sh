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

# Iterate over  files starting with dji_fly_
for file in [0-9][0-9][0-9][0-9]_[0-9][0-9][0-9][0-9]_*; do
    # Extract components from the filename
    year=$(echo "$file" | awk -F '_' '{print $1}')
    month_day=$(echo "$file" | awk -F '_' '{print $2}')
    new_name="${year}${month_day}_$(echo "$file" | cut -d'_' -f 3-)"


    if [ "$dry_run" = true ]; then
        # Dry run: Show the changes without applying them
        echo "Dry run: Would rename '$file' to '$new_name'"
    else
        # Rename the file
        mv "$file" "$new_name"
        echo "Renamed '$file' to '$new_name'"
    fi
done
