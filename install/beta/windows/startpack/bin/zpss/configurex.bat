@echo off
COLOR F2
echo Copying config packs..
xcopy /s/e c:\zpanel\panel\etc\build\config_packs\ms_windows\* c:\zpanel\configs
copy  c:\zpanel\panel\etc\build\config_packs\ubuntu_12_04\roundcube\main.inc.php c:\zpanel\panel\etc\apps\webmail\config\main.inc.php /Y

echo Done!

echo Importing ZPanel database..
mysql -uroot < c:\zpanel\configs\zpanel_core.sql
echo Cleaning up MySQL users (securing MySQL server)..
mysql -uroot < c:\zpanel\bin\zpss\MySQL_User_Cleanup.sql

echo Registering tools..
COPY c:\zpanel\panel\etc\build\bin\zppy.bat %windir%\zppy.bat /Y
COPY c:\zpanel\panel\etc\build\bin\setso.bat %windir%\setso.bat /Y
COPY c:\zpanel\panel\etc\build\bin\setzadmin.bat %windir%\setzadmin.bat /Y
echo Done!

echo Running configuration task..
php C:\zpanel\bin\zpss\enviroment_configure.php
echo The installer will now finalise the install...

echo Restarting Apache..
echo Stopping Apache
net stop Apache 
echo Starting Apache
net start Apache

echo Running the daemon for the first time..
php C:\zpanel\panel\bin\daemon.php
echo Done!

echo Restarting all services..
echo Stopping Apache
net stop Apache 
echo Starting Apache
net start Apache
echo Stopping hMailServer
net stop hMailServer 
echo Starting hMailServer
net start hMailServer
echo Stopping BIND
net stop named
echo Starting BIND
net start named

pause

echo Cleaning up..
DEL /F /Q c:\zpanel\bin\zpss\*.php
DEL /F /Q c:\zpanel\bin\zpss\*.sql
DEL /F /Q c:\zpanel\bin\zpss\*.bat



