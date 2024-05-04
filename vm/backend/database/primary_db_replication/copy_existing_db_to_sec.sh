#!/bin/bash

# Set the database name
database_name="test123"

# Perform MySQL dump on the source server
sudo mysqldump "$database_name" > db_backup.sql

# Prompt the user to enter their username for the replica server
echo "Enter your username for the replica server:"
read username

# Prompt the user to enter the replica server IP address
echo "Enter the replica server IP address:"
read replica_server_ip

# Copy the MySQL dump to the replica server using SCP with password prompt
scp db_backup.sql "$username@$replica_server_ip:/tmp/"

# Clean up - remove the local MySQL dump file
rm db_backup.sql
