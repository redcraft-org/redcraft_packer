#!/bin/bash

set -e

echo "Installing dependencies"
wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list
apt-get update

apt-get install -y apache2 php7.4 php7.4-fpm php7.4-xml php7.4-gd php7.4-opcache php7.4-mbstring php7.4-mysql mariadb-client supervisor

echo "Creating RedCraft directories"
rm -r /var/www/*
mkdir -p /var/www/redcraft-website/public /var/www/redcraft-website/storage/logs
chown www-data:www-data -R /var/www/redcraft-website

echo "Configuration of apache2"
rm /etc/apache2/sites-enabled/* || true
rm /etc/apache2/sites-available/* || true
cp /tmp/000-redcraft.conf /etc/apache2/sites-available/000-redcraft.conf
a2ensite 000-redcraft.conf
a2enmod proxy_fcgi
a2enmod rewrite
apachectl restart

echo "Testing FPM"
echo "<?php phpinfo(); ?>" | tee /var/www/redcraft-website/public/test.php
curl localhost/test.php | grep "FPM/FastCGI"
rm /var/www/redcraft-website/public/test.php

echo "Installing composer"
cd /tmp
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

echo "Setting up Laravel scheduler"
echo "* * * * * www-data cd /var/log/redcraft-website && php artisan schedule:run >> /dev/null 2>&1" | tee /etc/cron.d/laravel-scheduler

echo "Setting up Laravel worker"
cp /tmp/redcraft-worker.conf /etc/supervisor/conf.d/redcraft-worker.conf
supervisorctl reread
supervisorctl update
supervisorctl start redcraft-worker:*

echo "Adding deploy key"
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDnbqa03ORbyH+mzvEsLs7MW7pA4ZDmYCsRhPsuoOak/KEGzN10fn4o40wfnKFOWON2/t6MGyqRU3oF7rGSawa/lyQStsX91eWqpYa8J5e2h3c6iYEFolrev1PEALhlGeww8EOSXX+3mEu4DAfaW/83YzsgUburA4nuyygiDpSxj6nKD+NW3ej/T2XBMCKThDAsuOdEG0X935p2I0TK4kgwIm5PxI1GqLHN6O+AdrSipQxwVpz/DD0SaPLlAclgnCBzxDCgugpoA5n4MtSQGZn1KNkh0seEaFNo7e/UQdXfHcnGy3Y3JxBSOT342RiJCFX+TgTH1k2hozt1FFm/q129 deploy_key" > /root/.ssh/authorized_keys
