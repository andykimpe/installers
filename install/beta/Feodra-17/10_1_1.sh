#!/usr/bin/env bash

# OS VERSION: Fedora 17
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

# First we check if the user is 'root' before allowing installation to commence
while true; do
echo "To continue in English, type e"
echo "Pour continuer en Français, tapez f"
echo "To Exit / Pour quitter : CTRL-C"
read -e -p "? " lang
   case $lang in
     [e]* ) ZPXISOLANGUAGE=en && break;;
     [f]* ) ZPXISOLANGUAGE=fr && break;;
   esac
done

wget -q https://raw.github.com/zpanel/installers/master/lang/$ZPXISOLANGUAGE.sh -P /root
chmod +x /root/$ZPXISOLANGUAGE.sh
source $ZPXISOLANGUAGE.sh



# First we check if the user is 'root' before allowing installation to commence
if [ $UID -ne 0 ]; then
echo "$txt_installroot"
    exit 1
fi

# Lets check for some common control panels that we know will affect the installation/operating of ZPanel.
if [ -e /usr/local/cpanel ] || [ -e /usr/local/directadmin ] || [ -e /usr/local/solusvm/www ] || [ -e /usr/local/home/admispconfig ] || [ -e /usr/local/lxlabs/kloxo ] ; then
    echo -e "$txt_panel1"
    echo -e "$txt_panel2"
    echo -e "$txt_panel3"
    exit
fi

# Ensure the installer is launched and can only be launched on Fedora 17
if [ -f /etc/fedora-release ]; then
OS="Fedora"
  VER=$(rpm -q --queryformat '%{VERSION}\n' fedora-release)
else
OS=$(uname -s)
  VER=$(uname -r)
fi
echo "Detected : $OS $VER $BITS"
if [ "$OS" = "Fedora" ] && [ "$VER" = "17" ] ; then
echo "Ok."
else
echo "$txt_installsyserror Fedora 17."
  exit 1;
fi



networkmanagergome=$(rpm -q --queryformat '%{NAME}\n' NetworkManager-gnome)

if [ "$networkmanagergome" = "NetworkManager-gnome" ] ; then
echo "$txt_premove NetworkManager-gnome"
echo "$txt_reconfigureifcfg"
echo "$txt_restartinstaller"
  exit 1;
fi


# Set custom logging methods so we create a log file in the current working directory.
logfile=$$.log
exec > >(tee $logfile)
exec 2>&1

# ***************************************
# * Common installer functions *
# ***************************************

# Generates random passwords fro the 'zadmin' account as well as Postfix and MySQL root account.
passwordgen() {
         l=$1
           [ "$l" == "" ] && l=16
          tr -dc A-Za-z0-9 < /dev/urandom | head -c ${l} | xargs
}

# Display the 'welcome' splash/user warning info..
echo -e '*****************************************************************'
echo -e "$txt_gpl1 Fedora 17"
echo -e "$txt_gpl2"
echo -e "$txt_gpl3"
echo -e "$txt_gpl4"
echo -e "$txt_gpl5"
echo -e "$txt_gpl6"
echo -e "$txt_gpl7"
echo -e "$txt_gpl8"
echo -e '*****************************************************************'

# Set some installation defaults/auto assignments
fqdn=`/bin/hostname`
publicip=`wget -qO- http://api.zpanelcp.com/ip.txt`

# Lets check that the user wants to continue first...
while true; do
read -e -p "$txt_installcontinue" yn
    case $yn in
            [$txt_yes]* ) break;;
            [$txt_no]* ) exit;
        esac
done

#a selection list for the time zone is not better now?
yum -y -q install tzdata &>/dev/null
echo "echo \$TZ > /etc/timezone" >> /usr/bin/tzselect

# Installer options
while true; do
tzselect
        tz=`cat /etc/timezone`
        # patch hostname for apache 2.4 in fedora http://www.yodi.sg/fix-httpd-apache-wont-start-problem-in-fedora-18/
        read -e -p "$txt_enterfqdn : " -i $fqdn i &>/dev/tty
        while [ $i == "localhost.localdomain" ] || [ $i == "localhost" ]; do
echo "error your FQND shall not be localhost.localdomain or localhost"
        echo "Please re enter your FQND"
        read -e -p "$txt_enterfqdn : " -i $fqdn i &>/dev/tty
        done
fqdn=$i
        read -e -p "$txt_enterip : " -i $publicip publicip &>/dev/tty
        read -e -p "$txt_email : " email &>/dev/tty
        read -e -p "$txt_installok" yn
        case $yn in
                [$txt_yes]* ) break;;
                [$txt_no]* ) exit;
        esac
done

# patch hostname for apache 2.4 in fedora http://www.yodi.sg/fix-httpd-apache-wont-start-problem-in-fedora-18/
# warning /etc/resolv.conf
# No nameservers found; try putting DNS servers into your
# ifcfg files in /etc/sysconfig/network-scripts like so:
#
# DNS1=xxx.xxx.xxx.xxx
# DNS2=xxx.xxx.xxx.xxx
# DOMAIN=lab.foo.com bar.foo.com
chmod 777 /etc/sysconfig/network
cat > /etc/sysconfig/network <<EOF
NETWORKING=yes
HOSTNAME=$fqdn
EOF

