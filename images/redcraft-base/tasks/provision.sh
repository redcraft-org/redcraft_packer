#!/bin/bash

set -e

apt-get update

apt-get install -y htop python3 tmux byobu git jq apt-transport-https ca-certificates wget dirmngr gnupg software-properties-common

wget -qO - https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | apt-key add -

add-apt-repository --yes https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/

apt-get update

apt-get install -y adoptopenjdk-8-hotspot

for user in /tmp/users/*.json; do
    username=$(cat $user | jq -r '.username')
    hashed_password=$(cat $user | jq -r '.password_hash')
    ssh_public_key=$(cat $user | jq -r '.public_key')

    useradd -m -p $hashed_password -s /bin/bash $username
    mkdir -p /home/$username/.ssh
    echo $ssh_public_key > /home/$username/.ssh/authorized_keys
    chown -R $username:$username /home/$username/.ssh/
    chmod 700 -R /home/$username/.ssh/
    chmod 600 /home/$username/.ssh/authorized_keys
    usermod -a -G sudo $username
    cp /tmp/bashrc /home/$username/.bashrc
    chmod +x /home/$username/.bashrc
    chown $username:$username /tmp/bashrc /home/$username/.bashrc
    echo "Added user $username"
done

mv /tmp/bashrc /root/.bashrc
chmod +x /root/.bashrc

mv /tmp/motd /etc/motd.head

sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config

touch /var/lib/cloud/instance/locale-check.skip

apt-get upgrade -y

apt-get autoremove -y
