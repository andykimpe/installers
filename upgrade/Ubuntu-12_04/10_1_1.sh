#!/usr/bin/env bash

# OS VERSION: Ubuntu Server 12.04.x LTS
# ARCH: x32_64

ZPX_VERSION=10.1.1
ZPX_VERSION_ACTUAL="$(setso --show dbversion)"

# Official ZPanel Automated Upgrade Script
# =============================================
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

# First we check if the user is 'root' before allowing the upgrade to commence

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



if [ $UID -ne 0 ]; then
    echo -e "$txt_upgraderoot"
    exit 1;
fi

# Ensure the installer is launched and can only be launched on Ubuntu 12.04
BITS=$(uname -m | sed 's/x86_//;s/i[3-6]86/32/')
if [ -f /etc/lsb-release ]; then
  OS=$(cat /etc/lsb-release | grep DISTRIB_ID | sed 's/^.*=//')
  VER=$(cat /etc/lsb-release | grep DISTRIB_RELEASE | sed 's/^.*=//')
else
  OS=$(uname -s)
  VER=$(uname -r)
fi
echo "$txt_osdetect : $OS  $VER  $BITS"
if [ "$OS" = "Ubuntu" ] && [ "$VER" = "12.04" ]; then
  echo "Ok."
else
  echo -e "$txt_upgradesyserror Ubuntu 12.04."
  exit 1;
fi

if [ "$ZPX_VERSION" = "$ZPX_VERSION_ACTUAL" ] ; then
echo -e "$txt_errorzpversion"
fi

# Set custom logging methods so we create a log file in the current working directory.
logfile=$$.log
exec > >(tee $logfile)
exec 2>&1

# Check that ZPanel has been detected on the server if not, we'll exit!
if [ ! -d /etc/zpanel ]; then
    echo "$txt_zpanelnotfound"
    exit 1;
fi

# Lets check that the user wants to continue first and recommend they have a backup!
echo ""
echo "$txt_upgrade1"
echo "$txt_upgrade2"
echo "$txt_upgrade3"
echo ""
while true; do
read -e -p "$txt_upgrade4" yn
    case $yn in
		[$txt_yes]* ) break;;
		[$txt_no]* ) exit;
	esac
done

# Now we'll ask upgrade specific automatic detection...
if [ "$ZPX_VERSION_ACTUAL" = "10.0.0" ] ; then
upgradeto=10-0-1
ZPX_VERSIONGIT=10.0.1
fi

if [ "$ZPX_VERSION_ACTUAL" = "10.0.1" ] ; then
upgradeto=10-0-2
ZPX_VERSIONGIT=10.0.2
fi

if [ "$ZPX_VERSION_ACTUAL" = "10.0.2" ] ; then
upgradeto=10-1-0
ZPX_VERSIONGIT=10.1.0
fi

if [ "$ZPX_VERSION_ACTUAL" = "10.1.0" ] ; then
upgradeto=10-1-1
ZPX_VERSIONGIT=10.1.1
fi


#echo -e "Please enter the version of which you'd like to upgrade ZPanel to, for example 10-1-1"
#read -e -p "Upgrade to version:" -i "10-1-1" upgradeto
#echo -e ""
echo -e "$txt_upgrade5"
read -esp "$txt_mysqlrootpassword : " -i ""
echo -e ""
while true; do
	read -e -p "$txt_upgrade6" yn
	case $yn in
		 [$txt_yes]* ) break;;
		 [$txt_no]* ) exit;
	esac
done

# We now clone the latest ZPX software from GitHub
echo "$txt_downloadzp"
git clone https://github.com/bobsta63/zpanelx.git
cd zpanelx/
git checkout $ZPX_VERSIONGIT
mkdir ../zp_install_cache/
git checkout-index -a -f --prefix=../zp_install_cache/
cd ../zp_install_cache/
rm -rf cnf/

# Lets run OS software updates
apt-get update -yqq
apt-get upgrade -yqq

# Now we make ZPanel application/file specific updates
cp -R . /etc/zpanel/panel/
chmod -R 777 /etc/zpanel/
chmod 644 /etc/zpanel/panel/etc/apps/phpmyadmin/config.inc.php
cc -o /etc/zpanel/panel/bin/zsudo /etc/zpanel/configs/bin/zsudo.c
sudo chown root /etc/zpanel/panel/bin/zsudo
chmod +s /etc/zpanel/panel/bin/zsudo

# Lets execute MySQL data upgrade scripts
cat /etc/zpanel/panel/etc/build/config_packs/ubuntu_12_04/zpanelx-update/$upgradeto/sql/*.sql | mysql -u root -p$mysqlpassword
updatemessage=""
for each in /etc/zpanel/panel/etc/build/config_packs/ubuntu_12_04/zpanelx-update/$upgradeto/shell/*.sh ; do
    updatemessage="$updatemessage\n"$(bash $each)  ;
done

# We ensure that the daemons are registered for automatic startup and are restarted for changes to take effect
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
rm -rf zpanelx/ zp_install_cache/

# We now display to the user(s) update SQL/BASH upgrade script messages etc.
echo -e ""
echo -e "###################################################################"
echo -e "# $txt_upgrade7 #"
echo -e "# $updatemessage #"
echo -e "#                                                                 #"
echo -e "###################################################################"
echo -e ""

# We now recommend  that the user restarts their server...
while true; do
read -e -p "$txt_upgrade8" rsn
	case $rsn in
		[Yy]* ) break;;
		[Nn]* ) exit;
	esac
done
shutdown -r now
