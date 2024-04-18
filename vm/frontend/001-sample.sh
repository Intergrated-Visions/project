#!/bin/bash

# Add virtual host configuration
sudo bash -c 'cat <<EOF > /etc/apache2/sites-available/001-sample.conf
  GNU nano 6.2                      001-sample.conf                                
<VirtualHost *:80>

ServerAdmin admin@integratedvisions.com
ServerName 192.168.50.22
DocumentRoot /var/www/html

ErrorLog ${APACHE_LOG_DIR}/error.log
CustomLog ${APACHE_LOG_DIR}/access.log combined

Redirect "/" "https://192.168.50.22/
</VirtualHost>
EOF'

echo "Apache configured successfully."
