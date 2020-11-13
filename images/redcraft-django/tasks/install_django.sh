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

# Install authbind to use port 80
apt-get install -y authbind
touch /etc/authbind/byport/80
chmod 500 /etc/authbind/byport/80
chown gunicorn /etc/authbind/byport/80

# Start gunicorn at boot
mv /tmp/gunicorn.service /etc/systemd/system/gunicorn.service
systemctl daemon-reload
systemctl enable gunicorn

echo 'ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQBIGAs5k7tKWrvD3Y77NAl/c/oRLv9ldOx0ZIM2bME+sEqsvcmwWY9KH+3ZhxqRLjoAmc5XGgEbmk4JmNdYM/MEMgi7jUeUF4sMteESLW4tM9j2XarDmxmsV77cUNSAz2mW3puHSzh+c24Hj6r1slv/r/S8mRhaZOsS6d2PLwyARdvqitS5OLsM/FfJSpV+hJnEDmcsBXfhFgC/ZmZnMzkxjHqnA+Zu9jEYok8Iduj5RVH4Fnmoy4+ioM1/DK+c79WL2DFcsMD1q53xzZpHJ2ihdzhTsuwQ8ovksS1xbuWo5azXgms6M/R24k3SW8yMYKxjoOK0AvrWX+GaPpf/hCi/ redcraft_website_deploy_key' > /root/.ssh/authorized_keys
