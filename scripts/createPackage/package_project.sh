#!/bin/bash

# The directory of the project you want to package
projectDir="/home/yardley/Desktop/project"

# The directory where the zip file will be saved
zipSaveDir="/home/yardley/Desktop/project/packages"

# Ensure the save directory exists
mkdir -p "$zipSaveDir"

# Navigate to the project directory to use relative paths
cd "$projectDir" || exit

# The name of the archive you want to create
zipFileName="project_backup_$(date +%Y-%m-%d_%H-%M-%S).zip"

# Package the project into a zip file, excluding the '.git' folder and the packages directory itself to avoid recursion
zip -r -9 "$zipSaveDir/$zipFileName" . -x ".git/*" "packages/*"

# Check if the ZIP command succeeded
if [ $? -eq 0 ]; then
    echo "Package has been created successfully: $zipSaveDir/$zipFileName"
else
    echo "Could not create the zip package."
    exit 1
fi

# Check the number of backup packages in the directory and delete the oldest if more than 3
packageCount=$(ls -1 "$zipSaveDir"/*.zip 2>/dev/null | wc -l)

if [ "$packageCount" -gt 3 ]; then
    echo "More than 3 backup packages found. Deleting the oldest backup package..."
    oldestPackage=$(ls -t "$zipSaveDir"/*.zip | tail -1)
    rm -f "$oldestPackage"
    echo "Deleted the oldest package: $oldestPackage"
fi
