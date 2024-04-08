#!/bin/bash

# Directory to watch for changes
DIRECTORY_TO_WATCH="/home/yardley/Desktop/project/frontend"

# Base path for the output bundle file and .deb package
OUTPUT_BASE="/home/yardley/Desktop/project/changeFolder/frontend"
OUTPUT_BUNDLE_BASE="${OUTPUT_BASE}/backendBundle"
OUTPUT_DEB_BASE="${OUTPUT_BASE}/package"

# Variable to hold the last bundle and .deb package name
LAST_BUNDLE=""
LAST_DEB=""

# Ensure the output base directory exists
mkdir -p "$OUTPUT_BASE"

# Counter for the bundle naming
BUNDLE_COUNT=0

# Function to package and save the bundle, then create .deb package
package_directory() {
  # If a last bundle exists, delete it along with its .deb package
  if [ -f "$LAST_BUNDLE" ]; then
    echo "Removing old bundle: $LAST_BUNDLE"
    rm "$LAST_BUNDLE"
  fi
  if [ -f "$LAST_DEB" ]; then
    echo "Removing old .deb package: $LAST_DEB"
    rm "$LAST_DEB"
  fi

  # Increment the bundle count
  let BUNDLE_COUNT++

  # Create new bundle name with the incremented count
  OUTPUT_BUNDLE="${OUTPUT_BUNDLE_BASE}${BUNDLE_COUNT}.tar.gz"

  # Update LAST_BUNDLE with the new bundle's name
  LAST_BUNDLE="$OUTPUT_BUNDLE"

  # Package the directory into the bundle
  tar -czf "$OUTPUT_BUNDLE" -C "$DIRECTORY_TO_WATCH" .
  echo "Directory has been packaged into $OUTPUT_BUNDLE"

  # Prepare for .deb packaging
  PACKAGE_NAME="myapp_${BUNDLE_COUNT}"
  DEB_DIR="$OUTPUT_BASE/$PACKAGE_NAME"
  mkdir -p "$DEB_DIR/DEBIAN"
  CONTROL_FILE="$DEB_DIR/DEBIAN/control"

  # Create the control file for .deb package
  cat > "$CONTROL_FILE" <<EOF
Package: myapp
Version: 1.0.$BUNDLE_COUNT
Architecture: all
Maintainer: Your Name <you@example.com>
Description: An example application
EOF

  # Copy the tar.gz file into the package directory (you might want to extract and place its contents instead)
  mkdir -p "$DEB_DIR/usr/share/myapp"
  cp "$OUTPUT_BUNDLE" "$DEB_DIR/usr/share/myapp/"

  # Build the .deb package
  OUTPUT_DEB="${OUTPUT_DEB_BASE}${BUNDLE_COUNT}.deb"
  dpkg-deb --build "$DEB_DIR" "$OUTPUT_DEB"
  echo ".deb Package created: $OUTPUT_DEB"

  # Update LAST_DEB with the new .deb package's name
  LAST_DEB="$OUTPUT_DEB"

  # Clean up
  rm -r "$DEB_DIR"
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
