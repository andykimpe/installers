#!/usr/bin/env bash

# OS VERSION: Ubuntu Server 12.04.x LTS
# ARCH: x32_64

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

# Ensure the installer
if [ -f /usr/bin/apt-get ]; then
apt-get update &> /dev/null
apt-get -y install base-files debian-edu-config  &> /dev/null
else
echo "$txt_installsyserror Debian 7."
  exit 1;
fi
BITS=$(uname -m | sed 's/x86_//;s/i[3-6]86/32/')
if [ -f /etc/os-release ]; then
OS=Debian
  VER=$(cat /etc/os-release | grep VERSION_ID | sed 's/^.*="//' | sed 's/"//')
else
OS=$(uname -s)
  VER=$(uname -r)
fi
echo "Detected : $OS $VER $BITS"
if [ "$OS" = "Debian" ] && [ "$VER" = "7" ] ; then
echo "Ok."
else
echo "$txt_installsyserror Debian 7."
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
echo -e "$txt_gpl1 Debian 7"
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

# Lets check that the user wants to continue first as obviously otherwise we'll be removing AppArmor for no reason.
while true; do
read -e -p "$txt_installcontinue" yn
    case $yn in
                [$txt_yes]* ) break;;
                [$txt_no]* ) exit;
        esac
done

# We need to disable and remove AppArmor...
[ -f /etc/init.d/apparmor ]
if [ $? = "0" ]; then
echo -e ""
    echo -e "$txt_apparmor"
    /etc/init.d/apparmor stop &> /dev/null
        update-rc.d -f apparmor remove &> /dev/null
        apt-get -y remove apparmor &> /dev/null
        mv /etc/init.d/apparmor /etc/init.d/apparmpr.removed &> /dev/null
        ##after removing AppArmor reboot is not obligatory
        #echo -e "Please restart the server and run the installer again. AppArmor has been removed."
        #exit
fi

#a selection list for the time zone is not better now?
apt-get -yqq update &>/dev/null
apt-get -yqq install tzdata &>/dev/null

# Installer options
while true; do
        #echo -e "Find your timezone from : http://php.net/manual/en/timezones.php e.g Europe/London"
        #read -e -p "Enter your timezone: " -i "Europe/London" tz
        dpkg-reconfigure tzdata &>/dev/tty
        tz=`cat /etc/timezone` 
        read -e -p "$txt_enterfqdn : " -i $fqdn fqdn &>/dev/tty
        read -e -p "$txt_enterip : " -i $publicip publicip &>/dev/tty
        read -e -p "$txt_email :" email &>/dev/tty
    read -e -p "$txt_installok" yn
    case $yn in
        [$txt_yes]* ) break;;
        [$txt_no]* ) exit;
    esac
done

# Start log creation.
echo -e ""
echo -e "# $txt_logdebug"
uname -a
echo -e ""
dpkg --get-selections

# We need to update the enabled Aptitude repositories
echo -ne "\n$txt_aptitude: "
#if grep -Fxq "deb-src" /etc/apt/sources.list
#then
# echo "sources list up-to-date"
#else
# echo "deb-src http://archive.ubuntu.com/ubuntu precise main" >> /etc/apt/sources.list
# echo "deb-src http://archive.ubuntu.com/ubuntu precise-updates main" >> /etc/apt/sources.list
# echo "deb-src http://security.ubuntu.com/ubuntu precise-security main" >> /etc/apt/sources.list
# echo "deb-src http://archive.ubuntu.com/ubuntu precise universe" >> /etc/apt/sources.list
# echo "deb-src http://archive.ubuntu.com/ubuntu precise-updates universe" >> /etc/apt/sources.list
#fi
#to avoid compatibility problems have ppa and removes deposits in the outcry over
 mkdir -p "/etc/apt/sources.list.d.save"
        cp -R "/etc/apt/sources.list.d/*" "/etc/apt/sources.list.d.save" &> /dev/null
        rm -rf "/etc/apt/sources.list/*"
        cp "/etc/apt/sources.list" "/etc/apt/sources.list.save"
