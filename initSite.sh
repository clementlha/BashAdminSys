#!/bin/bash

#Vérification connexion internet
echo -e "GET https://google.fr" | nc google.fr 80 > /dev/null 2>&1
if [ $? -ne 0 ];then
	echo "Vous n'avez pas internet"
	exit 0
fi

#Vérification existance dossier images
if [ -d "images/" ];then
	#Verification existance d'image dans le dossier
	cd images/
	count=`ls -1 *.jpeg *.png 2>/dev/null | wc -l`
	if [ $count == 0 ];then
        	echo "Il n'y a aucune images dans le dossier images"
                exit 0
	fi
	cd ..
else
	echo "Le dossier images n'existe pas"
        exit 0
fi

while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -h|--help)
    echo " **** Script Administration Systeme et Réseaux **** 
    
    [Auteurs]
    Clément L'HARIDON et Hugo RAGIOT

    [Description]
    Ce script permet de générer un site vitrine contenant un carousel, des articles et des commentaires.
    
    [Options]
    -h | --help -> Affiche l'aide

    build | --build -> Permet de générer le site dans le répertoire courant
    
    build <chemin> -> Génére le site dans le répertoire spécifié
    
    -d | --debug -> Affiche les étape du script en décrivant leur éxécution
    
    --stats | generate_stats -> Affiche les statistiques du site
    
    add_image <image> -> Ajoute une image préalablement ajouté au répertoire \"images\" dans la page web
    
    add_articles <Titre de l'article[,]Description de l'article> -> Ajoute un/des article(s) ⚠⚠⚠ Si vous devez mettre une chaine de caractere, vous devez utiliser des guillemets \"\" 
    
    add_comment <commentaire> -> permet d'ajouter un/des commentaires  ⚠⚠⚠ Si vous devez mettre une chaine de caractere, vous devez utiliser des guillemets \"\" 

    -auth <Nom d'utilisateur> <Mot de passe> -> Permet de s'authentifier et d'afficher le nom dans la page web

    add_user <Nom d'utilisateur> <Mot de passe> -> Permet de générer un compte d'authentification
    "
    shift 
    shift 
    ;;
    build|--build)
    #Verification de l'existance du dossier donnees sinon il le creer
    if [ -d "donnees/" ];then
	    2>/dev/null
    else
	    mkdir donnees > /dev/null
    fi
    # Fichier qui contient les différentes étapes du script
    touch donnees/messages.csv
    LOG=donnees/messages.csv
    if [ $2 = "-h" | $2 = "--help" | $2 = "--build" | $2 = "build" | $2 = "--debug" | $2 = "-d" | $2 = "--stats" | $2 = "generate_stats" | $2 = "add_images" | $2 = "add_articles" | $2 = "add_comment" | $2 = "-auth" | $2 = "add_user" |];then
        echo "Vous ne pouvez pas mettre une deuxieme option apres \"build\" !"
        exit 0
    fi
    #Vérification existance du dossier www
    if [ -d "www/" ];then
            read -r -p "Voulez-vous supprimer le répertoire \"www\" existant ? [oui/non] " response

            case "$response" in [yY][eE][sS]|[yY]|[oO]|[oO][uU][iI]) 
                    rm -R www/
                    echo "$(date +%c) : Suppression du répertoire \"www\"" >> $LOG
                    echo "$(date +%c) : Création du nouveau site web" >> $LOG
                    ;;
            *)
                    echo "Le fichier n'a pas eté supprimé et pose conflit avec les commandes du programme. Veuillez le supprimer pour executer ce script"
                    echo "$(date +%c) : ⚠⚠⚠ Conflit ⚠⚠⚠ : dossier www existant" >> $LOG
                    exit 0
                    ;;
            esac
    fi
    
    #création répertoire www
    mkdir www > /dev/null
    echo "$(date +%c) : Création du répertoire www" >> $LOG
    cd www
    mkdir css > /dev/null
    echo "$(date +%c) : Création du répertoire css dans www" >> ../$LOG
    #Ajout du css
    echo "* {box-sizing: border-box;}

    .author-info {
    background: rgba(0, 0, 0, 0.75);
    color: white;
    padding: 0.75rem;
    text-align: center;
    position: absolute;
    bottom: 0;
    left: 0;
    width: 100%;
    margin: 0;
    }
    .author-info a {
    color: white;
    }

    html, body {
    overflow: auto;
    align-items: center;
    }

    .column {
    float: left;
    width: 25%;
    padding: 5px;
    }
    #img{height:400px;overflow:auto}
    /* Clearfix (clear floats) */
    .row::after {
    content: "";
    clear: both;
    display: table;
    }
    .crop {
    width: 350px;
    height: 350px;
    object-fit: cover;
    }" > css/style.css
    echo "$(date +%c) : Ajout du code css dans le fichier \"style.css\" " >> ../$LOG
    #Ajout du html
    echo "<!DOCTYPE html>
        <html lang='fr'>
        <head>
        <meta charset='UTF-8'>
        <meta http-equiv='X-UA-Compatible' content='IE=edge'>
        <meta name='viewport' content='width=device-width, initial-scale=1.0'>
        <title>AdminSys blog</title>
        <link href='css/style.css' rel='stylesheet'>
        </head>
        <body>
          <div class='row' id='img'>
            

          </div>

        <div class='article' align='center'>
        

        <span>
        

        </span>
        <h2> Commentaires </h2>
        <p id='commentaire'>
        
        </p>
        </div>
        <h5 i='createur'></5>
        </body>
        </html>
