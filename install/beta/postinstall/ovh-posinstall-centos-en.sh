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

# Set custom logging methods so we create a log file in the current working directory.
logfile=$$.log

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
tz="Europe/london"
fqdn=`/bin/hostname`
publicip=`wget -qO- http://api.zpanelcp.com/ip.txt`

# We need to disable SELinux...
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config > $logfile
setenforce 0 > $logfile

# We now stop IPTables to ensure a fully automated and pain free installation.
service iptables save > $logfile
service iptables stop > $logfile
chkconfig iptables off > $logfile

# Start log creation.
rpm -qa > $logfile

# Removal of conflicting packages and services prior to ZPX installation.
yum -y remove bind-chroot > $logfile

# Install some standard utility packages required by the installer and/or ZPX.
yum -y install sudo wget vim make zip unzip git chkconfig > $logfile


# We now clone the ZPX software from GitHub
git clone https://github.com/bobsta63/zpanelx.git > $logfile
cd zpanelx/ > $logfile
git checkout $ZPX_VERSION > $logfile
mkdir ../zp_install_cache/ > $logfile
git checkout-index -a -f --prefix=../zp_install_cache/ > $logfile
cd ../zp_install_cache/ > $logfile

# Lets pull in all the required updates etc.
#rpm --import https://fedoraproject.org/static/0608B895.txt > $logfile
#cp etc/build/config_packs/centos_6_3/yum.repos.d/epel.repo /etc/yum.repos.d/epel.repo > $logfile

# We now update the server software packages.
#yum -y update > $logfile
#yum -y upgrade > $logfile

# Install required software and dependencies required by ZPanel.
#yum -y install ld-linux.so.2 libbz2.so.1 libdb-4.7.so libgd.so.2 httpd php php-suhosin php-devel php-gd php-mbstring php-mcrypt php-intl php-imap php-mysql php-xml php-xmlrpc curl curl-devel perl-libwww-perl libxml2 libxml2-devel mysql-server zip webalizer gcc gcc-c++ httpd-devel at make mysql-devel bzip2-devel postfix postfix-perl-scripts bash-completion dovecot dovecot-mysql dovecot-pigeonhole mysql-server proftpd proftpd-mysql bind bind-utils bind-libs > $logfile

# Generation of random passwords
#password=`passwordgen`;
#postfixpassword=`passwordgen`;
#zadminNewPass=`passwordgen`;

# Set-up ZPanel directories and configure directory permissions as required.
#mkdir /etc/zpanel > $logfile
#mkdir /etc/zpanel/configs > $logfile
#mkdir /etc/zpanel/panel > $logfile
#mkdir /etc/zpanel/docs > $logfile
#mkdir /var/zpanel > $logfile
#mkdir /var/zpanel/hostdata > $logfile
#mkdir /var/zpanel/hostdata/zadmin > $logfile
#mkdir /var/zpanel/hostdata/zadmin/public_html > $logfile
#mkdir /var/zpanel/logs > $logfile
#mkdir /var/zpanel/logs/proftpd > $logfile
#mkdir /var/zpanel/backups > $logfile
#mkdir /var/zpanel/temp > $logfile
#cp -R . /etc/zpanel/panel/ > $logfile
#chmod -R 777 /etc/zpanel/ > $logfile
#chmod -R 777 /var/zpanel/ > $logfile
#chmod -R 770 /var/zpanel/hostdata/ > $logfile
#chown -R apache:apache /var/zpanel/hostdata/ > $logfile
#chmod 644 /etc/zpanel/panel/etc/apps/phpmyadmin/config.inc.php > $logfile
#ln -s /etc/zpanel/panel/bin/zppy /usr/bin/zppy > $logfile
#ln -s /etc/zpanel/panel/bin/setso /usr/bin/setso > $logfile
#ln -s /etc/zpanel/panel/bin/setzadmin /usr/bin/setzadmin > $logfile
#chmod +x /etc/zpanel/panel/bin/zppy > $logfile
#chmod +x /etc/zpanel/panel/bin/setso > $logfile
#cp -R /etc/zpanel/panel/etc/build/config_packs/centos_6_3/. /etc/zpanel/configs/ > $logfile
#sed -i "s|YOUR_ROOT_MYSQL_PASSWORD|$password|" /etc/zpanel/panel/cnf/db.php > $logfile
#cc -o /etc/zpanel/panel/bin/zsudo /etc/zpanel/configs/bin/zsudo.c > $logfile
#sudo chown root /etc/zpanel/panel/bin/zsudo > $logfile
#chmod +s /etc/zpanel/panel/bin/zsudo > $logfile

