#!/bin/bash

# Default restart Apache option
default_restart_apache=N

# Parse command line options
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -r|--restart) default_restart_apache="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Target directory
target_dir="/var/www/html"

# Check if the target directory exists, if not, create it
if [ ! -d "$target_dir" ]; then
    sudo mkdir -p "$target_dir"
fi

# Delete the contents of /var/www/html
sudo rm -rf "$target_dir"/*

# Copy the contents of ./website to /var/www/html
sudo cp -r ./website/* "$target_dir"

# Check if the copy operation was successful
if [ $? -eq 0 ]; then
    echo "Files copied successfully."

    # Check if restart Apache option was specified
    if [[ $default_restart_apache =~ ^[Yy]$ ]]; then
        sudo systemctl restart apache2
        echo "Apache restarted."
    else
        echo "Changes applied. Apache was not restarted."
    fi
else
    echo "Error: Failed to copy files."
fi