#!/bin/bash

# Check for dry-run flag
dry_run=false
if [ "$1" == "-n" ]; then
    dry_run=true
    shift  # Remove the dry-run flag from arguments
fi

# Specify the directories where your files are located
directory_keep="$1"
directory_delete="$2"

# Arrays for file extensions to keep and delete
extension_keep=(".JPG")
extension_delete=(".ARW")

# Loop through each extension in the extension_keep array
for ext_keep in "${extension_keep[@]}"; do
    # Loop through all files with the current extension in the keep directory
    for jpg_file in "$directory_keep"/*"$ext_keep"; do
        # Extract the filename without the extension
        filename=$(basename "$jpg_file" $ext_keep)

        # Loop through each extension in the extension_delete array
        for ext_del in "${extension_delete[@]}"; do
            # Check if the corresponding file exists in the delete directory
            if [ -e "$directory_delete/$filename$ext_del" ]; then
                # Dry run: Just print the action
                if [ "$dry_run" = true ]; then
                    echo "[DRY-RUN] Would delete $directory_delete/$filename$ext_del because $filename$ext_keep exists."
                else
                    # Actual deletion
                    rm "$directory_delete/$filename$ext_del"
                    echo "Deleted $directory_delete/$filename$ext_del because $filename$ext_keep exists."
                fi
            fi
        done
    done
done