#!/bin/bash

# Reverse copy script to transfer multiple files from VM to another location

# Variables
REMOTE_USER="root"          # Remote username
REMOTE_HOST="192.168.0.29"          # IP or hostname of the target VM or host
LOCAL_DIR="/audit/rapport/files_ubuntu"    # Directory to copy to

# List of remote files/directories to copy
REMOTE_FILES=(
    "/data/*.html"  # Add your first file or directory path
    "/data/*.log"  # Add your second file or directory path
    		   # Add additional files as needed
    # Add more paths as needed
)

# Ensure local directory exists
mkdir -p "$LOCAL_DIR"

# Perform the reverse copy using rsync
echo "Starting reverse copy from $REMOTE_HOST to $LOCAL_DIR..."

for FILE in "${REMOTE_FILES[@]}"; do
    rsync -avz --progress "$REMOTE_USER@$REMOTE_HOST:$FILE" "$LOCAL_DIR"
done

# Check if the last rsync command was successful
if [ $? -eq 0 ]; then
    echo "Reverse copy completed successfully."
else
    echo "Error during reverse copy."
    exit 1
fi