cat > /etc/apt/sources.list <<EOF
#Dépots main restricted
deb http://ftp.uk.debian.org/debian/ wheezy main contrib non-free
deb-src http://ftp.uk.debian.org/debian/ wheezy main contrib non-free

deb http://ftp.uk.debian.org/debian/ wheezy-updates main contrib non-free
deb-src http://ftp.uk.debian.org/debian/ wheezy-updates main contrib non-free
EOF

apt-get -yqq update &>/dev/null

# Install some standard utility packages required by the installer and/or ZPX.
apt-get -y install sudo wget vim make zip unzip git debconf-utils

# We now clone the ZPX software from GitHub
echo "$txt_downloadzp"
git clone https://github.com/bobsta63/zpanelx.git
cd zpanelx/
git checkout $ZPX_VERSION
mkdir ../zp_install_cache/
git checkout-index -a -f --prefix=../zp_install_cache/
cd ../zp_install_cache/

# We now update the server software packages.
apt-get update -yqq
apt-get dist-upgrade -yqq

# Install required software and dependencies required by ZPanel.
# We disable the DPKG prompts before we run the software install to enable fully automated install.
export DEBIAN_FRONTEND=noninteractive
apt-get install -qqy mysql-server mysql-server apache2 libapache2-mod-php5 libapache2-mod-bw php5-common php5-cli php5-mysql php5-gd php5-mcrypt php5-curl php-pear php5-imap php5-xmlrpc php5-xsl db4.7-util zip webalizer build-essential bash-completion dovecot-mysql dovecot-imapd dovecot-pop3d dovecot-common dovecot-managesieved dovecot-lmtpd postfix postfix-mysql libsasl2-modules-sql libsasl2-modules proftpd-mod-mysql bind9 bind9utils

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
chown -R www-data:www-data /var/zpanel/hostdata/
chmod 644 /etc/zpanel/panel/etc/apps/phpmyadmin/config.inc.php
ln -s /etc/zpanel/panel/bin/zppy /usr/bin/zppy
ln -s /etc/zpanel/panel/bin/setso /usr/bin/setso
ln -s /etc/zpanel/panel/bin/setzadmin /usr/bin/setzadmin
chmod +x /etc/zpanel/panel/bin/zppy
chmod +x /etc/zpanel/panel/bin/setso
cp -R /etc/zpanel/panel/etc/build/config_packs/ubuntu_12_04/. /etc/zpanel/configs/
# password configure after check connexion
cc -o /etc/zpanel/panel/bin/zsudo /etc/zpanel/configs/bin/zsudo.c
sudo chown root /etc/zpanel/panel/bin/zsudo
chmod +s /etc/zpanel/panel/bin/zsudo

