#!/bin/bash

# Define the directory of the project you want to package
projectDir="/home/yardley/Desktop/project"

# Define the directory where the zip file will be saved
zipSaveDir="$projectDir/packages"

# Ensure the save directory exists
mkdir -p "$zipSaveDir"

# Define the name of the archive you want to create
zipFileName="backup$(date +%Y-%m-%d_%H-%M-%S).zip"
zipFilePath="$zipSaveDir/$zipFileName"

# Navigate to the project directory
cd "$projectDir" || exit

# Package the project into a zip file, excluding the '.git' folder and the packages directory itself
zip -r -9 "$zipFilePath" . -x "*.git*" -x "packages/*"

# Check if the ZIP command succeeded
if [ $? -eq 0 ]; then
    echo "Package has been created successfully: $zipFilePath"
else
    echo "Could not create the zip package."
    exit 1
fi

# Check the number of backup packages in the directory and delete the oldest if more than 3
cd "$zipSaveDir"  # Change to the directory where the zip files are stored
ls -t | grep -E '\.zip$' | tail -n +4 | xargs -r rm --  # List zip files, order by time, skip the first three, and delete the rest

# Assuming main.php is located in the 'scripts/createPackage' directory
phpScriptPath="$projectDir/scripts/createPackage/main.php"

# Run main.php with the directory path and the zip file name
/usr/bin/php "$phpScriptPath" "$zipSaveDir" "$zipFileName"

# Return to the original directory
cd -
