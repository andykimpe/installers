ZPanel Installers Fédora
=================

testing and work
 Fédora 17 64 bit minimal work log file http://pastebin.com/QDtTDYE6
 
 Fédora 17 64 bit minimal work log file http://pastebin.com/CXW93zj4
 
For testing the installer install Fédora Minimal and enter command

Pour tester cette installateur installer Fédora Minimale et entrée les commande suivante

yum -y update

yum -y install bash wget

wget https://raw.github.com/andykimpe/installers/master/install/beta/Feodra-17/10_1_1.sh && bash 10_1_1.sh

after install check service list status

systemctl list-unit-files

your roster should be like this

https://github.com/andykimpe/installers/raw/master/install/beta/Feodra-17/service.txt

if this is not the case perform the following command

systemctl stop iptables

systemctl disable iptables

systemctl stop ip6tables

systemctl disable ip6tables

systemctl stop sendmail

systemctl disable sendmail

systemctl restart network

chkconfig --add network

chkconfig network on

systemctl enable httpd

systemctl enable postfix

systemctl enable dovecot

systemctl enable crond

systemctl enable mysqld

systemctl enable named

systemctl enable proftpd

systemctl restart httpd

systemctl restart postfix

systemctl restart dovecot

systemctl restart crond

systemctl restart mysqld

systemctl restart named

systemctl restart proftpd

systemctl restart atd

restart the server and check the list again


après l'installation vérifier la liste des service actif

systemctl list-unit-files

votre liste de service doit étre comme ceci

https://github.com/andykimpe/installers/raw/master/install/beta/Feodra-17/service.txt

si ce n'est pas le cas exécuter les commande suivante

systemctl stop iptables

systemctl disable iptables

systemctl stop ip6tables

systemctl disable ip6tables

systemctl stop sendmail

systemctl disable sendmail

systemctl restart network

chkconfig --add network

chkconfig network on

systemctl enable httpd

systemctl enable postfix

systemctl enable dovecot

systemctl enable crond

systemctl enable mysqld

systemctl enable named

systemctl enable proftpd

systemctl restart httpd

systemctl restart postfix

systemctl restart dovecot

systemctl restart crond

systemctl restart mysqld

systemctl restart named

systemctl restart proftpd

systemctl restart atd

redémarrer le serveur et vérifier a nouveau la liste
