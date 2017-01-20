#!/bin/bash

# Add Zoneminder official repo
add-apt-repository -y ppa:iconnor/zoneminder && \

# Update
apt-get update && \
apt-get upgrade -y -o Dpkg::Options::="--force-confold" && \
apt-get dist-upgrade -y && \

# Prefer mariadb over Oracle mysql
apt-get install -y mariadb-server && \
rm /etc/mysql/my.cnf && \
cp /etc/mysql/mariadb.conf.d/50-server.cnf /etc/mysql/my.cnf && \

# Install and configure zoneminder
# I install a bunch of VLC packages need for the libvlc stream, but they have
# a stack of dependencies (xserver, gcc) that add a few hundred MBs.
apt-get install -y \
  zoneminder 
  php-gd 
  sudo 
  vlc libvlc-dev libvlccore-dev && \
chmod 740 /etc/zm/zm.conf && \
chown root:www-data /etc/zm/zm.conf && \
adduser www-data video && \
a2enmod cgi && \
a2enconf zoneminder && \
a2enmod rewrite && \
chown -R www-data:www-data /usr/share/zoneminder/ && \
echo "
<Directory /usr/share>
        AllowOverride All
        Require all granted
</Directory>

<Directory /var/www/>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
</Directory>
" >> /etc/apache2/apache2.conf && \

# Add delay to zm startup. Needed??
sed -i "s|^start() {$|start() {\n        sleep 15|" /etc/init.d/zoneminder && \

# Configure mysql
service mysql start && \
mysql -uroot < /usr/share/zoneminder/db/zm_create.sql && \
mysql -uroot -e "grant select,insert,update,delete,create,alter,index,lock tables on zm.* to 'zmuser'@localhost identified by 'zmpass';" && \
mysql -sfu root < "/root/mysql_secure_installation.sql" && \
service mysql stop && \

# Cleanup
apt-get clean && \
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \

chmod +x /etc/my_init.d/firstrun.sh && \

# Create Directory for data
mkdir -p /config/mysql

# Prevent autostart. These are started in firstrun.sh.
update-rc.d -f apache2 remove && \
update-rc.d -f mysql remove && \
update-rc.d -f zoneminder remove