# MySQL specific installation tasks...
#service mysqld start > $logfile
#mysqladmin -u root password "$password" > $logfile
#mysql -u root -p$password -e "DELETE FROM mysql.user WHERE User='root' AND Host != 'localhost'"; > $logfile
#mysql -u root -p$password -e "DELETE FROM mysql.user WHERE User=''"; > $logfile
#mysql -u root -p$password -e "DROP DATABASE test"; > $logfile
#mysql -u root -p$password -e "CREATE SCHEMA zpanel_roundcube"; > $logfile
#cat /etc/zpanel/configs/zpanelx-install/sql/*.sql | mysql -u root -p$password > $logfile
#mysql -u root -p$password -e "UPDATE mysql.user SET Password=PASSWORD('$postfixpassword') WHERE User='postfix' AND Host='localhost';"; > $logfile
#mysql -u root -p$password -e "FLUSH PRIVILEGES"; > $logfile
#sed -i "/symbolic-links=/a \secure-file-priv=/var/tmp" /etc/my.cnf > $logfile

# Set some ZPanel custom configuration settings (using. setso and setzadmin)
#/etc/zpanel/panel/bin/setzadmin --set "$zadminNewPass"; > $logfile
#/etc/zpanel/panel/bin/setso --set zpanel_domain $fqdn > $logfile
#/etc/zpanel/panel/bin/setso --set server_ip $publicip > $logfile
#/etc/zpanel/panel/bin/setso --set apache_changed "true" > $logfile

# We'll store the passwords so that users can review them later if required.
#touch /root/passwords.txt > $logfile
#echo "zadmin Password: $zadminNewPass" >> /root/passwords.txt > $logfile
#echo "MySQL Root Password: $password" >> /root/passwords.txt > $logfile
#echo "MySQL Postfix Password: $postfixpassword" >> /root/passwords.txt > $logfile
#echo "IP Address: $publicip" >> /root/passwords.txt > $logfile
#echo "Panel Domain: $fqdn" >> /root/passwords.txt > $logfile

# Postfix specific installation tasks...
#sed -i "s|;date.timezone =|date.timezone = $tz|" /etc/php.ini > $logfile
#sed -i "s|;upload_tmp_dir =|upload_tmp_dir = /var/zpanel/temp/|" /etc/php.ini > $logfile
#mkdir /var/zpanel/vmail > $logfile
#chmod -R 770 /var/zpanel/vmail > $logfile
#useradd -r -u 101 -g mail -d /var/zpanel/vmail -s /sbin/nologin -c "Virtual mailbox" vmail > $logfile
#chown -R vmail:mail /var/zpanel/vmail > $logfile
#mkdir -p /var/spool/vacation > $logfile
#useradd -r -d /var/spool/vacation -s /sbin/nologin -c "Virtual vacation" vacation > $logfile
#chmod -R 770 /var/spool/vacation > $logfile
#ln -s /etc/zpanel/configs/postfix/vacation.pl /var/spool/vacation/vacation.pl > $logfile
#postmap /etc/postfix/transport > $logfile
#chown -R vacation:vacation /var/spool/vacation > $logfile
#if ! grep -q "127.0.0.1 autoreply.$fqdn" /etc/hosts; then echo "127.0.0.1 autoreply.$fqdn" >> /etc/hosts; fi > $logfile
#sed -i "s|myhostname = control.yourdomain.com|myhostname = $fqdn|" /etc/postfix/main.cf > $logfile
#sed -i "s|mydomain = control.yourdomain.com|mydomain = $fqdn|" /etc/postfix/main.cf > $logfile
#rm -rf /etc/postfix/main.cf /etc/postfix/master.cf > $logfile
#ln -s /etc/zpanel/configs/postfix/master.cf /etc/postfix/master.cf > $logfile
#ln -s /etc/zpanel/configs/postfix/main.cf /etc/postfix/main.cf > $logfile
#sed -i "s|password \= postfix|password \= $postfixpassword|" /etc/zpanel/configs/postfix/mysql-relay_domains_maps.cf > $logfile
#sed -i "s|password \= postfix|password \= $postfixpassword|" /etc/zpanel/configs/postfix/mysql-virtual_alias_maps.cf > $logfile
#sed -i "s|password \= postfix|password \= $postfixpassword|" /etc/zpanel/configs/postfix/mysql-virtual_domains_maps.cf > $logfile
#sed -i "s|password \= postfix|password \= $postfixpassword|" /etc/zpanel/configs/postfix/mysql-virtual_mailbox_limit_maps.cf > $logfile
#sed -i "s|password \= postfix|password \= $postfixpassword|" /etc/zpanel/configs/postfix/mysql-virtual_mailbox_maps.cf > $logfile
#sed -i "s|\$db_password \= 'postfix';|\$db_password \= '$postfixpassword';|" /etc/zpanel/configs/postfix/vacation.conf > $logfile

