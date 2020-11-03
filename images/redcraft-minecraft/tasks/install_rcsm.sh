#!/bin/bash

set -e

# Add minecraft user
adduser --system --no-create-home --group minecraft
mkdir /opt/rcsm
chown -R minecraft:minecraft /opt/rcsm

# Install rcsm
URL=`curl -s https://api.github.com/repos/redcraft-org/redcraft_server_management/releases/latest | grep "amd64" | cut -d : -f 2,3 | tr -d \" | tail -n 1`
wget -O /opt/rcsm/rcsm $URL
chmod +x /opt/rcsm/rcsm

# Config rcsm
mv /tmp/rcsm_config /opt/rcsm/rcsm_config
chown -R minecraft:minecraft /opt/rcsm

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
    mkdir /mnt/minecraft/servers
    chown -R minecraft:minecraft /mnt/minecraft
    chmod +rw /mnt/minecraft
fi
EOF

chmod +x /etc/rc.local

echo '' > /root/.ssh/authorized_keys