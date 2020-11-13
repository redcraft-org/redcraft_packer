#!/bin/bash

set -e

apt-get install -y redis-server

systemctl enable redis-server

sed -i 's/bind 127.0.0.1 ::1/#bind 127.0.0.1 ::1/g' /etc/redis/redis.conf
sed -i 's/protected-mode yes/protected-mode no/g' /etc/redis/redis.conf
