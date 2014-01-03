<?php
/*
############################################################
# Enviroment configuration script for ZPI                  #
# Developedy by Bobby Allen, 18th November 2009            #
############################################################
# Last updated by Bobby Allen 09/03/2012                   #
############################################################
 */

fwrite(STDOUT, "\r\n
##################################################\r\n
# ZPANELX CONFIG WIZARD FOR WINDOWS              #\r\n
##################################################\r\n");

// ZPanel version (Sent to ZPanel)
$version = "10.1.0";

// Set default MySQL account details etc...
$hostname_db = "localhost";
$username_db = "root";
$password_db = "";
$db = mysql_pconnect($hostname_db, $username_db, $password_db) or trigger_error('Unable to connect to database server.');

// Generate two random passwords...
$p1 = substr(md5(uniqid(rand(), 1)), 3, 8);
$p2 = substr(md5(uniqid(rand(), 1)), 3, 6);

// Set MySQL ROOT password to a random password and display to user!
fwrite(STDOUT, "\r\nConfiguring MySQL 'root' password...\r\n");
$sql = "SET PASSWORD FOR `root`@`localhost`=PASSWORD('" . $p1 . "')";
$resault = @mysql_query($sql, $db) or die(mysql_error());
$sql = "FLUSH PRIVILEGES;";
$resault = @mysql_query($sql, $db) or die(mysql_error());

// Create system.php file for database access:-
$db_settings_file = fopen("c:/zpanel/panel/cnf/db.php", "w");
fwrite($db_settings_file, "<?php\n");
fwrite($db_settings_file, "/**\n");
fwrite($db_settings_file, " * Database configuration file.\n");
fwrite($db_settings_file, " * @package zpanelx\n");
fwrite($db_settings_file, " * @subpackage core -> config\n");
fwrite($db_settings_file, " * @author Bobby Allen (ballen@zpanelcp.com)\n");
fwrite($db_settings_file, " * @copyright ZPanel Project (http://www.zpanelcp.com/)\n");
fwrite($db_settings_file, " * @link http://www.zpanelcp.com/\n");
fwrite($db_settings_file, " * @license GPL (http://www.gnu.org/licenses/gpl.html)\n");
fwrite($db_settings_file, " */\n");
fwrite($db_settings_file, "\$host = \"localhost\";\n");
fwrite($db_settings_file, "\$dbname = \"zpanel_core\";\n");
fwrite($db_settings_file, "\$user = \"root\";\n");
fwrite($db_settings_file, "\$pass = \"" . $p1 . "\";\n");
fwrite($db_settings_file, "?>");
fclose($db_settings_file);

// Now we connect with the correct username and password as we just reset it...
$hostname_db = "localhost";
$username_db = "root";
$password_db = $p1;
$db = mysql_pconnect($hostname_db, $username_db, $password_db) or trigger_error('Unable to connect to database server.');

// Create databases (zpanel_core, zpanel_roundcube and zpanel_hmail)
fwrite(STDOUT, "Creating databases...\r\n");
$sql = "CREATE DATABASE `zpanel_roundcube` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;";
$resault = @mysql_query($sql, $db) or die(mysql_error());
$sql = "CREATE DATABASE `zpanel_hmail` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;";
$resault = @mysql_query($sql, $db) or die(mysql_error());

// SQL script executor...

function RunSQL($sqlFileToExecute) {
    $f = fopen($sqlFileToExecute, "r+");
    $sqlFile = fread($f, filesize($sqlFileToExecute));
    $sqlArray = explode(';', $sqlFile);
    foreach ($sqlArray as $stmt) {
        if (strlen($stmt) > 3) {
            $result = mysql_query($stmt);
            if (!$result) {
                $sqlErrorCode = mysql_errno();
                $sqlErrorText = mysql_error();
                $sqlStmt = $stmt;
                break;
            }
        }
    }
}

// Get the 'true' server IP address.

function GetServerIPFromZWS() {
    $response = @file_get_contents('http://api.zpanelcp.com/ip.json');
    $decoded = json_decode($response, true);
    if ($decoded['ipaddress']) {
        return $decoded['ipaddress'];
    } else {
        return "127.0.0.1";
    }
}

// Insert Roundcube inital SQL into the zpanel_roundcube database.
mysql_select_db('zpanel_roundcube', $db);
$sqlFileToExecute = "C:/zpanel/panel/etc/apps/webmail/SQL/mysql.initial.sql";
$res = RunSQL($sqlFileToExecute);

// Insert hMailServer inital SQL into the zpanel_hmail database.
mysql_select_db('zpanel_hmail', $db);
$sqlFileToExecute = "c:/zpanel/bin/hmailserver/INSTALL/zpanel_hmail.sql";
$res = RunSQL($sqlFileToExecute);

// Set database back to ZPanel core to continue with the install.
@mysql_select_db('zpanel_core', $db);

// Update the current Apache Config to include the new Apache configs as part of the 'config_packs':-
$db_settings_file = fopen("c:/zpanel/bin/apache/conf/extra/httpd-vhosts.conf", "w");
fwrite($db_settings_file, "# Include the ZPanel managed http-vhosts file.\r\n");
fwrite($db_settings_file, "Include c:/zpanel/configs/apache/httpd-vhosts.conf");
fclose($db_settings_file);


// Ask user what domain they will be hosting the control panel on and then create it and add entries to the hosts file...
fwrite(STDOUT, "\r\n
##################################################\r\n
# ZPANELX CONFIG WIZARD FOR WINDOWS              #\r\n
##################################################\r\n
\r\n
Please enter details when asked below for the main\r\n
admin account.\r\n
\r\n
Full name: ");
$fullname = trim(fgets(STDIN));
fwrite(STDOUT, "Email address: ");
$email = trim(fgets(STDIN));
fwrite(STDOUT, "\r\n\r\n
Please now tell us where you want to access your\r\n
control panel from (eg. zpanel.yourdomain.com)\r\n
this should be a domain or sub-domain (FQDN).\r\n
\r\n\r\n
FQDN: ");
$location = trim(fgets(STDIN));
fwrite(STDOUT, "\r\n\r\n
Enter a password for the zadmin account: ");
$zadminpass = trim(fgets(STDIN));

fwrite(STDOUT, "\r\n\r\n");
@mysql_select_db('zpanel_core', $db);
exec("setso --set dbversion " . $version . "");
exec("setso --set zpanel_domain " . $location . "");
exec("setso --set email_from_address " . $email . "");
exec("setso --set email_from_address " . $email . "");
exec("setso --set daemon_lastrun 0");
exec("setso --set daemon_dayrun 0");
exec("setso --set daemon_weekrun 0");
exec("setso --set daemon_monthrun 0");
exec("setso --set apache_changed true");
exec("setso --set server_ip " . GetServerIPFromZWS() . "");
exec("setzadmin --set " . $zadminpass . "");

@mysql_select_db('zpanel_core', $db);
/** 
* NO LONGER NEEDED WITH setzadmin
*
* // We now update the MySQL user for the default 'zadmin' account..
* $log = "UPDATE x_accounts SET ac_pass_vc='" . md5($p2) . "', ac_created_ts=" . time() . " WHERE ac_user_vc='zadmin'";
* $do = @mysql_query($log, $db) or die(mysql_error());
*
**/

// Now we add the server admin to the server admin database table..
$sql = "UPDATE x_profiles SET ud_created_ts=" . time() . ", ud_fullname_vc='" . $fullname . "' WHERE ud_user_fk=1;";
mysql_query($sql, $db);

// Now we add the email address to zadmins account..
$sql = "UPDATE x_accounts SET ac_email_vc='" . $email . "' WHERE ac_id_pk=1;";
mysql_query($sql, $db);

// Create db.inc.php for Roundcube webmail:-
$db_settings_file = fopen("c:/zpanel/panel/etc/apps/webmail/config/db.inc.php", "w");
fwrite($db_settings_file, "<?php\n");
fwrite($db_settings_file, "\$rcmail_config = array();\n");
fwrite($db_settings_file, "\$rcmail_config['db_dsnw'] = 'mysql://root:" . $p1 . "@localhost/zpanel_roundcube';\n");
fwrite($db_settings_file, "\$rcmail_config['db_dsnr'] = '';\n");
fwrite($db_settings_file, "\$rcmail_config['db_max_length'] = 512000;\n");
fwrite($db_settings_file, "\$rcmail_config['db_persistent'] = FALSE;\n");
fwrite($db_settings_file, "\$rcmail_config['db_table_users'] = 'users';\n");
fwrite($db_settings_file, "\$rcmail_config['db_table_identities'] = 'identities';\n");
fwrite($db_settings_file, "\$rcmail_config['db_table_contacts'] = 'contacts';\n");
fwrite($db_settings_file, "\$rcmail_config['db_table_session'] = 'session';\n");
fwrite($db_settings_file, "\$rcmail_config['db_table_cache'] = 'cache';\n");
fwrite($db_settings_file, "\$rcmail_config['db_table_messages'] = 'messages';\n");
fwrite($db_settings_file, "\$rcmail_config['db_sequence_users'] = 'user_ids';\n");
fwrite($db_settings_file, "\$rcmail_config['db_sequence_identities'] = 'identity_ids';\n");
fwrite($db_settings_file, "\$rcmail_config['db_sequence_contacts'] = 'contact_ids';\n");
fwrite($db_settings_file, "\$rcmail_config['db_sequence_cache'] = 'cache_ids';\n");
fwrite($db_settings_file, "\$rcmail_config['db_sequence_messages'] = 'message_ids';\n");
fwrite($db_settings_file, "?>");
fclose($db_settings_file);

// Create hMailServer.INI for hMailServer MySQL configuration:-
$db_settings_file = @fopen("c:/zpanel/bin/hmailserver/Bin/hMailServer.ini", "w");
fwrite($db_settings_file, "\r\n
################################################################\r\n
# hMailServer configuration file                               #\r\n
# Automatically generated by ZPanelX installer for Windows     #\r\n
################################################################\r\n
\r\n");
fwrite($db_settings_file, "\r\n");
fwrite($db_settings_file, "[Directories]\r\n");
fwrite($db_settings_file, "ProgramFolder=c:\zpanel\bin\hmailserver\r\n");
fwrite($db_settings_file, "DataFolder=c:\zpanel\bin\hmailserver\Data\r\n");
fwrite($db_settings_file, "LogFolder=c:\zpanel\logs\r\n");
fwrite($db_settings_file, "TempFolder=c:\zpanel\bin\hmailserver\Temp\r\n");
fwrite($db_settings_file, "EventFolder=c:\zpanel\bin\hmailserver\Events\r\n");
fwrite($db_settings_file, "\r\n");
fwrite($db_settings_file, "[GUILanguages]\r\n");
fwrite($db_settings_file, "ValidLanguages=english,swedish\r\n");
fwrite($db_settings_file, "\r\n");
fwrite($db_settings_file, "[Database]\r\n");
fwrite($db_settings_file, "Type=MYSQL\r\n");
fwrite($db_settings_file, "Username=root\r\n");
fwrite($db_settings_file, "Password=" . $p1 . "\r\n");
fwrite($db_settings_file, "PasswordEncryption=0\r\n");
fwrite($db_settings_file, "Port=3306\r\n");
fwrite($db_settings_file, "Server=localhost\r\n");
fwrite($db_settings_file, "Database=zpanel_hmail\r\n");
fwrite($db_settings_file, "Internal=0\r\n");
fwrite($db_settings_file, "\r\n");
fwrite($db_settings_file, "[Security]\r\n");
fwrite($db_settings_file, "AdministratorPassword=" . md5($zadminpass) . "\r\n");
fclose($db_settings_file);

// Generate rcdn-key for BIND
$rcdn_key_file = @fopen("C:/zpanel/bin/bind/etc/key.conf", "w");
fwrite($rcdn_key_file, "key \"rndc-key\" {\r\n");
fwrite($rcdn_key_file, "	algorithm hmac-md5;\r\n");
fwrite($rcdn_key_file, "	secret \"" . md5(uniqid(rand(), 1)) . "\";\r\n");
fwrite($rcdn_key_file, "};");
fclose($rcdn_key_file);

fwrite(STDOUT, "\r\n
################################################################\r\n
# YOUR ZPANEL SERVER LOGIN DETAILS                             #\r\n
################################################################\r\n
\r
Your new MySQL 'root' password is: " . $p1 . "\r
Your new ZPanel details are as follows:-\r
URL: http://" . $location . "/\r
Username: zadmin\r
Password: " . $zadminpass . "\r\n
These details can also be found in c:\zpanel\login_details.txt\r
\r
Thank you for installing ZPanel!\r\n\r\n");

// Now we add a static route so the server admin can instantly access the control panel, and reboot Apache so VHOST is activated.
exec("c:/zpanel/bin/zpss/setroute.exe " . $location . "");

// Add the password details to a file in C:\zpanel
$login_details_file = fopen("c:/zpanel/login_details.txt", "w");
fwrite($login_details_file, "################################################################\r\n");
fwrite($login_details_file, "# YOUR ZPANEL SERVER LOGIN DETAILS                             #\r\n");
fwrite($login_details_file, "################################################################\r\n");
fwrite($login_details_file, "MySQL Root Password: " . $p1 . "\r\n");
fwrite($login_details_file, "ZPanel URL: http://" . $location . "\r\n");
fwrite($login_details_file, "ZPanel account: zadmin\r\n");
fwrite($login_details_file, "ZPanel password: " . $zadminpass . "\r\n");
fclose($login_details_file);
?>