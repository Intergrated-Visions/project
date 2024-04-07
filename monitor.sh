#!/bin/bash

# List of remote hostnames
remote_hosts=("hostname1" "hostname2" "hostname3")

# Remote folder (same for all hosts)
remote_folder="/path/to/remote/folder"

# Local folder where changes are aggregated
local_folder="/path/to/local/folder"

# Function to install rsync if not installed
install_rsync() {
    if ! command -v rsync &> /dev/null; then
        echo "rsync is not installed. Installing rsync..."
        sudo apt-get update
        sudo apt-get install -y rsync
    else
        echo "rsync is already installed."
    fi
}

# Function to synchronize a remote folder with the local folder
sync_from_remote() {
    local remote_host=$1

    echo "Synchronizing from $remote_host..."

    rsync -avz "${remote_host}:${remote_folder}/" "${local_folder}"
}

# Function to distribute local changes back to the remote folder
sync_to_remote() {
    local remote_host=$1

    echo "Distributing changes to $remote_host..."

    rsync -avz "${local_folder}/" "${remote_host}:${remote_folder}"
}

# Main execution
install_rsync
for remote_host in "${remote_hosts[@]}"; do
    sync_from_remote "$remote_host"
done

# The above will sync all changes from the remotes to the local folder
# Now you can manually invoke sync_to_remote to push changes to a specific remote
# Example usage to push changes back to hostname1: sync_to_remote "hostname1"

# If you want to automatically push changes back to all remotes after syncing, uncomment the following lines:
# for remote_host in "${remote_hosts[@]}"; do
#     sync_to_remote "$remote_host"
# done
