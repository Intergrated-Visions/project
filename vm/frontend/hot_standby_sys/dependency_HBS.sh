#!/bin/bash

# Check if Keepalived is installed
if ! command -v keepalived &>/dev/null; then
    # Install Keepalived
    echo "Installing Keepalived..."
    sudo apt update
    sudo apt install -y keepalived
    echo "Keepalived installed."
fi

# Define the path to the script file
check_apache_script="/etc/keepalived/check_apache.sh"

# Check if the file exists
if [ ! -f "$check_apache_script" ]; then
    # File does not exist, create it with sudo privileges
    echo '#!/bin/bash' | sudo tee "$check_apache_script" >/dev/null
    echo '' | sudo tee -a "$check_apache_script" >/dev/null
    echo '# Check if Apache2 service is running' | sudo tee -a "$check_apache_script" >/dev/null
    echo 'if systemctl is-active --quiet apache2; then' | sudo tee -a "$check_apache_script" >/dev/null
    echo '    exit 0  # Apache2 is running, exit with success' | sudo tee -a "$check_apache_script" >/dev/null
    echo 'else' | sudo tee -a "$check_apache_script" >/dev/null
    echo '    exit 1  # Apache2 is not running, exit with failure' | sudo tee -a "$check_apache_script" >/dev/null
    echo 'fi' | sudo tee -a "$check_apache_script" >/dev/null

    # Make the file executable
    sudo chmod +x "$check_apache_script"

    echo "File $check_apache_script created and made executable."
else
    echo "File $check_apache_script already exists."
fi

