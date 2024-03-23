#!/bin/bash

install_gh() {
    # Create directory for keyrings
    sudo mkdir -p -m 755 /etc/apt/keyrings

    # Download and add GitHub CLI GPG key to keyring
    sudo wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
    sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg

    # Add GitHub CLI repository to sources list
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

    # Update package list
    sudo apt update

    # Install GitHub CLI
    sudo apt install gh -y

    echo "GitHub CLI (gh) installed successfully."
}

configure_gh() {
    # Perform gh auth login
    gh auth login
}

configure_git() {
    # Set Git configuration for name
    read -p "Enter your Git username: " git_username
    git config --global user.name "$git_username"

    # Set Git configuration for email
    read -p "Enter your Git email: " git_email
    git config --global user.email "$git_email"

    echo "Git configuration updated successfully."
}

# Prompt user for each step
read -p "Do you want to install GitHub CLI (gh)? (y/n): " install_gh_choice
if [[ $install_gh_choice == "y" ]]; then
    install_gh
fi

read -p "Do you want to configure GitHub CLI (gh)? (y/n): " configure_gh_choice
if [[ $configure_gh_choice == "y" ]]; then
    configure_gh
fi

read -p "Do you want to configure Git? (y/n): " configure_git_choice
if [[ $configure_git_choice == "y" ]]; then
    configure_git
fi