hostname $fdqn

# We need to disable SELinux...
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
setenforce 0

# We now stop IPTables to ensure a fully automated and pain free installation.
iptables-save > /etc/sysconfig/iptables
systemctl stop iptables
systemctl disable iptables
systemctl stop ip6tables
systemctl disable ip6tables
systemctl stop sendmail
systemctl disable sendmail
systemctl restart network
chkconfig --add network
chkconfig network on
yum -y remove sendmail

# Start log creation.
echo -e ""
echo -e "# $txt_logdebug"
uname -a
echo -e ""
rpm -qa

# Removal of conflicting packages and services prior to ZPX installation.
yum -y remove bind-chroot bind-license

# Install some standard utility packages required by the installer and/or ZPX.
yum -y install sudo wget vim make zip unzip git chkconfig


# We now clone the ZPX software from GitHub
echo "$txt_downloadzp"
git clone https://github.com/bobsta63/zpanelx.git
cd zpanelx/
git checkout $ZPX_VERSION
mkdir ../zp_install_cache/
git checkout-index -a -f --prefix=../zp_install_cache/
cd ../zp_install_cache/

# We now update the server software packages.
yum -y update
yum -y upgrade

# Install required software and dependencies required by ZPanel.
yum -y install ld-linux.so.2 libdb-4.7.so libgd.so.2 httpd php php-devel php-gd php-mbstring php-mcrypt php-intl php-imap php-mysql php-xml php-xmlrpc curl curl-devel perl-libwww-perl libxml2 libxml2-devel mysql-server zip webalizer gcc gcc-c++ httpd-devel at make mysql-devel bzip2-devel postfix postfix-perl-scripts bash-completion dovecot dovecot-mysql dovecot-pigeonhole mysql-server proftpd proftpd-mysql bind bind-utils bind-libs

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
# password configure after check connexion
cc -o /etc/zpanel/panel/bin/zsudo /etc/zpanel/configs/bin/zsudo.c
sudo chown root /etc/zpanel/panel/bin/zsudo
chmod +s /etc/zpanel/panel/bin/zsudo

