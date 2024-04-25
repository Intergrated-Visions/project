#!/bin/bash

# Update package index
sudo apt update

# Install PHP CLI, PHP MySQL extension, PHP AMQP extension, and MySQL Server
sudo apt install -y php-cli php-mysql php-amqp mysql-server

# The script will now also install MySQL Server
