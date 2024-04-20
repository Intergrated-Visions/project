#!/bin/bash

# Check if Keepalived is installed
if ! command -v keepalived &>/dev/null; then
    # Install Keepalived
    echo "Installing Keepalived..."
    sudo apt update
    sudo apt install -y keepalived
    echo "Keepalived installed."
fi

# Create keepalived.conf file
keepalived_conf="/etc/keepalived/keepalived.conf"

# Create or overwrite keepalived.conf file with the specified content
echo "Creating $keepalived_conf file..."
sudo bash -c "cat > $keepalived_conf" <<EOF
vrrp_instance VI_1 {
    state BACKUP                                # Set the state of the instance to BACKUP on this server
    interface ens33                            # Specify the network interface to bind
    virtual_router_id 51                        # Unique ID for this virtual router instance
    priority 90                                 # Lower priority than the MASTER server
    advert_int 1                                # Advertisement interval in seconds
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        192.168.50.203/24 dev ens33             # Virtual IP address and subnet mask
    }
}
EOF
echo "$keepalived_conf file created."

# Enable and start Keepalived service
echo "Enabling and starting Keepalived service..."
sudo systemctl enable keepalived
sudo systemctl start keepalived

# Display status of Keepalived service
echo "Keepalived service status:"
sudo systemctl status keepalived

# Display Keepalived logs
echo "Keepalived logs:"
sudo journalctl -u keepalived
