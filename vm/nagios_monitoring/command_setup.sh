#!/bin/bash

# Define the location to search and the commands to add
search_location="/usr/local/nagios/etc/objects/commands.cfg"
commands_to_add="
define command {
    command_name    check_nrpe
    command_line    /usr/lib/nagios/plugins/check_nrpe -H \$HOSTADDRESS\$ -c \$ARG1\$
}

define command {
    command_name    check_load
    command_line    /usr/lib/nagios/plugins/check_nrpe -H \$HOSTADDRESS\$ -c check_load
}
"

# Check if the search location exists
if [ ! -f "$search_location" ]; then
    echo "Error: $search_location not found."
    exit 1
fi

# Use awk to modify content and print to standard output
awk -v cmd="$commands_to_add" '/check_nt/ {print; print cmd; next} 1' "$search_location"

echo "Commands added after check_nt in $search_location."
