#!/bin/bash
# Update package index
sudo apt update

# Install PHP CLI, PHP MySQL extension, PHP AMQP extension, and MySQL Server
sudo apt install -y php-cli php-mysql php-amqp mysql-server

# The script will now also install MySQL Server
# Install RabbitMQ
echo "Installing RabbitMQ..."
sudo apt-get update
sudo apt-get install -y rabbitmq-server

# Enable RabbitMQ management plugin
sudo rabbitmq-plugins enable rabbitmq_management

# Install RabbitMQ management tool
echo "Installing RabbitMQ management tool..."
sudo wget http://localhost:15672/cli/rabbitmqadmin -O /usr/local/bin/rabbitmqadmin
sudo chmod +x /usr/local/bin/rabbitmqadmin

# Copy rabbitmq.config to the correct system folder
echo "Copying rabbitmq.config file..."
sudo cp ./rabbitmq.config /etc/rabbitmq/

# Restart RabbitMQ service
echo "Restarting RabbitMQ service..."
sudo service rabbitmq-server restart

echo "Setup completed successfully."