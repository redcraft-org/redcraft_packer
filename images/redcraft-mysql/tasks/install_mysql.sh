#!/bin/bash

set -e

apt-get install -y mariadb-server

systemctl enable mariadb

mkdir -p /mnt/mysql_data

echo "/dev/sda /mnt/mysql_data ext4 rw,_netdev" >> /etc/fstab

sed -i 's/\/var\/lib\/mysql/\/mnt\/mysql_data\/mysql/g' /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/mariadb.conf.d/50-server.cnf

cat << \EOF > /etc/rc.local
#!/bin/bash

# Make sure the storage partition is formatted

blkid -o value -s TYPE /dev/sda 2>&1 > /dev/null
if [ $? -ne 0 ]; then
    mkfs -t ext4 /dev/sda
    mount -a
    chown -R mysql:mysql /mnt/mysql_data
    chmod +rw /mnt/mysql_data
    sudo -u mysql mysql_install_db
    service mysql restart
    mysql -e "CREATE USER 'netdata'@'localhost';GRANT USAGE ON *.* TO 'netdata'@'localhost';FLUSH PRIVILEGES;"
    service netdata restart
fi
EOF

chmod +x /etc/rc.local

echo '' > /root/.ssh/authorized_keys