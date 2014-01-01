#!/bin/bash
# zpanel installer originale English Language
txt_osdetect="Detected"
txt_installroot="Installed failed! To install you must be logged in as 'root', please try again"
txt_upgraderoot="Upgrade failed! To upgrade you must be logged in as 'root', please try again"
txt_panel='You appear to have a control panel already installed on your server; This installer\n'
txt_panel=$txt_panel'is designed to install and configure ZPanel on a clean OS installation only!\n\n'
txt_panel=$txt_panel'Please re-install your OS before attempting to install using this script.'
txt_installsyserror="Sorry, this installer only supports the installation of ZPanel on"
txt_upgradesyserror="Sorry, this upgrade script only supports ZPanel on"
txt_zpanelnotfound="ZPanel has not been detected on this server, the upgrade script can therefore not continue!"
txt_upgrade1="The ZPanel Upgrade script is now ready to start, we recommend that before"
txt_upgrade2="continuing that you first backup your ZPanel server to enable a restore"
txt_upgrade3="in the event that something goes wrong during the upgrade process!"
txt_upgrade4="Would you like to continue with the upgrade now (y/n)? "
txt_upgrade5="Please provide your current MySQL root password (this can found in /etc/zpanel/panel/cnf/db.php)"
txt_upgrade6="ZPanel will now be updated, are you sure you want to continue (y/n)? "
txt_upgrade7="Please read and note down any update errors and messages below:"
txt_upgrade8="Restart your server now to complete the upgrade (y/n)? "
txt_yes="Yy"
txt_no="Nn"
txt_premove="Please remove"
txt_reconfigureifcfg="reconfigure ifcfg files in /etc/sysconfig/network-scripts"
txt_reconfigureinterface="reconfigure /etc/network/interfaces"
txt_restartinstaller="and restart the installer"
txt_gpl1=" Welcome to the Official ZPanelX Installer for"
txt_gpl2=" Please make sure your VPS provider hasn t pre-installed "
txt_gpl3=" any packages required by ZPanelX. "
txt_gpl4=" If you are installing on a physical machine where the OS "
txt_gpl5=" has been installed by yourself please make sure you only "
txt_gpl6=" installed your system with no extra packages. "
txt_gpl7=" If you selected additional options during the your system "
txt_gpl8=" install please consider reinstalling without them. "
txt_errorzpversion="your version of ZPanel already updated"
txt_installcontinue="Would you like to continue (y/n)?"
txt_apparmor="Disabling and removing AppArmor, please wait..."
txt_logdebug="Generating installation log and debug info..."
txt_downloadzp="Downloading ZPanel, Please wait, this may take several minutes, the installer will continue after this is complete!"
txt_enterfqdn="Enter the FQDN of the server (example: zpanel.yourdomain.com)"
txt_mysqlpassworderror="Enter Your current root Password of mysql"
txt_enterip="Enter the public (external) server IP"
txt_email="enter your email address"
txt_installok="ZPanel is now ready to install, do you wish to continue (y/n)"
txt_aptitude="Updating Aptitude Repos"
txt_zadminpassword="zadmin Password"
txt_mysqlrootpassword="MySQL Root Password"
txt_mysqlpostfixpassword="MySQL Postfix Password"
txt_ipaddress="IP Address"
txt_paneldomain="Panel Domain"
txt_passwords="passwords"
txt_finishinstall1="Congratulations ZpanelX has now been installed on your"
txt_finishinstall2="server. Please review the log file left in /root/ for"
txt_finishinstall3="any errors encountered during installation."
txt_finishinstall4="Save the following information somewhere safe:"
txt_finishinstall5="ZPanelX Username"
txt_finishinstall6="ZPanelX Password"
txt_finishinstall7="ZPanelX Web login can be accessed using your server IP"
txt_finishinstall8="inside your web browser."
txt_finishinstall9="Restart your server now to complete the install (y/n)? "
