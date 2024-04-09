#!/bin/bash

# The directory of the project you want to package
projectDir="/home/yardley/Desktop/project"

# The directory where the zip file will be saved
zipSaveDir="/home/yardley/Desktop/project/packages"

# The name of the archive you want to create
zipFileName="project_backup_$(date +%Y-%m-%d_%H-%M-%S).zip"

# Ensure the save directory exists
mkdir -p "$zipSaveDir"

# Navigate to the project directory to use relative paths for exclusions
cd "$projectDir" || exit

# Package the project into a zip file, excluding the 'packages' folder and '.git' folder
# -r: recursively include files in directories
# -9: use the maximum compression level
# -x: exclude the following patterns
zip -r -9 "$zipSaveDir/$zipFileName" . -x "packages/*" ".git/*"

# Check if the ZIP command succeeded
if [ $? -eq 0 ]; then
    echo "Package has been created successfully: $zipSaveDir/$zipFileName"
else
    echo "Could not create the zip package."
fi
