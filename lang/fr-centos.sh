#!/bin/bash
osdetect="Detection"
installroot="installation échoué! Pour installer, vous devez être connecté en tant que 'root', s'il vous plaît essayer à nouveau"
upgraderoot="La mise à niveau a échoué! Pour mettre à niveau, vous devez être connecté en tant que 'root', s'il vous plaît essayer à nouveau"
panel='Vous semblez avoir un panneau de contrôle est déjà installé sur votre serveur; Ce programme d installation\n'
panel=$panel'est conçu pour installer et configurer ZPanel sur une installation du système d exploitation propre seulement!\n\n'
panel=$panel'SVP réinstaller votre système d exploitation avant d installer en utilisant ce script.'
installsyserror="Désolé, cette installation ne prend en charge l'installation de ZPanel uniquement sur"
upgradesyserror="Désolé, ce script de mise à jour de Zpanel et uniquement pour"
gpl=' Bienvenue sur l installateur officiel de ZPaneX pour CentOS 6.4, 6.5 \n\n'
gpl=$gpl' SVP assurez-vous que votre fournisseur de VPS na pas pré-installé \n'
gpl=$gpl' les paquets requis par ZPanelX. \n\n'
gpl=$gpl' Si vous installez sur une machine physique où le système d exploitation \n'
gpl=$gpl' a été installé par vous-même SVP assurez-vous que vous avez installés \n'
gpl=$gpl' CentOS sans paquets supplémentaires. \n\n'
gpl=$gpl' Si vous avez sélectionné des options supplémentaires au cours de l installation de CentOS \n'
gpl=$gpl' SVP envisager de réinstaller sans ces options. \n'
errorzpversion="Votre version de ZPanel déjà mis à jour."
