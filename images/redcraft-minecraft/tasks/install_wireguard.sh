#!/bin/bash

set -e

# Check if config file is empty or not
if [ -s "/tmp/wireguard.conf" ]
then
    # Install Wireguard
    apt-get install -y wireguard resolvconf
    cp /tmp/wireguard.conf /etc/wireguard/wg1.conf

    sudo systemctl enable wg-quick@wg1.service
    sudo systemctl daemon-reload
else
	echo "No Wireguard config found, setup skipped..."
fi