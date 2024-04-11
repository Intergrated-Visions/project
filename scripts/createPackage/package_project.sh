#!/bin/bash

# Store the current directory
currentDir=$(pwd)

# The directory of the project you want to package
projectDir="/home/yardley/Desktop/project"

# The directory where the zip file will be saved
zipSaveDir="$projectDir/packages"

# Ensure the save directory exists
mkdir -p "$zipSaveDir"

# The name of the archive you want to create
zipFileName="project_backup_$(date +%Y-%m-%d_%H-%M-%S).zip"

# Package the project into a zip file, excluding the '.git' folder and the packages directory itself to avoid recursion
zip -r -9 "$zipSaveDir/$zipFileName" "$projectDir" -x "*.git*" "packages/*"

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
    # Find the oldest file and delete it
    oldestPackage=$(ls -t "$zipSaveDir"/*.zip | tail -1)
    rm -f "$oldestPackage"
    echo "Deleted the oldest package: $oldestPackage"
fi

# Assuming main.php is located in the 'scripts/createPackage' directory
# Replace with the actual path to main.php if it's located elsewhere
phpScriptPath="$currentDir/main.php"

# Run main.php with the full path to the zip file
/usr/bin/php "$phpScriptPath" "$zipSaveDir/$zipFileName"

# Return to the original directory
cd "$currentDir"
