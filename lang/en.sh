#!/bin/bash
installroot="Installed failed! To install you must be logged in as 'root', please try again"
upgraderoot="Upgrade failed! To upgrade you must be logged in as 'root', please try again"
panel='You appear to have a control panel already installed on your server; This installer\n'
panel=$panel'is designed to install and configure ZPanel on a clean OS installation only!\n\n'
panel=$panel'Please re-install your OS before attempting to install using this script.'
installsyserror="Sorry, this installer only supports the installation of ZPanel on"
upgradesyserror="Sorry, this upgrade script only supports ZPanel on"
gpl=' Welcome to the Official ZPanelX Installer for $OS $VER \n\n'
gpl=$gpl' Please make sure your VPS provider hasn t pre-installed \n'
gpl=$gpl' any packages required by ZPanelX. \n\n'
gpl=$gpl' If you are installing on a physical machine where the OS \n'
gpl=$gpl' has been installed by yourself please make sure you only \n'
gpl=$gpl' installed $OS with no extra packages. \n\n'
gpl=$gpl' If you selected additional options during the $OS \n'
gpl=$gpl' install please consider reinstalling without them. \n'
errorzpversion="your version of ZPanel already updated"
