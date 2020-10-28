#!/bin/bash

set -e

# Add minecraft user
adduser --system --no-create-home --group minecraft

# Install rcsm
URL=`curl -s https://api.github.com/repos/redcraft-org/redcraft_server_management/releases/latest | grep "amd64" | cut -d : -f 2,3 | tr -d \" | tail -n 1`
wget -O /usr/bin/rcsm $URL
chmod +x /usr/bin/rcsm

# Config rcsm
mv /tmp/rcsm_config /etc/rcsm_config

# Start rcsm at boot
mv /tmp/rcsm.service /etc/systemd/system/rcsm.service
systemctl daemon-reload
systemctl enable rcsm

# Setup disk
mkdir -p /mnt/minecraft

echo "/dev/sda /mnt/minecraft ext4 rw,_netdev" >> /etc/fstab

cat << \EOF > /etc/rc.local
#!/bin/bash

# Make sure the storage partition is formatted

blkid -o value -s TYPE /dev/sda 2>&1 > /dev/null
if [ $? -ne 0 ]; then
    mkfs -t ext4 /dev/sda
    mount -a
    chown -R minecraft:minecraft /mnt/minecraft
    chmod +rw /mnt/minecraft
fi
EOF

chmod +x /etc/rc.local

echo '' > /root/.ssh/authorized_keys