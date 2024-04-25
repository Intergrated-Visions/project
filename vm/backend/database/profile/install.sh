#!/bin/bash

# Get the full path to the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
//
# Get the directory name from the full path
DIR_NAME="$(basename "$SCRIPT_DIR")"

# Define the path to the /opt/ destination
DEST_DIR="/opt/$DIR_NAME"

# Check if the service is active before attempting to stop it
SERVICE_FILE="$DIR_NAME.service"
if systemctl is-active --quiet "$SERVICE_FILE"; then
    sudo systemctl stop "$SERVICE_FILE"
fi

# Copy the script directory to /opt/
sudo cp -r "$SCRIPT_DIR" "$DEST_DIR"

# Check if the .service file exists in the script directory
if [ -f "$SCRIPT_DIR/$SERVICE_FILE" ]; then
    # Copy the .service file to the systemd directory
    sudo cp "$SCRIPT_DIR/$SERVICE_FILE" "/etc/systemd/system/"

    # Set the proper permissions
    sudo chmod 644 "/etc/systemd/system/$SERVICE_FILE"

    # Reload the systemd daemon to recognize the new service
    sudo systemctl daemon-reload

    # Enable and start the service
    sudo systemctl enable "$SERVICE_FILE"
    sudo systemctl start "$SERVICE_FILE"

    echo "The service has been installed and started successfully."
else
    echo "Error: The .service file does not exist in the script directory."
fi
