#!/bin/bash

# OS VERSION: CentOS 6.5 + Minimal
# ARCH: 32bit + 64bit

ZPX_VERSION=10.1.1

# Official ZPanel Automated Installation Script
# =============================================
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#

# ***************************************
# * Common installer functions *
# ***************************************

# Generates random passwords fro the 'zadmin' account as well as Postfix and MySQL root account.
passwordgen() {
         l=$1
           [ "$l" == "" ] && l=16
          tr -dc A-Za-z0-9 < /dev/urandom | head -c ${l} | xargs
}



# Set some installation defaults/auto assignments
tz=`cat /etc/sysconfig/clock`
fqdn=`/bin/hostname`
publicip=`wget -qO- http://api.zpanelcp.com/ip.txt`

# We need to disable SELinux...
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config > /dev/null 2>&1
setenforce 0 > /dev/null 2>&1

# We now stop IPTables to ensure a fully automated and pain free installation.
service iptables save > /dev/null 2>&1
service iptables stop > /dev/null 2>&1
chkconfig iptables off > /dev/null 2>&1

# Start log creation.
rpm -qa > /dev/null 2>&1

# Removal of conflicting packages and services prior to ZPX installation.
yum -y remove bind-chroot > /dev/null 2>&1

# Install some standard utility packages required by the installer and/or ZPX.
yum -y install sudo wget vim make zip unzip git chkconfig


# We now clone the ZPX software from GitHub
git clone https://github.com/bobsta63/zpanelx.git
cd zpanelx/
git checkout $ZPX_VERSION
mkdir ../zp_install_cache/
git checkout-index -a -f --prefix=../zp_install_cache/
cd ../zp_install_cache/

# Lets pull in all the required updates etc.
rpm --import https://fedoraproject.org/static/0608B895.txt
cp etc/build/config_packs/centos_6_3/yum.repos.d/epel.repo /etc/yum.repos.d/epel.repo

# We now update the server software packages.
yum -y update
yum -y upgrade

# Install required software and dependencies required by ZPanel.
yum -y install ld-linux.so.2 libbz2.so.1 libdb-4.7.so libgd.so.2 httpd php php-suhosin php-devel php-gd php-mbstring php-mcrypt php-intl php-imap php-mysql php-xml php-xmlrpc curl curl-devel perl-libwww-perl libxml2 libxml2-devel mysql-server zip webalizer gcc gcc-c++ httpd-devel at make mysql-devel bzip2-devel postfix postfix-perl-scripts bash-completion dovecot dovecot-mysql dovecot-pigeonhole mysql-server proftpd proftpd-mysql bind bind-utils bind-libs

# Generation of random passwords
password=`passwordgen`;
postfixpassword=`passwordgen`;
zadminNewPass=`passwordgen`;

# Set-up ZPanel directories and configure directory permissions as required.
mkdir /etc/zpanel
mkdir /etc/zpanel/configs
mkdir /etc/zpanel/panel
mkdir /etc/zpanel/docs
mkdir /var/zpanel
mkdir /var/zpanel/hostdata
mkdir /var/zpanel/hostdata/zadmin
mkdir /var/zpanel/hostdata/zadmin/public_html
mkdir /var/zpanel/logs
mkdir /var/zpanel/logs/proftpd
mkdir /var/zpanel/backups
mkdir /var/zpanel/temp
cp -R . /etc/zpanel/panel/
chmod -R 777 /etc/zpanel/
chmod -R 777 /var/zpanel/
chmod -R 770 /var/zpanel/hostdata/
chown -R apache:apache /var/zpanel/hostdata/
chmod 644 /etc/zpanel/panel/etc/apps/phpmyadmin/config.inc.php
ln -s /etc/zpanel/panel/bin/zppy /usr/bin/zppy
ln -s /etc/zpanel/panel/bin/setso /usr/bin/setso
ln -s /etc/zpanel/panel/bin/setzadmin /usr/bin/setzadmin
chmod +x /etc/zpanel/panel/bin/zppy
chmod +x /etc/zpanel/panel/bin/setso
cp -R /etc/zpanel/panel/etc/build/config_packs/centos_6_3/. /etc/zpanel/configs/
sed -i "s|YOUR_ROOT_MYSQL_PASSWORD|$password|" /etc/zpanel/panel/cnf/db.php
cc -o /etc/zpanel/panel/bin/zsudo /etc/zpanel/configs/bin/zsudo.c
sudo chown root /etc/zpanel/panel/bin/zsudo
chmod +s /etc/zpanel/panel/bin/zsudo

