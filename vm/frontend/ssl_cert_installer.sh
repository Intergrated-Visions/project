#!/bin/bash

# Check if OpenSSL is installed
if ! command -v openssl &> /dev/null; then
    echo "OpenSSL is not installed. Please install OpenSSL and run this script again."
    exit 1
fi

# Check if Apache is installed
if ! command -v apache2 &> /dev/null; then
    echo "Apache is not installed. Please install Apache and run this script again."
    exit 1
fi

# Generate private key and certificate signing request (CSR)
sudo openssl req -nodes -newkey rsa:2048 -keyout /etc/ssl/private/private.key -out /etc/ssl/private/request.csr -subj "/C=US/ST=New Jersey/L=Newark/O=Integrated Visions/CN=integratedvisions.com"

# Generate SSL certificate from CSR
sudo openssl x509 -req -in /etc/ssl/private/request.csr -signkey /etc/ssl/private/private.key -out /etc/ssl/private/certificate.crt -days 365

# File paths
vhost_file="/etc/apache2/sites-available/001-sample.conf"
ssl_file="/etc/apache2/sites-available/default-ssl.conf"

# Check if the files exist
if [ ! -f "$vhost_file" ]; then
    echo "File $vhost_file does not exist."
    exit 1
fi

if [ ! -f "$ssl_file" ]; then
    echo "File $ssl_file does not exist."
    exit 1
fi

# Delete the content of the files
echo "" | sudo tee "$vhost_file" >/dev/null
echo "" | sudo tee "$ssl_file" >/dev/null

# Write the VirtualHost configuration block to the VirtualHost file
cat <<EOF | sudo tee -a "$vhost_file" >/dev/null
<VirtualHost *:80>
    ServerAdmin admin@integratedvisions.com
    ServerName 192.168.50.22
    DocumentRoot /var/www/html
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
    Redirect "/" "https://192.168.50.22/"
</VirtualHost>
EOF

# Write the SSL configuration block to the SSL file
cat <<EOF | sudo tee -a "$ssl_file" >/dev/null
<IfModule mod_ssl.c>
<VirtualHost _default_:443>
    ServerAdmin admin@integratedvisions.com
    ServerName 192.168.50.22
    DocumentRoot /var/www/html
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
    SSLEngine on
    SSLCertificateFile /etc/ssl/private/certificate.crt
    SSLCertificateKeyFile /etc/ssl/private/private.key

    <FilesMatch "\.(cgi|shtml|phtml|php)$">
        SSLOptions +StdEnvVars
    </FilesMatch>
    <Directory /usr/lib/cgi-bin>
        SSLOptions +StdEnvVars
    </Directory>
</VirtualHost>
</IfModule>
EOF

# Notify the user
echo "VirtualHost configuration written to $vhost_file."
echo "SSL configuration written to $ssl_file."

# Enable default SSL site configuration
sudo a2ensite 001-sample.conf

# Enable SSL and headers modules
sudo a2enmod ssl
sudo a2enmod headers

# Set permissions for private key
#sudo chmod 600 /etc/ssl/private/private.key

# Reload & restart Apache to apply changes
sudo systemctl restart apache2
sudo systemctl reload apache2

echo "SSL configured successfully."