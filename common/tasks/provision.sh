#!/bin/bash

set -e

# Update dependencies
apt-get update
apt-get upgrade -y --option=Dpkg::Options::=--force-confdef

# Install Java deps
apt-get install -y apt-transport-https ca-certificates wget software-properties-common gnupg2
wget -qO - https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | apt-key add -
add-apt-repository --yes https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/
apt-get update

# Install packages
apt-get install -y zip unzip htop python3 python3-venv python3-dev python3-pip tmux byobu git jq adoptopenjdk-8-hotspot dirmngr gnupg multitail tree iotop cowsay sl iftop dnsutils traceroute default-libmysqlclient-dev mariadb-client build-essential

# Setup user accounts
for user in /tmp/users/*.json; do
    username=$(cat $user | jq -r '.username')
    hashed_password=$(cat $user | jq -r '.password_hash')
    ssh_public_key=$(cat $user | jq -r '.public_key')

    useradd -m -p $hashed_password -s /bin/bash $username
    mkdir -p /home/$username/.ssh
    echo "$ssh_public_key" > /home/$username/.ssh/authorized_keys
    chown -R $username:$username /home/$username/.ssh/
    chmod 700 -R /home/$username/.ssh/
    chmod 600 /home/$username/.ssh/authorized_keys
    usermod -a -G sudo $username
    if [[ -f "/tmp/users/$username.bashrc" ]]; then
        cp "/tmp/users/$username.bashrc" /home/$username/.bashrc
        chmod +x /home/$username/.bashrc
        chown $username:$username /home/$username/.bashrc
    fi
    echo "Added user $username"
done

# Setup motd
mv /tmp/motd.head /etc/motd.head
sed -i '/Documentation:/d' /etc/update-motd.d/50-scw
sed -i '/Community:/d' /etc/update-motd.d/50-scw
sed -i '/Image source:/,+1 d' /etc/update-motd.d/50-scw

# Remove SSH password authentication to enforce use of keys
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config

# Fix locale error
touch /var/lib/cloud/instance/locale-check.skip

# Setup netdata
apt-get install -y autoconf autoconf-archive autogen automake cmake gcc libelf-dev libjson-c-dev libjudy-dev liblz4-dev libmnl-dev libssl-dev libtool libuv1-dev pkg-config uuid-dev
wget -O /tmp/kickstart.sh https://my-netdata.io/kickstart.sh
chmod +x /tmp/kickstart.sh
/tmp/kickstart.sh --dont-start-it --dont-wait

# Setup first boot scripts
mv /tmp/first_start_provisioning.sh /root/first_start_provisioning.sh
chmod +x /root/first_start_provisioning.sh
echo '@reboot root /root/first_start_provisioning.sh' > /etc/cron.d/first_start_provisioning

# Remove useless packages to reduce the image size
apt-get autoremove -y
