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

après l'installation vérifier la liste des service actif

systemctl list-unit-files

votre liste de service doit étre comme ceci

https://github.com/andykimpe/installers/raw/master/install/beta/Feodra-17/service.txt

