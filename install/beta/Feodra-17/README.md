ZPanel Installers Fédora
=================

testing and work
 Fédora 17 64 bit minimal work log file http://pastebin.com/QDtTDYE6
 
 Fédora 17 64 bit minimal work log file http://pastebin.com/CXW93zj4
 
For testing the installer install Fédora Minimal and enter command

Pour tester cette installateur installer Fédora Minimale et entrée les commande suivante

yum -y update

yum -y install bash wget

iptables-save > /etc/sysconfig/iptables

systemctl stop iptables

systemctl disable iptables

systemctl stop ip6tables

systemctl disable ip6tables

systemctl stop sendmail

systemctl disable sendmail

systemctl restart network

chkconfig --add network

systemctl enable network

wget https://raw.github.com/andykimpe/installers/master/install/beta/Feodra-17/10_1_1.sh && bash 10_1_1.sh
