#!/bin/bash

set -e

apt-get update

apt-get upgrade -y

apt-get install -y htop python3 tmux byobu git jq

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
    echo "Added user $username"
done

mv /tmp/motd /etc/motd.head

mv /tmp/sshd_config /etc/ssh/sshd_config

apt-get autoremove -y
