#!/bin/bash

set -e

# Check if config file is empty or not
if [ -s "/tmp/openvpn_config" ]
then
    # Install OpenVPN
    apt-get install openvpn
    sed -i 's/#AUTOSTART="all"/AUTOSTART="all"/g' /etc/default/openvpn
    cp /tmp/openvpn_config /etc/openvpn/client.conf
    systemctl enable openvpn@client.service
    systemctl daemon-reload
    systemctl start openvpn@client.service
else
	echo "No OpenVPN config found, setup skipped..."
fi