#!/bin/bash

set -e

apt-get update
sleep 1
apt-get install -y mariadb-server

systemctl enable mariadb
systemctl start mariadb

mysql < /tmp/create_mysql_accounts.sql

echo '' > /root/.ssh/authorized_keys