" > index.html
    echo "$(date +%c) : Ajout du code html dans le fichier \"index.html\"" >> ../$LOG
    cd ..
    cd images/
    for ls in *;do  
        sed -i "/<div class='row' id='img'>/ a\ <div class='column'><img class='crop' src='../images/$ls' alt='$ls' style='width:100%'></div>" ../www/index.html
        echo "$(date +%c) : Ajout de l'image \"$ls\" dans la page index.html" >> ../$LOG
    done
    cd ..
    
    #Creation d'un fichier csv contenant des articles
    echo "Les personnalités nées un 11 janvier,Aja Naomi King : née le 11 janvier 1985. Connue pour avoir joué dans la série Murder <br> Yannick Andreï. DevOps Engineer chez GoodBarber. <br> Diego El Glaoui : compagnon de Iris Mittenaere
Pourquoi je suis toujours fatigué, Le manque de sommeil est souvent une cause de fatigue. Ce type de fatigue est normal et disparaît avec du repos." > donnees/Articles.csv
    echo "$(date +%c) : Création du fichier Articles.csv dans le répertoire donnees, contenant les articles " >> $LOG
    #Affichage des article dans la page web
    FILE=donnees/Articles.csv
    OLDIFS=$IFS
    IFS=','
    [ ! -f $FILE ] && { echo "$FILE file not found"; exit 99; }
    while read titre description
    do
        sed -i "/<div class='article' align='center'>/ a\<h2>$titre</h2> $description" www/index.html
        echo "$(date +%c) : Ajout dans la page index.html les articles stocker dans \"Articles.csv\"" >> $LOG
    done < $FILE
    IFS=$OLDIFS

    #Creation d'un fichier csv contenant des articles
    echo "Cool :)
Génial !!!
Merci j'ai appris quelque chose." > donnees/Commentaires.csv
    echo "$(date +%c) : Création du fichier Commentaires.csv dans le répertoire donnees, contenant les commentaires " >> $LOG
    # Affichage des commentaires dans la page web
    FILE=donnees/Commentaires.csv
    [ ! -f $FILE ] && { echo "$FILE file not found"; exit 99; }
    while read commentaire
    do
        sed -i "/<p id='commentaire'>/ a\ $commentaire<br>" www/index.html
        echo "$(date +%c) : Ajout dans la page index.html les commentaires stocker dans \"Commentaires.csv\"" >> $LOG
    done < $FILE
    # Générer compte Utilisateur
    echo "clement,monMDP
