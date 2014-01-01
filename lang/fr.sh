#!/bin/bash
txt_osdetect="Detection"
txt_installroot="installation échoué! Pour installer, vous devez être connecté en tant que 'root', s'il vous plaît essayer à nouveau"
txt_upgraderoot="La mise à niveau a échoué! Pour mettre à niveau, vous devez être connecté en tant que 'root', s'il vous plaît essayer à nouveau"
txt_panel='Vous semblez avoir un panneau de contrôle est déjà installé sur votre serveur; Ce programme d installation\n'
txt_panel=$txt_panel'est conçu pour installer et configurer ZPanel sur une installation du système d exploitation propre seulement!\n\n'
txt_panel=$txt_panel'SVP réinstaller votre système d exploitation avant d installer en utilisant ce script.'
txt_installsyserror="Désolé, cette installation ne prend en charge l'installation de ZPanel uniquement sur"
txt_upgradesyserror="Désolé, ce script de mise à jour de Zpanel et uniquement pour"
txt_zpanelnotfound="ZPanel n a pas été détecté sur ce serveur, le script de mise à niveau ne peut donc pas continuer!"
txt_upgrade1="Le script de mise à niveau ZPanel est maintenant prêt à commencer, nous vous recommandons avant"
txt_upgrade2="de continuer de faire une sauvegarde de votre serveur ZPanel pour permettre une restauration"
txt_upgrade3="au cas où quelque chose se passe mal pendant le processus de mise à jour !"
txt_upgrade4="Voulez-vous continuer la mise à jour maintenant (o/n) ?"
txt_upgrade5="SVP fournir votre mot de passe actuel de Mysql root (qui peut être trouve dans /etc/zpanel/panel/cnf/db.php)"
txt_upgrade6="ZPanel va maintenant être mis à jour, êtes vous sûr de vouloir continuer (o/n) ?"
txt_upgrade7="S'il vous plaît lire et noter les erreurs de mise à jour et les messages ci-dessous :"
txt_upgrade8="Redémarrez votre serveur maintenant pour compléter la mise à jour (o/n) ? "
txt_yes="Oo"
txt_no="Nn"
txt_gpl1=" Bienvenue sur l installateur officiel de ZPaneX pour"
txt_gpl=' SVP assurez-vous que votre fournisseur de VPS na pas pré-installé \n'
txt_gpl=$txt_gpl' les paquets requis par ZPanelX. \n\n'
txt_gpl=$txt_gpl' Si vous installez sur une machine physique où le système d exploitation \n'
txt_gpl=$txt_gpl' a été installé par vous-même SVP assurez-vous que vous avez installés \n'
txt_gpl=$txt_gpl' votre système sans paquets supplémentaires. \n\n'
txt_gpl=$txt_gpl' Si vous avez sélectionné des options supplémentaires au cours de \n'
gpl=$gpl' l installation de votre système \n'
gpl=$gpl' SVP envisager de réinstaller sans ces options. \n'
txt_errorzpversion="Votre version de ZPanel est déjà à jour."
txt_installcontinue="Voulez-vous continuer (o/n)?"
txt_apparmor="Désactivation et supression d AppArmor, patientez SVP ..."
txt_logdebug="Génération journal d'installation et des informations de débogage ..."
txt_downloadzp="Téléchargement de ZPanel, SVP patientez, cela peut prendre plusieurs minutes, le programme d'installation continuera une fois que cette opération sera terminée!"
txt_enterfqdn="Entrez le nom de domaine complet du serveur (example: zpanel.votredomaine.com)"
txt_mysqlpassworderror="Entez Votre Mot de Passe actuel pour l'utilisateur root de mysql"
txt_enterip="Entrez l'IP public (externe) du serveur"
txt_email="Entrez votre addrese email"
txt_installok="ZPanel est maintenant prêt à être installer, voulez-vous continuer (o/n)"
txt_aptitude="Mise à jour de Repos Aptitude"
txt_zadminpassword="Mot de Passe zadmin"
txt_mysqlrootpassword="Mot de passe MySQL Root"
txt_mysqlpostfixpassword="Mot de Passe MySQL Postfix"
txt_ipaddress="Adresse IP"
txt_paneldomain="Domaine du Paneau"
txt_passwords="Mots de Passe"
txt_finishinstall1="Félicitations ZpanelX a été installé sur votre"
txt_finishinstall2="serveur. SVP consulter le fichier journal laissé dans /root/ pour"
txt_finishinstall3="les erreurs rencontrées lors de l'installation."
txt_finishinstall4="Enregistrer ces informations dans un endroit sûr :"
txt_finishinstall5="Nom d utilisateur ZPanelX"
txt_finishinstall6="Mot de passe ZPanelX"
txt_finishinstall7="La connexion a votre espace Web ZPanelX est accessible via l IP de votre serveur"
txt_finishinstall8="dans votre navigateur web"
txt_finishinstall9="Redémarrez votre serveur maintenant pour terminer l'installation (o/n) ?"
