#!/bin/bash

#Parametrage du help
if [ "$1" == "--help" ];then
	echo "salut"
	exit 0
fi

#Vérification existance dossier images
if [ -d "images/" ];then
	:
else
	echo "Le dossier images n'existe pas"
fi

#Verification existance d'image dans le dossier
cd images/
ls *.jpeg *.jpg *.png *.gif > nfile
if [ $count == 0 ];then
	echo "Aucune images"
fi
cd ..
