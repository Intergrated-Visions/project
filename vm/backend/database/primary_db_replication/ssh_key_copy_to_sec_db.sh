#!/bin/bash

# Enable debug mode if "-d" option is provided
if [[ "$1" == "-d" ]]; then
    set -x
fi

# Generate SSH key pair
echo "Generating RSA key pair..."
ssh-keygen -t rsa

# Prompt the user to enter the SSH username and remote server IP address
read -p "Enter your SSH username: " username
read -p "Enter the remote server IP address or hostname: " remote_server

# Copy the public key to the remote server
echo "Copying public key to $remote_server..."
ssh-copy-id "$username@$remote_server"

# Verify key-based authentication
echo "Testing key-based authentication..."
ssh "$username@$remote_server" exit

if [ $? -eq 0 ]; then
    echo "Key-based authentication successful! You can now SSH into $remote_server without a password."
else
    echo "Key-based authentication failed. Please check your configuration."
fi
