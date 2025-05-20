#!/bin/bash

# Check if ffmpeg is installed
if ! command -v ffmpeg &> /dev/null; then
    echo "Error: ffmpeg is not installed. Please install it and try again."
    exit 1
fi

# Check if input file is provided
if [ -z "$1" ]; then
    echo "Usage: $0 input_file.mp4"
    exit 1
fi

# Input and output file names
input_file="$1"
output_file="${input_file%.*}_compressed.mp4"

# Run ffmpeg to resize the video to 720p
# ffmpeg -n -i "$input_file" -vf "scale=1280:720" -c:a copy "$output_file"
# echo "Video resized to 720p. Output file: $output_file"

# compress
ffmpeg -n -i "$input_file" -vcodec libx264 -crf 23 -preset medium -c:a copy "$output_file"
echo "Video resized to 720p. Output file: $output_file"
