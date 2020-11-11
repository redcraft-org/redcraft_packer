#!/bin/bash

set -e

# Add gunicorn user
adduser --system --no-create-home --group gunicorn
mkdir /opt/redcraft_website
chown -R gunicorn:gunicorn /opt/redcraft_website

# Install redcraft_website
cd /opt
git clone https://github.com/redcraft-org/redcraft_website.git
cd /opt/redcraft_website
python3 -m venv env
source env/bin/activate
pip install gunicorn
pip install -r requirements.txt

# Config permissions and directories
mkdir -p /var/log/redcraft
chown -R gunicorn:gunicorn /opt/redcraft_website
chown -R gunicorn:gunicorn /var/log/redcraft

# Start gunicorn at boot
mv /tmp/gunicorn.service /etc/systemd/system/gunicorn.service
systemctl daemon-reload
systemctl enable gunicorn

echo '' > /root/.ssh/authorized_keys
