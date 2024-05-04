#!/bin/bash

# Define variables
# Prompt user to enter values for variables
read -p "Enter your secondary database user: " SECONDARY_DB_USER
read -sp "Enter your secondary database password: " SECONDARY_DB_PASSWORD
read -p "Enter your primary database user: " PRIMARY_DB_USER
read -sp "Enter your primary database password: " PRIMARY_DB_PASSWORD
PRIMARY_DB_IP="192.168.50.22"
SECONDARY_DB_IP="192.168.50.25"
INCLUDE_DATABASE_NAME="test123"


# Check if required variables are set
if [[ -z "$PRIMARY_DB_IP" || -z "$PRIMARY_DB_USER" || -z "$INCLUDE_DATABASE_NAME" || -z "$SECONDARY_DB_IP" || -z "$SECONDARY_DB_USER" ]]; then
    echo "ERROR: One or more required variables (PRIMARY_DB_IP, PRIMARY_DB_USER, INCLUDE_DATABASE_NAME, SECONDARY_DB_IP, SECONDARY_DB_USER) are not set. Please set all required variables and try again."
    exit 1
fi

# Configure firewall to allow MySQL traffic
sudo ufw allow from "$SECONDARY_DB_IP" to any port 3306

# Allow MySQL to listen on all interfaces
sudo sed -i 's/^bind-address\s*=.*$/bind-address = 192.168.50.22/' /etc/mysql/mysql.conf.d/mysqld.cnf

# Modify MySQL configuration file for primary_db server
sudo sed -i '/^server-id/d; /^log_bin/d; /^binlog_do_db/d' /etc/mysql/mysql.conf.d/mysqld.cnf
sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf <<EOF
server-id = 1
log_bin = /var/log/mysql/mysql-bin.log
binlog_do_db = $INCLUDE_DATABASE_NAME
EOF

# Restart MySQL service
sudo systemctl restart mysql

# Connect to MySQL on primary_db and create replication user
sudo mysql -e "CREATE USER '$SECONDARY_DB_USER'@'$SECONDARY_DB_IP' IDENTIFIED WITH mysql_native_password BY '$SECONDARY_DB_PASSWORD'; GRANT REPLICATION SLAVE ON *.* TO '$SECONDARY_DB_USER'@'$SECONDARY_DB_IP';"


# Check if user is created and permissions are granted
echo "Checking user and permissions..."
sudo mysql -e "SELECT user, host FROM mysql.user WHERE user = '$SECONDARY_DB_USER'; SHOW GRANTS FOR '$SECONDARY_DB_USER'@'$SECONDARY_DB_IP';"

# Get primary_db status
PRIMARY_DB_STATUS="$(sudo mysql -e 'SHOW MASTER STATUS;' --silent)"

# Check if result is obtained
if [ -z "$PRIMARY_DB_STATUS" ]; then
    echo "ERROR: Unable to retrieve master status."
    exit 1
fi

echo "Master status obtained successfully:"
echo "$PRIMARY_DB_STATUS"

# Extract primary_db log file and position
PRIMARY_DB_LOG_FILE=$(echo "$PRIMARY_DB_STATUS" | awk '{print $1}')
PRIMARY_DB_LOG_POS=$(echo "$PRIMARY_DB_STATUS" | awk '{print $2}')

echo "Primary_db setup completed successfully."

# Unset password variables at the end of the script
unset SECONDARY_DB_PASSWORD
unset PRIMARY_DB_PASSWORD
