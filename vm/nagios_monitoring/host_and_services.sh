-#!/bin/bash

# Array of remote host IPs and aliases
remote_hosts=(
    "192.168.x.12 SI-Dev-backend"
    "192.168.x.11 SI-Dev-dmz"
    "192.168.x.13 si-prod-backend"
    "192.168.x.14 si-prod-dmz"
    "192.168.x.16 si-prod-frontend"
    "192.168.x.15 si-test-backend"
    "192.168.x.17 si-test-dmz"
    "192.168.x.18 si-test-frontend"
    "192.168.x.19 si-developer"
    "192.168.x.3 si-developer"
    "192.168.x.26 si-prod-db-backup"
    "192.168.x.24 si-prod-frontend-backup"
    "192.168.x.7 SI-Dev-frontend"
)

# Loop through each remote host and create host/service definitions
for host_info in "${remote_hosts[@]}"
do
    host_ip=$(echo $host_info | cut -d ' ' -f 1)
    host_alias=$(echo $host_info | cut -d ' ' -f 2)

    # Define host with alias
    echo "define host {" >> /usr/local/nagios/etc/objects/hosts.cfg
    echo "    use         linux-server" >> /usr/local/nagios/etc/objects/hosts.cfg
    echo "    host_name   ${host_alias}" >> /usr/local/nagios/etc/objects/hosts.cfg
    echo "    alias       my-remote-host-${host_ip}" >> /usr/local/nagios/etc/objects/hosts.cfg
    echo "    address     ${host_ip}" >> /usr/local/nagios/etc/objects/hosts.cfg
    echo "}" >> /usr/local/nagios/etc/objects/hosts.cfg

    # Define service
    echo "define service {" >> /usr/local/nagios/etc/objects/services.cfg
    echo "    use                 generic-service" >> /usr/local/nagios/etc/objects/services.cfg
    echo "    host_name           ${host_alias}" >> /usr/local/nagios/etc/objects/services.cfg
    echo "    service_description CPU Load" >> /usr/local/nagios/etc/objects/services.cfg
    echo "    check_command       check_nrpe!check_load" >> /usr/local/nagios/etc/objects/services.cfg
    echo "}" >> /usr/local/nagios/etc/objects/services.cfg
done

# Restart Nagios for changes to take effect
sudo systemctl restart nagios
