#!/bin/bash

# Folder to monitor
FOLDER_TO_MONITOR="./website"

# Script to run
SCRIPT_TO_RUN="copy_website.sh"

# Function to run the script
run_script() {
    echo "Changes detected. Copying"
    ./$SCRIPT_TO_RUN
}

# Check if inotifywait is installed
if ! command -v inotifywait &> /dev/null; then
    echo "inotifywait is not installed. Installing..."
    # Install inotify-tools package
    if [ -x "$(command -v apt-get)" ]; then
        sudo apt-get update
        sudo apt-get install -y inotify-tools
    fi
fi

# Monitor the folder for changes
while inotifywait -r -e modify,move,create,delete $FOLDER_TO_MONITOR; do
    run_script
done