# MySQL specific installation tasks...
service mysqld start
mysqladmin -u root password "$password"
mysql -u root -p$password -e "DELETE FROM mysql.user WHERE User='root' AND Host != 'localhost'";
mysql -u root -p$password -e "DELETE FROM mysql.user WHERE User=''";
mysql -u root -p$password -e "DROP DATABASE test";
mysql -u root -p$password -e "CREATE SCHEMA zpanel_roundcube";
cat /etc/zpanel/configs/zpanelx-install/sql/*.sql | mysql -u root -p$password
mysql -u root -p$password -e "UPDATE mysql.user SET Password=PASSWORD('$postfixpassword') WHERE User='postfix' AND Host='localhost';"; 
mysql -u root -p$password -e "FLUSH PRIVILEGES";
sed -i "/symbolic-links=/a \secure-file-priv=/var/tmp" /etc/my.cnf

# Set some ZPanel custom configuration settings (using. setso and setzadmin)
/etc/zpanel/panel/bin/setzadmin --set "$zadminNewPass";
/etc/zpanel/panel/bin/setso --set zpanel_domain $fqdn 
/etc/zpanel/panel/bin/setso --set server_ip $publicip
/etc/zpanel/panel/bin/setso --set apache_changed "true"

# We'll store the passwords so that users can review them later if required.
touch /root/passwords.txt
echo "zadmin Password: $zadminNewPass" >> /root/passwords.txt
echo "MySQL Root Password: $password" >> /root/passwords.txt
echo "MySQL Postfix Password: $postfixpassword" >> /root/passwords.txt
echo "IP Address: $publicip" >> /root/passwords.txt
echo "Panel Domain: $fqdn" >> /root/passwords.txt

# Postfix specific installation tasks...
sed -i "s|;date.timezone =|date.timezone = $tz|" /etc/php.ini
sed -i "s|;upload_tmp_dir =|upload_tmp_dir = /var/zpanel/temp/|" /etc/php.ini
mkdir /var/zpanel/vmail
chmod -R 770 /var/zpanel/vmail
useradd -r -u 101 -g mail -d /var/zpanel/vmail -s /sbin/nologin -c "Virtual mailbox" vmail
chown -R vmail:mail /var/zpanel/vmail
mkdir -p /var/spool/vacation
useradd -r -d /var/spool/vacation -s /sbin/nologin -c "Virtual vacation" vacation
chmod -R 770 /var/spool/vacation
ln -s /etc/zpanel/configs/postfix/vacation.pl /var/spool/vacation/vacation.pl
postmap /etc/postfix/transport
chown -R vacation:vacation /var/spool/vacation
if ! grep -q "127.0.0.1 autoreply.$fqdn" /etc/hosts; then echo "127.0.0.1 autoreply.$fqdn" >> /etc/hosts; fi > /dev/null 2>&1
sed -i "s|myhostname = control.yourdomain.com|myhostname = $fqdn|" /etc/zpanel/configs/postfix/main.cf
sed -i "s|mydomain = control.yourdomain.com|mydomain = $fqdn|" /etc/zpanel/configs/postfix/main.cf
rm -rf /etc/postfix/main.cf /etc/postfix/master.cf
ln -s /etc/zpanel/configs/postfix/master.cf /etc/postfix/master.cf
ln -s /etc/zpanel/configs/postfix/main.cf /etc/postfix/main.cf
sed -i "s|password \= postfix|password \= $postfixpassword|" /etc/zpanel/configs/postfix/mysql-relay_domains_maps.cf
sed -i "s|password \= postfix|password \= $postfixpassword|" /etc/zpanel/configs/postfix/mysql-virtual_alias_maps.cf
sed -i "s|password \= postfix|password \= $postfixpassword|" /etc/zpanel/configs/postfix/mysql-virtual_domains_maps.cf
sed -i "s|password \= postfix|password \= $postfixpassword|" /etc/zpanel/configs/postfix/mysql-virtual_mailbox_limit_maps.cf
sed -i "s|password \= postfix|password \= $postfixpassword|" /etc/zpanel/configs/postfix/mysql-virtual_mailbox_maps.cf
sed -i "s|\$db_password \= 'postfix';|\$db_password \= '$postfixpassword';|" /etc/zpanel/configs/postfix/vacation.conf





# Dovecot specific installation tasks (includes Sieve)
mkdir /var/zpanel/sieve
chown -R vmail:mail /var/zpanel/sieve
mkdir /var/lib/dovecot/sieve/
touch /var/lib/dovecot/sieve/default.sieve
ln -s /etc/zpanel/configs/dovecot2/globalfilter.sieve /var/zpanel/sieve/globalfilter.sieve
rm -rf /etc/dovecot/dovecot.conf
ln -s /etc/zpanel/configs/dovecot2/dovecot.conf /etc/dovecot/dovecot.conf
sed -i "s|postmaster_address = postmaster@your-domain.tld|postmaster_address = postmaster@$fqdn|" /etc/dovecot/dovecot.conf
sed -i "s|password=postfix|password=$postfixpassword|" /etc/zpanel/configs/dovecot2/dovecot-dict-quota.conf
sed -i "s|password=postfix|password=$postfixpassword|" /etc/zpanel/configs/dovecot2/dovecot-mysql.conf
touch /var/log/dovecot.log
touch /var/log/dovecot-info.log
touch /var/log/dovecot-debug.log
chown vmail:mail /var/log/dovecot*
chmod 660 /var/log/dovecot*

# ProFTPD specific installation tasks
groupadd -g 2001 ftpgroup
useradd -u 2001 -s /bin/false -d /bin/null -c "proftpd user" -g ftpgroup ftpuser
sed -i "s|zpanel_proftpd@localhost root z|zpanel_proftpd@localhost root $password|" /etc/zpanel/configs/proftpd/proftpd-mysql.conf
rm -rf /etc/proftpd.conf
touch /etc/proftpd.conf
if ! grep -q "include /etc/zpanel/configs/proftpd/proftpd-mysql.conf" /etc/proftpd.conf; then echo "include /etc/zpanel/configs/proftpd/proftpd-mysql.conf" >> /etc/proftpd.conf; fi > /dev/null 2>&1
chmod -R 644 /var/zpanel/logs/proftpd
serverhost=`hostname`

# Apache HTTPD specific installation tasks...
if ! grep -q "Include /etc/zpanel/configs/apache/httpd.conf" /etc/httpd/conf/httpd.conf; then echo "Include /etc/zpanel/configs/apache/httpd.conf" >> /etc/httpd/conf/httpd.conf; fi > /dev/null 2>&1
if ! grep -q "127.0.0.1 "$fqdn /etc/hosts; then echo "127.0.0.1 "$fqdn >> /etc/hosts; fi > /dev/null 2>&1
if ! grep -q "apache ALL=NOPASSWD: /etc/zpanel/panel/bin/zsudo" /etc/sudoers; then echo "apache ALL=NOPASSWD: /etc/zpanel/panel/bin/zsudo" >> /etc/sudoers; fi > /dev/null 2>&1
sed -i 's|DocumentRoot "/var/www/html"|DocumentRoot "/etc/zpanel/panel"|' /etc/httpd/conf/httpd.conf
chown -R apache:apache /var/zpanel/temp/

# PHP specific installation tasks...
sed -i "s|;date.timezone =|date.timezone = $tz|" /etc/php.ini
sed -i "s|;upload_tmp_dir =|upload_tmp_dir = /var/zpanel/temp/|" /etc/php.ini

# Permissions fix for Apache and ProFTPD (to enable them to play nicely together!)
if ! grep -q "umask 002" /etc/sysconfig/httpd; then echo "umask 002" >> /etc/sysconfig/httpd; fi > /dev/null 2>&1
if ! grep -q "127.0.0.1 $serverhost" /etc/hosts; then echo "127.0.0.1 $serverhost" >> /etc/hosts; fi > /dev/null 2>&1
usermod -a -G apache ftpuser
usermod -a -G ftpgroup apache

# BIND specific installation tasks...
chmod -R 777 /etc/zpanel/configs/bind/zones/
rm -rf /etc/named.conf /etc/rndc.conf /etc/rndc.key
rndc-confgen -a > /dev/null 2>&1
ln -s /etc/zpanel/configs/bind/named.conf /etc/named.conf > /dev/null 2>&1
ln -s /etc/zpanel/configs/bind/rndc.conf /etc/rndc.conf > /dev/null 2>&1
cat /etc/rndc.key /etc/named.conf | tee named.conf > /dev/null 2>&1
cat /etc/rndc.key /etc/rndc.conf | tee named.conf > /dev/null 2>&1

# CRON specific installation tasks...
mkdir -p /var/spool/cron/
mkdir -p /etc/cron.d/
touch /var/spool/cron/apache
touch /etc/cron.d/apache
crontab -u apache /var/spool/cron/apache
cp /etc/zpanel/configs/cron/zdaemon /etc/cron.d/zdaemon
chmod -R 644 /var/spool/cron/
chmod -R 644 /etc/cron.d/
chown -R apache:apache /var/spool/cron/

# Webalizer specific installation tasks...
rm -rf /etc/webalizer.conf

# Roundcube specific installation tasks...
sed -i "s|YOUR_MYSQL_ROOT_PASSWORD|$password|" /etc/zpanel/configs/roundcube/db.inc.php
sed -i "s|#||" /etc/zpanel/configs/roundcube/db.inc.php
rm -rf /etc/zpanel/panel/etc/apps/webmail/config/main.inc.php
ln -s /etc/zpanel/configs/roundcube/main.inc.php /etc/zpanel/panel/etc/apps/webmail/config/main.inc.php
ln -s /etc/zpanel/configs/roundcube/config.inc.php /etc/zpanel/panel/etc/apps/webmail/plugins/managesieve/config.inc.php
ln -s /etc/zpanel/configs/roundcube/db.inc.php /etc/zpanel/panel/etc/apps/webmail/config/db.inc.php

# Enable system services and start/restart them as required.
chkconfig httpd on
chkconfig postfix on
chkconfig dovecot on
chkconfig crond on
chkconfig mysqld on
chkconfig named on
chkconfig proftpd on
service httpd start
service postfix restart
service dovecot start
service crond reload
service mysqld start
service named start
service proftpd start
service atd start
php -q /etc/zpanel/panel/bin/daemon.php > /dev/null 2>&1
service httpd restart
service postfix restart
service dovecot restart
service crond restart
service mysqld restart
service named restart
service proftpd restart
service atd restart


# We'll now remove the temporary install cache.
cd ../ > /dev/null 2>&1
rm -rf zp_install_cache/ zpanelx/

echo "OK"
exit