# MySQL specific installation tasks...
service mysql start
mysqladmin -u root password $password > /dev/null 2>&1
until mysql -u root -p$password -e ";" > /dev/null 2>&1 ; do
read -s -p "$txt_mysqlpassworderror : " password
done
sed -i "s|YOUR_ROOT_MYSQL_PASSWORD|$password|" /etc/zpanel/panel/cnf/db.php
mysql -u root -p$password -e "DROP DATABASE test";
mysql -u root -p$password -e "DELETE FROM mysql.user WHERE User='root' AND Host != 'localhost'";
mysql -u root -p$password -e "DELETE FROM mysql.user WHERE User=''";
mysql -u root -p$password -e "FLUSH PRIVILEGES";
mysql -u root -p$password -e "CREATE SCHEMA zpanel_roundcube";
cat /etc/zpanel/configs/zpanelx-install/sql/*.sql | mysql -u root -p$password
mysql -u root -p$password -e "UPDATE mysql.user SET Password=PASSWORD('$postfixpassword') WHERE User='postfix' AND Host='localhost';";
mysql -u root -p$password -e "FLUSH PRIVILEGES";
sed -i "/ssl-key=/a \secure-file-priv = /var/tmp" /etc/mysql/my.cnf

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
mkdir /var/zpanel/vmail
chmod -R 770 /var/zpanel/vmail
useradd -r -u 150 -g mail -d /var/zpanel/vmail -s /sbin/nologin -c "Virtual maildir" vmail
chown -R vmail:mail /var/zpanel/vmail
mkdir -p /var/spool/vacation
useradd -r -d /var/spool/vacation -s /sbin/nologin -c "Virtual vacation" vacation
chmod -R 770 /var/spool/vacation
ln -s /etc/zpanel/configs/postfix/vacation.pl /var/spool/vacation/vacation.pl
postmap /etc/postfix/transport
chown -R vacation:vacation /var/spool/vacation
if ! grep -q "127.0.0.1 autoreply.$fqdn" /etc/hosts; then echo "127.0.0.1 autoreply.$fqdn" >> /etc/hosts; fi
rm -rf /etc/postfix/main.cf /etc/postfix/master.cf
ln -s /etc/zpanel/configs/postfix/master.cf /etc/postfix/master.cf
ln -s /etc/zpanel/configs/postfix/main.cf /etc/postfix/main.cf
sed -i "s|myhostname = control.yourdomain.com|myhostname = $fqdn|" /etc/postfix/main.cf
sed -i "s|mydomain = control.yourdomain.com|mydomain = $fqdn|" /etc/postfix/main.cf
sed -i "s|password \= postfix|password \= $postfixpassword|" /etc/zpanel/configs/postfix/mysql-relay_domains_maps.cf
sed -i "s|password \= postfix|password \= $postfixpassword|" /etc/zpanel/configs/postfix/mysql-virtual_alias_maps.cf
sed -i "s|password \= postfix|password \= $postfixpassword|" /etc/zpanel/configs/postfix/mysql-virtual_domains_maps.cf
sed -i "s|password \= postfix|password \= $postfixpassword|" /etc/zpanel/configs/postfix/mysql-virtual_mailbox_limit_maps.cf
sed -i "s|password \= postfix|password \= $postfixpassword|" /etc/zpanel/configs/postfix/mysql-virtual_mailbox_maps.cf
sed -i "s|\$db_password \= 'postfix';|\$db_password \= '$postfixpassword';|" /etc/zpanel/configs/postfix/vacation.conf

# Dovecot specific installation tasks (includes Sieve)
mkdir -p /var/zpanel/sieve
chown -R vmail:mail /var/zpanel/sieve
mkdir -p /var/lib/dovecot/sieve/
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
sed -i "s|#SQLConnectInfo zpanel_proftpd@localhost root password_here|SQLConnectInfo zpanel_proftpd@localhost root $password|" /etc/zpanel/configs/proftpd/proftpd-mysql.conf
rm -rf /etc/proftpd/proftpd.conf
touch /etc/proftpd/proftpd.conf
if ! grep -q "include /etc/zpanel/configs/proftpd/proftpd-mysql.conf" /etc/proftpd/proftpd.conf; then echo "include /etc/zpanel/configs/proftpd/proftpd-mysql.conf" >> /etc/proftpd/proftpd.conf; fi
chmod -R 644 /var/zpanel/logs/proftpd
serverhost=`hostname`

# Apache HTTPD specific installation tasks...
if ! grep -q "Include /etc/zpanel/configs/apache/httpd.conf" /etc/apache2/apache2.conf; then echo "Include /etc/zpanel/configs/apache/httpd.conf" >> /etc/apache2/apache2.conf; fi
sed -i 's|DocumentRoot "/var/www/html"|DocumentRoot "/etc/zpanel/panel"|' /etc/apache2/apache2.conf
sed -i 's|Include sites-enabled/||' /etc/apache2/apache2.conf
chown -R www-data:www-data /var/zpanel/temp/
if ! grep -q "127.0.0.1 "$fqdn /etc/hosts; then echo "127.0.0.1 "$fqdn >> /etc/hosts; fi
if ! grep -q "www-data ALL=NOPASSWD: /etc/zpanel/panel/bin/zsudo" /etc/sudoers; then echo "www-data ALL=NOPASSWD: /etc/zpanel/panel/bin/zsudo" >> /etc/sudoers; fi
a2enmod rewrite
service apache2 restart

# PHP specific installation tasks...
sed -i "s|;date.timezone =|date.timezone = $tz|" /etc/php5/cli/php.ini
sed -i "s|;date.timezone =|date.timezone = $tz|" /etc/php5/apache2/php.ini
sed -i "s|;upload_tmp_dir =|upload_tmp_dir = /var/zpanel/temp/|" /etc/php5/cli/php.ini
sed -i "s|;upload_tmp_dir =|upload_tmp_dir = /var/zpanel/temp/|" /etc/php5/apache2/php.ini

# Permissions fix for Apache and ProFTPD (to enable them to play nicely together!)
if ! grep -q "umask 002" /etc/apache2/envvars; then echo "umask 002" >> /etc/apache2/envvars; fi
if ! grep -q "127.0.0.1 $serverhost" /etc/hosts; then echo "127.0.0.1 $serverhost" >> /etc/hosts; fi
usermod -a -G www-data ftpuser
usermod -a -G ftpgroup www-data

# BIND specific installation tasks...
chmod -R 777 /etc/zpanel/configs/bind/zones/
mkdir /var/zpanel/logs/bind
mkdir -p /var/named/dynamic
touch /var/named/dynamic/managed-keys.bind
touch /var/zpanel/logs/bind/bind.log
chown root:root /etc/bind/rndc.key
chown -R bind:bind /var/named/
chmod 755 /etc/bind/rndc.key
chmod -R 777 /var/zpanel/logs/bind/bind.log
chmod -R 777 /etc/zpanel/configs/bind/etc
rm -rf /etc/bind/named.conf /etc/bind/rndc.conf /etc/bind/rndc.key
rndc-confgen -a
ln -s /etc/zpanel/configs/bind/named.conf /etc/bind/named.conf
ln -s /etc/zpanel/configs/bind/rndc.conf /etc/bind/rndc.conf
if ! grep -q "include \"/etc/zpanel/configs/bind/etc/log.conf\";" /etc/bind/named.conf; then echo "include \"/etc/zpanel/configs/bind/etc/log.conf\";" >> /etc/bind/named.conf; fi
ln -s /usr/sbin/named-checkconf /usr/bin/named-checkconf
ln -s /usr/sbin/named-checkzone /usr/bin/named-checkzone
ln -s /usr/sbin/named-compilezone /usr/bin/named-compilezone
cat /etc/bind/rndc.key | cat - /etc/bind/named.conf > /etc/bind/named.conf.new && mv /etc/bind/named.conf.new /etc/bind/named.conf
cat /etc/bind/rndc.key | cat - /etc/bind/rndc.conf > /etc/bind/rndc.conf.new && mv /etc/bind/rndc.conf.new /etc/bind/rndc.conf
rm -rf /etc/bind/rndc.key

# CRON specific installation tasks...
mkdir -p /var/spool/cron/crontabs/
mkdir -p /etc/cron.d/
touch /var/spool/cron/crontabs/www-data
touch /etc/cron.d/www-data
crontab -u www-data /var/spool/cron/crontabs/www-data
cp /etc/zpanel/configs/cron/zdaemon /etc/cron.d/zdaemon
chmod -R 644 /var/spool/cron/crontabs/
chmod -R 644 /etc/cron.d/
chown -R www-data:www-data /var/spool/cron/crontabs/

# Webalizer specific installation tasks...
rm -rf /etc/webalizer/webalizer.conf

# Roundcube specific installation tasks...
sed -i "s|YOUR_MYSQL_ROOT_PASSWORD|$password|" /etc/zpanel/configs/roundcube/db.inc.php
sed -i "s|#||" /etc/zpanel/configs/roundcube/db.inc.php
rm -rf /etc/zpanel/panel/etc/apps/webmail/config/main.inc.php
ln -s /etc/zpanel/configs/roundcube/main.inc.php /etc/zpanel/panel/etc/apps/webmail/config/main.inc.php
ln -s /etc/zpanel/configs/roundcube/config.inc.php /etc/zpanel/panel/etc/apps/webmail/plugins/managesieve/config.inc.php
ln -s /etc/zpanel/configs/roundcube/db.inc.php /etc/zpanel/panel/etc/apps/webmail/config/db.inc.php

# Enable system services and start/restart them as required.
service apache2 start
service postfix restart
service dovecot start
service cron reload
service mysql start
service bind9 start
service proftpd start
service atd start
php /etc/zpanel/panel/bin/daemon.php

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