# Dovecot specific installation tasks (includes Sieve)
#mkdir /var/zpanel/sieve > $logfile
#chown -R vmail:mail /var/zpanel/sieve > $logfile
#mkdir /var/lib/dovecot/sieve/ > $logfile
#touch /var/lib/dovecot/sieve/default.sieve > $logfile
#ln -s /etc/zpanel/configs/dovecot2/globalfilter.sieve /var/zpanel/sieve/globalfilter.sieve > $logfile
#rm -rf /etc/dovecot/dovecot.conf > $logfile
#ln -s /etc/zpanel/configs/dovecot2/dovecot.conf /etc/dovecot/dovecot.conf > $logfile
#sed -i "s|postmaster_address = postmaster@your-domain.tld|postmaster_address = postmaster@$fqdn|" /etc/dovecot/dovecot.conf > $logfile
#sed -i "s|password=postfix|password=$postfixpassword|" /etc/zpanel/configs/dovecot2/dovecot-dict-quota.conf > $logfile
#sed -i "s|password=postfix|password=$postfixpassword|" /etc/zpanel/configs/dovecot2/dovecot-mysql.conf > $logfile
#touch /var/log/dovecot.log > $logfile
#touch /var/log/dovecot-info.log > $logfile
#touch /var/log/dovecot-debug.log > $logfile
#chown vmail:mail /var/log/dovecot* > $logfile
#chmod 660 /var/log/dovecot* > $logfile

# ProFTPD specific installation tasks
#groupadd -g 2001 ftpgroup > $logfile
#useradd -u 2001 -s /bin/false -d /bin/null -c "proftpd user" -g ftpgroup ftpuser > $logfile
#sed -i "s|zpanel_proftpd@localhost root z|zpanel_proftpd@localhost root $password|" /etc/zpanel/configs/proftpd/proftpd-mysql.conf > $logfile
#rm -rf /etc/proftpd.conf > $logfile
#touch /etc/proftpd.conf > $logfile
#if ! grep -q "include /etc/zpanel/configs/proftpd/proftpd-mysql.conf" /etc/proftpd.conf; then echo "include /etc/zpanel/configs/proftpd/proftpd-mysql.conf" >> /etc/proftpd.conf; fi > $logfile
#chmod -R 644 /var/zpanel/logs/proftpd > $logfile
#serverhost=`hostname`

# Apache HTTPD specific installation tasks...
#if ! grep -q "Include /etc/zpanel/configs/apache/httpd.conf" /etc/httpd/conf/httpd.conf; then echo "Include /etc/zpanel/configs/apache/httpd.conf" >> /etc/httpd/conf/httpd.conf; fi > $logfile
#if ! grep -q "127.0.0.1 "$fqdn /etc/hosts; then echo "127.0.0.1 "$fqdn >> /etc/hosts; fi > $logfile
#if ! grep -q "apache ALL=NOPASSWD: /etc/zpanel/panel/bin/zsudo" /etc/sudoers; then echo "apache ALL=NOPASSWD: /etc/zpanel/panel/bin/zsudo" >> /etc/sudoers; fi > $logfile
#sed -i 's|DocumentRoot "/var/www/html"|DocumentRoot "/etc/zpanel/panel"|' /etc/httpd/conf/httpd.conf > $logfile
#chown -R apache:apache /var/zpanel/temp/ > $logfile

