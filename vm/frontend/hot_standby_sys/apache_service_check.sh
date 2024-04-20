#!/bin/bash

check_apache_script="/etc/keepalived/check_apache.sh"

# Check if the file exists
if [ ! -f "$check_apache_script" ]; then
    # File does not exist, create it
    echo '#!/bin/bash' > "$check_apache_script"
    echo '' >> "$check_apache_script"
    echo '# Check if Apache2 service is running' >> "$check_apache_script"
    echo 'if systemctl is-active --quiet apache2; then' >> "$check_apache_script"
    echo '    exit 0  # Apache2 is running, exit with success' >> "$check_apache_script"
    echo 'else' >> "$check_apache_script"
    echo '    exit 1  # Apache2 is not running, exit with failure' >> "$check_apache_script"
    echo 'fi' >> "$check_apache_script"

    # Make the file executable
    chmod +x "$check_apache_script"

    echo "File $check_apache_script created and made executable."
else
    echo "File $check_apache_script already exists."
fi
