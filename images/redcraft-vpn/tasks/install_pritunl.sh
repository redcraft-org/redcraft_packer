#!/bin/bash

set -e

echo "deb http://repo.mongodb.org/apt/debian buster/mongodb-org/4.2 main" > /etc/apt/sources.list.d/mongodb-org-4.2.list

echo "deb http://repo.pritunl.com/stable/apt buster main" > /etc/apt/sources.list.d/pritunl.list

apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv E162F504A20CDF15827F718D4B7C549A058F8B6B
apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 7568D9BB55FF9E5287D586017AE645C0CF8E292A
apt-get update
sleep 1
apt-get --assume-yes install pritunl mongodb-org dirmngr
systemctl enable mongod pritunl

echo '' > /root/.ssh/authorized_keys