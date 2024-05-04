#!/bin/bash

# Prompt the user to enter the database name
echo "Enter the name of the database:"
read database_name

# Prompt the user to enter the replica server username and IP address
echo "Enter the replica server username:"
read replica_username
echo "Enter the replica server IP address:"
read replica_ip

# Check if the database exists on the primary server
echo "Checking if the database '$database_name' exists on the primary server..."
if sudo mysql -e "USE $database_name;" &> /dev/null; then
    echo "Database '$database_name' exists on the primary server."
else
    echo "Database '$database_name' does not exist on the primary server."
    exit 1
fi

# Check if the database exists on the secondary server (replica)
echo "Checking if the database '$database_name' exists on the secondary server (replica)..."
if ssh "$replica_username@$replica_ip" "sudo mysql -e 'USE $database_name;' 2>/dev/null"; then
    echo "Database '$database_name' exists on the secondary server (replica)."
else
    echo "Database '$database_name' does not exist on the secondary server (replica) or there was an SSH connection error."
    exit 1
fi

# Check the list of tables in the specified database on the primary server
echo "List of tables in the '$database_name' database on the primary server:"
sudo mysql -e "SHOW TABLES FROM \`$database_name\`;"

# Check the list of tables in the specified database on the secondary server (replica)
echo "List of tables in the '$database_name' database on the secondary server (replica):"
ssh "$replica_username@$replica_ip" "sudo mysql -e 'SHOW TABLES FROM \`$database_name\`;'" | tail -n +2

# Check the replication status between primary and secondary servers
echo "Checking database replication status between primary and secondary servers..."
sudo mysql -e "SHOW SLAVE STATUS\G" | grep "Slave_IO_Running:\|Slave_SQL_Running:" | awk '{print "Primary Replication "$1": "$2}'
ssh "$replica_username@$replica_ip" "sudo mysql -e 'SHOW SLAVE STATUS\G'" | grep "Slave_IO_Running:\|Slave_SQL_Running:" | awk '{print "Secondary Replication "$1": "$2}'

echo "Database replication check completed."
