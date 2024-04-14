#!/bin/bash

# Define the full path to the zip file you want to unzip
zipFilePath="/home/ubuntu/Desktop/deployer/packageReceiver/copyfile/backup2024-04-12_21-54-19.zip"

# Define the directory where you want to extract the contents of the zip file
extractToDir="/home/ubuntu/Desktop/deployer"

# Check if the zip file exists
if [ ! -f "$zipFilePath" ]; then
    echo "The file $zipFilePath does not exist."
    exit 1
fi

# Make sure the directory to which you want to extract exists or create it
mkdir -p "$extractToDir"

# Unzip the file
unzip -o "$zipFilePath" -d "$extractToDir"

# Check if the unzip command was successful
if [ $? -eq 0 ]; then
    echo "Unzipped the file successfully to $extractToDir"
else
    echo "Failed to unzip the file."
    exit 1
fi
