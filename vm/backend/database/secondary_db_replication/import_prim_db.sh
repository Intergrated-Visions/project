#!/bin/bash

# Set the database name
database_name="test123"

# Create the database using sudo mysql
sudo mysql -e "CREATE DATABASE IF NOT EXISTS $database_name;"

# Import data into the database
sudo mysql $database_name < /tmp/db_backup.sql

# Show list of databases
echo "List of databases:"
sudo mysql -e "SHOW DATABASES;"

# Show list of tables in the specified database
echo "List of tables in $database_name database:"
sudo mysql -e "SHOW TABLES FROM $database_name;"
