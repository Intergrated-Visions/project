#!/bin/bash

# Directory to watch for changes
DIRECTORY_TO_WATCH="/home/yardley/Desktop/project/backend"

# Base path for the output bundle file
OUTPUT_BUNDLE_BASE="/home/yardley/Desktop/project/changeFolder/backendBundle"

# Variable to hold the last bundle name
LAST_BUNDLE=""

# Function to package and save the bundle
package_directory() {
  # If a last bundle exists, delete it
  if [ -f "$LAST_BUNDLE" ]; then
    echo "Removing old bundle: $LAST_BUNDLE"
    rm "$LAST_BUNDLE"
  fi

  # Increment the bundle count
  let BUNDLE_COUNT++

  # Create a new bundle name with the incremented count
  OUTPUT_BUNDLE="${OUTPUT_BUNDLE_BASE}${BUNDLE_COUNT}.tar.gz"

  # Update LAST_BUNDLE with the new bundle's name
  LAST_BUNDLE="$OUTPUT_BUNDLE"

  # Package the directory into the bundle
  tar -czf "$OUTPUT_BUNDLE" "$DIRECTORY_TO_WATCH"
  echo "Directory has been packaged into $OUTPUT_BUNDLE"
}

# Check for inotify-tools and install if not present
if ! type inotifywait > /dev/null; then
  sudo apt-get install -y inotify-tools
fi

# Use inotifywait to monitor the directory for changes recursively
inotifywait -m -r -e create -e modify -e delete -e move "$DIRECTORY_TO_WATCH" --format '%w%f' |
while read file; do
  echo "Change detected in $file"
  package_directory
done
