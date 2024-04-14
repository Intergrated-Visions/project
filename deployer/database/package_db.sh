#!/bin/bash
# Check if the db.sql file exists in the current directory
sudo apt update
sudo apt install mysql-server
sudo apt install -y php-cli php-mysql php-amqp mysql-server
if [ -f "package_db.sql" ]; then
    # Run the db.sql file
    sudo mysql < package_db.sql
    echo "The SQL script has been executed."
else
    echo "Error: db.sql file does not exist in the current directory."
fi
