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

# Iterate over MP4 files starting with DJI_
for file in *.AVI; do
    # Use exiftool to get the creation date metadata, ignoring warnings about embedded files
    created_date=$(exiftool -api largefilesupport=1 -b -m -CreateDate -Comment "$file")

    # Format the creation date to YYYYMMDD_HHMMSS
    formatted_date=$(date -jf "%Y:%m:%d %H:%M:%S" "$created_date" +"%Y%m%d_%H%M%S")

    # Extract the file number from the filename
    #file_number=$(echo "$file" | sed -n 's/.*DJI_0*\([1-9][0-9]*\).*/\1/p')

    # Get the Type value from the comment field using awk
    type_value=$(exiftool -Comment "$file" | grep 'Type=QuickShot')

    # Determine the suffix based on the Type value
    #if [ "$type_value" ]; then
    #    suffix="_quickshot.mp4"
    #else
    #    suffix="_video.mp4"
    #fi

    # Create the new filename
    new_name="${formatted_date}.mp4"
    if [ "$dry_run" = true ]; then
        # Dry run: Show the changes without applying them
        echo "Dry run: Would rename '$file' to '$new_name'"
    else
        # Rename the file
        mv "$file" "$new_name"
        echo "Renamed '$file' to '$new_name'"
    fi
done
