#!/bin/bash

# Update package lists
sudo apt update

# Install Apache2
sudo apt install -y apache2

# Install development libraries and tools
sudo apt install -y libc6-dev gcc make libgd-dev php wget

# Install Nagios NRPE plugin
sudo apt install -y nagios-nrpe-plugin

# Download Nagios Core
NAGIOS_VERSION="4.4.6"
wget "https://assets.nagios.com/downloads/nagioscore/releases/nagios-${NAGIOS_VERSION}.tar.gz"
tar -zxvf "nagios-${NAGIOS_VERSION}.tar.gz"
cd "nagios-${NAGIOS_VERSION}"

# Configure and install Nagios Core
./configure --with-httpd-conf=/etc/apache2/sites-enabled
make all
sudo make install
sudo make install-init
sudo make install-config
sudo make install-commandmode
sudo make install-webconf

# Update Nagios configuration
sudo sed -i '/^cfg_file=/ { s|^cfg_file=.*|cfg_file=/usr/local/nagios/etc/objects/hosts.cfg|; }' /usr/local/nagios/etc/nagios.cfg

# Download Nagios Plugins
sudo apt install -y nagios-nrpe-plugin nagios-plugins

NAGIOS_PLUGINS_VERSION="2.3.3"
wget "https://nagios-plugins.org/download/nagios-plugins-${NAGIOS_PLUGINS_VERSION}.tar.gz"
tar -zxvf "nagios-plugins-${NAGIOS_PLUGINS_VERSION}.tar.gz"
cd "nagios-plugins-${NAGIOS_PLUGINS_VERSION}"


# Install Nagios Plugins
./configure
make
sudo make install

# Enable Apache modules and restart Apache
sudo a2enmod rewrite cgi
sudo systemctl restart apache2

# Create Nagios user and group
sudo useradd nagios
sudo groupadd nagcmd
sudo usermod -a -G nagcmd nagios
sudo usermod -a -G nagcmd www-data

# Restart Nagios service
sudo systemctl restart nagios

# Create Nagios admin user
sudo htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin

# Validate Nagios configuration
sudo /usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg

# Clean up downloaded files
rm -rf "nagios-${NAGIOS_VERSION}" "nagios-plugins-${NAGIOS_PLUGINS_VERSION}" "*.tar.gz"

echo "Installation and configuration completed."
