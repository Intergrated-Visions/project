#!/bin/bash

# Update package index
sudo apt update

# Install PHP CLI, PHP MySQL extension, and PHP AMQP extension
sudo apt install -y php-cli php-amqp
