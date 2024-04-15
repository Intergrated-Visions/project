#!/bin/bash

# Define the directory of the project you want to package
projectDir="/home/ubuntu/Desktop/project"

# Define the directory where the zip file will be saved
zipSaveDir="$projectDir/packages"

# The name of the archive you want to create
zipFileName="project_backup_$(date +%Y-%m-%d_%H-%M-%S).zip"

# Ensure the save directory exists
mkdir -p "$zipSaveDir"

# Navigate to the project directory to use relative paths for exclusions
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

# Run main.php with the directory path, zip file name, remote VM username, and host
/usr/bin/php "$phpScriptPath" "$zipSaveDir" "$zipFileName" "$remoteVMUsername" "$remoteVMHost"

# Return to the original directory
cd -
