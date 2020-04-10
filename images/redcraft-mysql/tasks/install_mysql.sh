#!/bin/bash

set -e

apt-get install -y mariadb-server

systemctl enable mariadb

mkdir -p /mnt/mysql_data

echo "/dev/vdb /mnt/mysql_data ext4 rw" >> /etc/fstab

sed -i 's/\/var\/lib\/mysql/\/mnt\/mysql_data\/mysql/g' /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/mariadb.conf.d/50-server.cnf

echo '' > /root/.ssh/authorized_keys