#!/bin/bash

# Update package index
sudo apt update

# Install Apache2, PHP, and PHP-AMQP extension
sudo apt install -y apache2 php php-amqp

# Enable and start Apache2 service
sudo systemctl enable apache2
sudo systemctl start apache2

echo "Installation of Apache2, PHP, and PHP-AMQP extension completed."