# MySQL specific installation tasks...
systemctl start mysqld
mysqladmin -u root password $password
until mysql -u root -p$password -e ";" > /dev/null 2>&1 ; do
read -s -p "$txt_mysqlpassworderror : " password
done
sed -i "s|YOUR_ROOT_MYSQL_PASSWORD|$password|" /etc/zpanel/panel/cnf/db.php
mysql -u root -p$password -e "DELETE FROM mysql.user WHERE User='root' AND Host != 'localhost'";
mysql -u root -p$password -e "DELETE FROM mysql.user WHERE User=''";
mysql -u root -p$password -e "DROP DATABASE test";
mysql -u root -p$password -e "CREATE SCHEMA zpanel_roundcube";
cat /etc/zpanel/configs/zpanelx-install/sql/*.sql | mysql -u root -p$password
mysql -u root -p$password -e "UPDATE mysql.user SET Password=PASSWORD('$postfixpassword') WHERE User='postfix' AND Host='localhost';";
mysql -u root -p$password -e "FLUSH PRIVILEGES";
sed -i "/symbolic-links=/a \secure-file-priv=/var/tmp" /etc/my.cnf

# Set some ZPanel custom configuration settings (using. setso and setzadmin)
/etc/zpanel/panel/bin/setso --set dbversion $ZPX_VERSION
/etc/zpanel/panel/bin/setso --set zpanel_domain $fqdn
/etc/zpanel/panel/bin/setso --set server_ip $publicip
/etc/zpanel/panel/bin/setso --set email_from_address $email
/etc/zpanel/panel/bin/setso --set daemon_lastrun 0
/etc/zpanel/panel/bin/setso --set daemon_dayrun 0
/etc/zpanel/panel/bin/setso --set daemon_weekrun 0
/etc/zpanel/panel/bin/setso --set daemon_monthrun 0
/etc/zpanel/panel/bin/setzadmin --set "$zadminNewPass"
/etc/zpanel/panel/bin/setso --set apache_changed "true"

# We'll store the passwords so that users can review them later if required.
touch /root/"$txt_passwords".txt;
echo "$txt_zadminpassword : $zadminNewPass" >> /root/"$txt_passwords"
echo "$txt_mysqlrootpassword : $password" >> /root/"$txt_passwords"
echo "$txt_mysqlpostfixpassword : $postfixpassword" >> /root/"$txt_passwords"
echo "$txt_ipaddress : $publicip" >> /root/"$txt_passwords"
echo "$txt_paneldomain : $fqdn" >> /root/"$txt_passwords"

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
if ! grep -q "127.0.0.1 autoreply.$fqdn" /etc/hosts; then echo "127.0.0.1 autoreply.$fqdn" >> /etc/hosts; fi
sed -i "s|myhostname = control.yourdomain.com|myhostname = $fqdn|" /etc/postfix/main.cf
sed -i "s|mydomain = control.yourdomain.com|mydomain = $fqdn|" /etc/postfix/main.cf
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
if ! grep -q "include /etc/zpanel/configs/proftpd/proftpd-mysql.conf" /etc/proftpd.conf; then echo "include /etc/zpanel/configs/proftpd/proftpd-mysql.conf" >> /etc/proftpd.conf; fi
chmod -R 644 /var/zpanel/logs/proftpd
serverhost=`hostname`

# Apache HTTPD specific installation tasks...
if ! grep -q "Include /etc/zpanel/configs/apache/httpd.conf" /etc/httpd/conf/httpd.conf; then echo "Include /etc/zpanel/configs/apache/httpd.conf" >> /etc/httpd/conf/httpd.conf; fi
if ! grep -q "127.0.0.1 "$fqdn /etc/hosts; then echo "127.0.0.1 "$fqdn >> /etc/hosts; fi
if ! grep -q "apache ALL=NOPASSWD: /etc/zpanel/panel/bin/zsudo" /etc/sudoers; then echo "apache ALL=NOPASSWD: /etc/zpanel/panel/bin/zsudo" >> /etc/sudoers; fi
sed -i 's|DocumentRoot "/var/www/html"|DocumentRoot "/etc/zpanel/panel"|' /etc/httpd/conf/httpd.conf
sed -i 's|<Directory "/var/www">|<Directory "/etc/zpanel/panel">|' /etc/httpd/conf/httpd.conf
sed -i 's|<Directory "/var/www/html">|<Directory "/etc/zpanel/panel">|' /etc/httpd/conf/httpd.conf
sed -i 's/ServerTokens Maj/#ServerTokens Maj/g' /etc/zpanel/configs/apache/httpd.conf
chown -R apache:apache /var/zpanel/temp/

# PHP specific installation tasks...
sed -i "s|;date.timezone =|date.timezone = $tz|" /etc/php.ini
sed -i "s|;upload_tmp_dir =|upload_tmp_dir = /var/zpanel/temp/|" /etc/php.ini

# Permissions fix for Apache and ProFTPD (to enable them to play nicely together!)
if ! grep -q "umask 002" /etc/sysconfig/httpd; then echo "umask 002" >> /etc/sysconfig/httpd; fi
if ! grep -q "127.0.0.1 $serverhost" /etc/hosts; then echo "127.0.0.1 $serverhost" >> /etc/hosts; fi
usermod -a -G apache ftpuser
usermod -a -G ftpgroup apache

# BIND specific installation tasks...
chmod -R 777 /etc/zpanel/configs/bind/zones/
rm -rf /etc/named.conf /etc/rndc.conf /etc/rndc.key
rndc-confgen -a
ln -s /etc/zpanel/configs/bind/named.conf /etc/named.conf
ln -s /etc/zpanel/configs/bind/rndc.conf /etc/rndc.conf
cat /etc/rndc.key /etc/named.conf | tee named.conf > /dev/null
cat /etc/rndc.key /etc/rndc.conf | tee named.conf > /dev/null

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
systemctl enable httpd
systemctl enable postfix
systemctl enable dovecot
systemctl enable crond
systemctl enable mysqld
systemctl enable named
systemctl enable proftpd
systemctl start httpd
systemctl restart postfix
systemctl start dovecot
systemctl restart crond
systemctl restart mysqld
systemctl start named
systemctl start proftpd
systemctl start atd

# Lauch Daemon
php /etc/zpanel/panel/bin/daemon.php


# Enable Disable system services and stop/restart them as required after daemon.


systemctl restart httpd
systemctl restart postfix
systemctl restart dovecot
systemctl restart crond
systemctl restart mysqld
systemctl restart named
systemctl restart proftpd
systemctl restart atd


# We'll now remove the temporary install cache.
cd ../
rm -rf zp_install_cache/ zpanelx/

# Advise the user that ZPanel is now installed and accessible.
echo -e "##############################################################" &>/dev/tty
echo -e "# $txt_finishinstall1 #" &>/dev/tty
echo -e "# $txt_finishinstall2 #" &>/dev/tty
echo -e "# $txt_finishinstall3 #" &>/dev/tty
echo -e "# #" &>/dev/tty
echo -e "# $txt_finishinstall4 #" &>/dev/tty
echo -e "# $txt_mysqlrootpassword : $password" &>/dev/tty
echo -e "# $txt_mysqlpostfixpassword : $postfixpassword" &>/dev/tty
echo -e "# $txt_finishinstall5 : zadmin #" &>/dev/tty
echo -e "# $txt_finishinstall6 : $zadminNewPass" &>/dev/tty
echo -e "# #" &>/dev/tty
echo -e "# $txt_finishinstall7 #" &>/dev/tty
echo -e "# $txt_finishinstall8 #" &>/dev/tty
echo -e "# #" &>/dev/tty
echo -e "##############################################################" &>/dev/tty
echo -e "" &>/dev/tty

# We now request that the user restarts their server...
read -e -p "$txt_finishinstall9" rsn
while true; do
case $rsn in
                [$txt_yes]* ) break;;
                [$txt_no]* ) exit;
        esac
done
shutdown -r now
