#!/bin/bash
# Usage: ./script.sh FOLDER1 FOLDER2 [--dry-run] [-v|--verbose]
FOLDER1=$1
FOLDER2=$2
DRY_RUN=false
VERBOSE=false

# Parse arguments for --dry-run and --verbose flags
for arg in "$@"; do
    case $arg in
        -n|--dry-run)
            DRY_RUN=true
            ;;
        -v|--verbose)
            VERBOSE=true
            ;;
    esac
done

if [[ ! -d "$FOLDER1" || ! -d "$FOLDER2" ]]; then
    echo "Both arguments must be directories."
    exit 1
fi

if $VERBOSE; then
    echo "Verbose mode enabled"
    echo "Comparing $FOLDER1 to $FOLDER2"
fi

# Loop through files in FOLDER1
find "$FOLDER1" -type f | while read -r FILE1; do
    # Calculate relative path and corresponding file in FOLDER2
    REL_PATH="${FILE1#$FOLDER1/}"
    FILE2="$FOLDER2/$REL_PATH"

    if [[ -f "$FILE2" ]]; then
        if $VERBOSE; then
            echo "Found corresponding file: $FILE2"
        fi

        # Calculate checksums
        CHECKSUM1=$(md5 "$FILE1" | awk '{print $4}')
        CHECKSUM2=$(md5 "$FILE2" | awk '{print $4}')

        if $VERBOSE; then
            echo "Checksum1: $CHECKSUM1, Checksum2: $CHECKSUM2"
        fi

        # Compare checksums
        if [ "$CHECKSUM1" == "$CHECKSUM2" ]; then
            echo "Duplicate found:"
            echo "Original: $FILE1"
            echo "Duplicate: $FILE2"
            if $DRY_RUN; then
                echo "Dry-run: Would delete $FILE2"
            else
                echo "Deleting $FILE2"
                rm "$FILE2"
            fi
        fi
    fi
done
