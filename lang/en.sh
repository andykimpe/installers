#!/bin/bash
installroot="Installed failed! To install you must be logged in as 'root', please try again"
upgraderoot="Upgrade failed! To upgrade you must be logged in as 'root', please try again"
panel='You appear to have a control panel already installed on your server; This installer\n'
panel=$panel'is designed to install and configure ZPanel on a clean OS installation only!\n\n'
panel=$panel'Please re-install your OS before attempting to install using this script.'
installsyserror="Sorry, this installer only supports the installation of ZPanel on"
