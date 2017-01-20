#!/bin/bash

# Copy mysql database if it doesn't exist
if [ ! -d /config/mysql/mysql ]; then
  echo "moving mysql to config folder"
  cp -a /var/lib/mysql /config/
else
  echo "using existing mysql database"
fi

echo "creating symbolink links"
rm -r /var/lib/mysql
ln -s /config/mysql /var/lib/mysql
chown -R mysql:mysql /var/lib/mysql

# Create any missing folders. Ignore STDERR if they are already mounted.
sudo -u www-data mkdir /var/cache/zoneminder/events \
  /var/cache/zoneminder/images \
  /var/cache/zoneminder/temp 2>/dev/null

#Get docker env timezone and set system timezone
export DEBCONF_NONINTERACTIVE_SEEN=true DEBIAN_FRONTEND=noninteractive
echo "setting the correct timezone : $TZ"
echo $TZ > /etc/timezone
ln -fs /usr/share/zoneinfo/$TZ /etc/localtime
dpkg-reconfigure tzdata
sed -i "s|^;date.timezone =.*$|date.timezone = ${TZ}|" /etc/php/7.0/apache2/php.ini

#fix memory issue
echo "setting shared memory : $SHMEM of $MEM"
umount /dev/shm
mount -t tmpfs -o rw,nosuid,nodev,noexec,relatime,size=${SHMEM} tmpfs /dev/shm

echo "starting services"
service mysql start
service apache2 start
service zoneminder start

