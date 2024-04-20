#!/bin/bash


# Create keepalived.conf file
keepalived_conf="/etc/keepalived/keepalived.conf"

# Create or overwrite keepalived.conf file with the specified content
echo "Creating $keepalived_conf file..."
sudo bash -c "cat > $keepalived_conf" <<EOF
vrrp_script chk_apache {
    script "/etc/keepalived/check_apache.sh"   # Path to the health check script
    interval 2                                  # Check interval in seconds
    fall 2                                      # Number of failed checks before considering the server down
    rise 2                                      # Number of successful checks before considering the server up
}

vrrp_instance VI_1 {
    state MASTER                                # Set the state of the instance to MASTER on one server and BACKUP on the other
    interface ens33                           # Specify the network interface to bind
    virtual_router_id 51                        # Unique ID for this virtual router instance
    priority 100                                # Priority for this router in case of multiple masters
    advert_int 1                                # Advertisement interval in seconds
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        192.168.50.203/24 dev ens33             # Virtual IP address and subnet mask
    }
    track_script {
        chk_apache                              # Track the health check script
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
