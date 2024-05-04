#!/bin/bash

# Prompt user to enter values for variables
#read -p "Enter your secondary database user: " SECONDARY_DB_USER
#read -sp "Enter your secondary database password: " SECONDARY_DB_PASSWORD
read -p "Enter your primary database user: " PRIMARY_DB_USER
read -sp "Enter your primary database password: " PRIMARY_DB_PASSWORD
PRIMARY_DB_IP="192.168.50.22"
SECONDARY_DB_IP="192.168.50.25"
INCLUDE_DATABASE_NAME="test123"
PRIMARY_DB_LOG_FILE="mysql-bin.000034"
PRIMARY_DB_LOG_POS=686 

# Check if required variables are set
if [[ -z "$PRIMARY_DB_IP" || -z "$PRIMARY_DB_USER" || -z "$INCLUDE_DATABASE_NAME" ]]; then
    echo "ERROR: One or more required variables (PRIMARY_DB_IP, PRIMARY_DB_USER, INCLUDE_DATABASE_NAME, SECONDARY_DB_IP, SECONDARY_DB_USER) are not set. Please set all required variables and try again."
    exit 1
fi

# Configure MySQL replication settings
sudo sed -i '/^server-id/d; /^log_bin/d; /^binlog_do_db/d' /etc/mysql/mysql.conf.d/mysqld.cnf
sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf <<EOF
server-id = 2
log_bin = /var/log/mysql/mysql-bin.log
binlog_do_db = $INCLUDE_DATABASE_NAME
relay-log = /var/log/mysql/mysql-relay-bin.log
EOF

# Restart MySQL service
sudo systemctl restart mysql || { echo "Failed to restart MySQL service"; exit 1; }

# Connect to MySQL on secondary_db and stop slave
sudo mysql -e "STOP SLAVE;"

# Connect to MySQL on secondary_db and reset slave
sudo mysql -e "RESET SLAVE ALL;"

# Connect to MySQL on secondary_db and configure slave
sudo mysql -e "CHANGE MASTER TO MASTER_HOST='$PRIMARY_DB_IP', MASTER_USER='$PRIMARY_DB_USER', MASTER_PASSWORD='$PRIMARY_DB_PASSWORD', MASTER_LOG_FILE='$PRIMARY_DB_LOG_FILE', MASTER_LOG_POS=$PRIMARY_DB_LOG_POS;"

# Connect to MySQL on secondary_db and start slave
sudo mysql -e "START SLAVE;"

# Show slave status and exit
sudo mysql -e "SHOW SLAVE STATUS\G;"

echo "Secondary database setup for replication completed successfully."