Hugo,1997pass" > donnees/User.csv
    echo "$(date +%c) : Création du fichier User.csv dans le répertoire donnees, contenant les comptes utilisateurs " >> $LOG
    

    #Vérification parametre build <répertoire>
    if [ -z "$2" ];then
	    echo "Le site est généré dans le répertoire www du répertoire courant"
        firefox ./www/index.html
        echo "$(date +%c) : Ouverture de la page index.html dans le navigateur firefox" >> $LOG
    else
        (cp -r www/ echo $2 | sed 's/\.\///' | tr -d '\n') 2> /dev/null
        (cp -r images/ echo $2 | sed 's/\.\///' | tr -d '\n') 2> /dev/null
        (cp -r donnees/ echo $2 | sed 's/\.\///' | tr -d '\n') 2> /dev/null
        rm -R www/ 2> /dev/null
        rm -R donnees/ 2> /dev/null
        if [ $? -ne 0 ];then
                echo "Impossible d'acceder à ${2}"
                exit 0
        fi
        firefox $2www/index.html
    fi
    shift 
    shift 
    ;;


    -d|--debug)
    # Affichage du fichier contenant les étapes du script
    cat donnees/messages.csv
    shift 
    shift 
    ;;


    --stats|generate_stats)
    # Affichage nombre d'utilisateur dans la base
    nbuser=$(wc -l donnees/User.csv)
    nbuser=$(echo $nbuser | sed 's/donnees\/User.csv//')
    echo "Il y a ${nbuser}utilisateurs enregistrés dans la base"
    # Affichage nombre d'article
    nbarticle=$(wc -l donnees/Articles.csv)
    nbarticle=$(echo $nbarticle | sed 's/donnees\/Articles.csv//')
    echo "Il y a ${nbarticle}articles enregistrés dans la base"
    # Affichage nombre de commentaire
    nbcomment=$(wc -l donnees/Commentaires.csv)
    nbcomment=$(echo $nbcomment | sed 's/donnees\/Commentaires.csv//')
    echo "Il y a ${nbcomment}commentaires enregistrés dans la base"
    # Affichage nombre d'image
    nbimage=0
    cd images/
    for ls in *;do  
        let "nbimage++"
    done
    cd ..
    echo "Il y a ${nbimage} images dans le répertoire \"images\""
    shift 
    shift 
    ;;


    add_image)
    cd images/
    if [ -e $2 ]
    then
        sed -i "/<div class='row' id='img'>/ a\ <div class='column'><img src='../images/$2' alt='$2' style='width:100%'></div>" ../www/index.html
    else
        echo "L'image $2 n'est pas disponible dans le répertoire \"images\". Veuillez l'ajouter et réésayer."
        cd ..
        exit 0
    fi
    cd ..
    shift 
    shift 
    ;;


    add_articles)
    #Ajout d'un article
    for var in "$@"
    do
        sed -i "1i\ $var
" donnees/Articles.csv
    done
    shift 
    shift 
    ;;


    add_user)
    #Vérification que le Nom d'utilisateur n'existe pas déjà
    FILE=donnees/User.csv
    OLDIFS=$IFS
    IFS=','
    [ ! -f $FILE ] && { echo "$FILE file not found"; exit 99; }
    while read user pass
    do
        if [ $user = "$2" ];then
            echo "L'utilisateur existe déjà dans la base de données"
            exit 0
        fi   
    done < $FILE
    IFS=$OLDIFS
    sed -i "1i\\$2,$3
" donnees/User.csv
    exit 1
    shift 
    shift 
    ;;


    -auth)
    #Permet de s'authentifier et d'afficher le nom dans la page web
    FILE=donnees/User.csv
    OLDIFS=$IFS
    IFS=','
    [ ! -f $FILE ] && { echo "$FILE file not found"; exit 99; }
    while read user pass
    do
        if [ "$user" = "$2" ] && [ "$pass" = "$3" ];then
            echo "Vous êtes authentifié avec le compte $2"
        fi
    done < $FILE
    IFS=$OLDIFS
    echo "Erreur d'authentification !"
    exit 0
    shift 
    shift 
    ;;


    add_comment)
    shift
    for var in "$@"
    do
        sed -i "1i\ $var <br>" donnees/Commentaires.csv
        sed -i "/<p id='commentaire'>/ a\ $var<br>" www/index.html  
    done
    shift 
    ;;


    ?)
    echo "Le parametre ${2} n'existe pas"
    shift 
    shift 
    ;;


    --default)
    DEFAULT=YES
    shift 
    ;;

esac
done