# PHP specific installation tasks...
#sed -i "s|;date.timezone =|date.timezone = $tz|" /etc/php.ini > $logfile
#sed -i "s|;upload_tmp_dir =|upload_tmp_dir = /var/zpanel/temp/|" /etc/php.ini > $logfile

# Permissions fix for Apache and ProFTPD (to enable them to play nicely together!)
#if ! grep -q "umask 002" /etc/sysconfig/httpd; then echo "umask 002" >> /etc/sysconfig/httpd; fi > $logfile
#if ! grep -q "127.0.0.1 $serverhost" /etc/hosts; then echo "127.0.0.1 $serverhost" >> /etc/hosts; fi > $logfile
#usermod -a -G apache ftpuser > $logfile
#usermod -a -G ftpgroup apache > $logfile

# BIND specific installation tasks...
#chmod -R 777 /etc/zpanel/configs/bind/zones/ > $logfile
#rm -rf /etc/named.conf /etc/rndc.conf /etc/rndc.key > $logfile
#rndc-confgen -a > $logfile
#ln -s /etc/zpanel/configs/bind/named.conf /etc/named.conf > $logfile
#ln -s /etc/zpanel/configs/bind/rndc.conf /etc/rndc.conf > $logfile
#cat /etc/rndc.key /etc/named.conf | tee named.conf > /dev/null > $logfile
#cat /etc/rndc.key /etc/rndc.conf | tee named.conf > /dev/null > $logfile

# CRON specific installation tasks...
#mkdir -p /var/spool/cron/ > $logfile
#mkdir -p /etc/cron.d/ > $logfile
#touch /var/spool/cron/apache > $logfile
#touch /etc/cron.d/apache > $logfile
#crontab -u apache /var/spool/cron/apache > $logfile
#cp /etc/zpanel/configs/cron/zdaemon /etc/cron.d/zdaemon > $logfile
#chmod -R 644 /var/spool/cron/ > $logfile
#chmod -R 644 /etc/cron.d/ > $logfile
#chown -R apache:apache /var/spool/cron/ > $logfile

# Webalizer specific installation tasks...
#rm -rf /etc/webalizer.conf > $logfile

# Roundcube specific installation tasks...
#sed -i "s|YOUR_MYSQL_ROOT_PASSWORD|$password|" /etc/zpanel/configs/roundcube/db.inc.php > $logfile
#sed -i "s|#||" /etc/zpanel/configs/roundcube/db.inc.php > $logfile
#rm -rf /etc/zpanel/panel/etc/apps/webmail/config/main.inc.php > $logfile
#ln -s /etc/zpanel/configs/roundcube/main.inc.php /etc/zpanel/panel/etc/apps/webmail/config/main.inc.php > $logfile
#ln -s /etc/zpanel/configs/roundcube/config.inc.php /etc/zpanel/panel/etc/apps/webmail/plugins/managesieve/config.inc.php > $logfile
#ln -s /etc/zpanel/configs/roundcube/db.inc.php /etc/zpanel/panel/etc/apps/webmail/config/db.inc.php > $logfile

# Enable system services and start/restart them as required.
#chkconfig httpd on > $logfile
#chkconfig postfix on > $logfile
#chkconfig dovecot on > $logfile
#chkconfig crond on > $logfile
#chkconfig mysqld on > $logfile
#chkconfig named on > $logfile
#chkconfig proftpd on > $logfile
#service httpd start > $logfile
#service postfix restart > $logfile
#service dovecot start > $logfile
#service crond reload > $logfile
#service mysqld start > $logfile
#service named start > $logfile
#service proftpd start > $logfile
#service atd start > $logfile
#php /etc/zpanel/panel/bin/daemon.php > $logfile

# We'll now remove the temporary install cache.
#cd ../ > $logfile
#rm -rf zp_install_cache/ zpanelx/ > $logfile

echo "OK"
exit
