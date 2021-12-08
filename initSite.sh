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
    
    [Description]
    Ce script permet de générer un site vitrine contenant un carousel, des articles et des commentaires.
    
    [Options]
    -h | --help -> Affiche l'aide

    build | --build -> Permet de générer le site dans le répertoire courant
    
    build <chemin> -> Génére le site dans le répertoire spécifié
    
    -d | --debug -> Affiche les étape du script en décrivant leur éxécution
    
    --stats | generate_stats -> Affiche les statistiques du site
    
    add_image <image> ->Ajoute une image au dossier images/
    
    add_articles <Titre de l'article[,]Description de l'article> -> Ajoute un/des article(s) ⚠⚠⚠ Si vous devez mettre une chaine de caractere, vous devez utiliser des guillemets \"\" 
    
    add_comment <commentaire> -> permet d'ajouter un/des commentaires  ⚠⚠⚠ Si vous devez mettre une chaine de caractere, vous devez utiliser des guillemets \"\" 

    -auth <Nom d'utilisateur> <Mot de passe> -> Permet de s'authentifier et d'afficher le nom dans la page web

    add_user <Nom d'utilisateur> <Mot de passe> -> Génére un compte d'authentification
    "
    shift # past argument
    shift # past value
    ;;
    build|--build)
    #Vérification existance du dossier www
    if [ -d "www/" ];then
            read -r -p "Voulez-vous supprimer le répertoire \"www\" existant ? [oui/non] " response

            case "$response" in [yY][eE][sS]|[yY]|[oO]|[oO][uU][iI]) 
                    rm -R www/
                    ;;
            *)
                    echo "Le fichier n'a pas eté supprimé et pose conflit avec les commandes du programme. Veuillez le supprimer pour executer ce script"
                    exit 0
                    ;;
            esac
    fi
    if [ -z "$2" ];then
	    echo "Le site est généré dans le dossier www du répertoire courant"
    else
        cd $2
        if [ $? -ne 0 ];then
                echo "Impossible d'acceder à ${2}"
                exit 0
        fi
    fi
    #Verification de l'existance du dossier donnees sinon il le creer
    if [ -d "donnees/" ];then
	    2>/dev/null
    else
	    mkdir donnees > /dev/null
    fi
    #création répertoire www
    mkdir www > /dev/null
    logger -s 'création du répertoire www' > donnees/logs.log
    cd www
    mkdir css > /dev/null
    #Ajout du css
    echo "* {box-sizing: border-box;}

        .slider {
        width: 300px;
        text-align: center;
        overflow: hidden;
        }

        #slide {
        margin: 0 auto;
        align-items: center;
        justify-content: center;
        font-family: 'Ropa Sans', sans-serif;
        }

        .slides {
        display: flex;
        overflow-x: auto;
        scroll-snap-type: x mandatory;
        scroll-behavior: smooth;
        -webkit-overflow-scrolling: touch;
        
        }
        .slides::-webkit-scrollbar {
        width: 10px;
        height: 10px;
        }
        .slides::-webkit-scrollbar-thumb {
        background: black;
        border-radius: 10px;
        }
        .slides::-webkit-scrollbar-track {
        background: transparent;
        }
        .slides > div {
        scroll-snap-align: start;
        flex-shrink: 0;
        width: 300px;
        height: 300px;
        margin-right: 50px;
        border-radius: 10px;
        background: #eee;
        transform-origin: center center;
        transform: scale(1);
        transition: transform 0.5s;
        position: relative;
        
        display: flex;
        justify-content: center;
        align-items: center;
        font-size: 100px;
        }
        .slides > div:target {
        /*   transform: scale(0.8); */
        }
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
        img {
        object-fit: cover;
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        }

        .slider > a {
        display: inline-flex;
        width: 1.5rem;
        height: 1.5rem;
        background: white;
        text-decoration: none;
        align-items: center;
        justify-content: center;
        border-radius: 50%;
        margin: 0 0 0.5rem 0;
        position: relative;
        }
        .slider > a:active {
        top: 1px;
        }
        .slider > a:focus {
        background: #000;
        }

        /* Don't need button navigation */
        @supports (scroll-snap-type) {
        .slider > a {
        display: none;
        }
        }

        html, body {
        height: 100%;
        overflow: hidden;
        }

        .navbar, input, button, #form {
        text-align: left;  
        }

        .div > .article{
        margin-top: 20rem;
        }
        #commentaire{
        border: 2px solid;
        width:50%;
        }" > css/style.css
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
        <div class='slider' id='slide' align='center'  style='margin-top: 35px;'>
        
        
        <div class='slides'>
        
        
        </div>
        </div>

        <div class='article' align='center'>
        

        <span>
        

        </span>
        <h2> Commentaires </h2>
        <p id='commentaire'>
        
        </p>
        </div>
        </body>
        </html>" > index.html

    cd ..
    cd images/
    i=1
    l1=13
    l2=17
    for ls in *;do
        sed -i "$l1 i\<a href='#slide-$i'>$i</a>" ../www/index.html
        sed -i "$l2 i\<div id='slide-$i'><img src='../images/$ls' alt='$ls' width='300' height='400'></div>" ../www/index.html
        let "i+=1"
        let "l1+=1"
        let "l2+=2"
    done
    cd ..
    
    #Creation d'un fichier csv contenant des articles
    echo "Les personnalités nées un 11 janvier,Aja Naomi King : née le 11 janvier 1985. Connue pour avoir joué dans la série Murder <br> Yannick Andrei. DevOps Engineer chez GoodBarber. <br> Diego El Glaoui : compagnon de Iris Mittenaere
Pourquoi je suis toujours fatigué, Le manque de sommeil est souvent une cause de fatigue. Ce type de fatigue est normal et disparaît avec du repos." > donnees/Articles.csv
    
    #Affichage des article dans la page web
    FILE=donnees/Articles.csv
    OLDIFS=$IFS
    IFS=','
    [ ! -f $FILE ] && { echo "$FILE file not found"; exit 99; }
    while read titre description
    do
        sed -i "/<div class='article' align='center'>/ a\<h2>$titre</h2> $description" www/index.html
    done < $FILE
    IFS=$OLDIFS

    #Creation d'un fichier csv contenant des articles
    echo "Cool :)
Génial !!!
Merci j'ai appris quelque chose." > donnees/Commentaires.csv
    
    # Affichage des commentaires dans la page web
    FILE=donnees/Commentaires.csv
    [ ! -f $FILE ] && { echo "$FILE file not found"; exit 99; }
    while read commentaire
    do
        sed -i "/<p id='commentaire'>/ a\ $commentaire<br>" www/index.html
    done < $FILE
    # Générer compte Utilisateur
    echo "clement,monMDP
Hugo,1997pass" > donnees/User.csv
    shift # past argument
    shift # past value
    ;;


    -d|--debug)
    LIBPATH="$2"
    shift # past argument
    shift # past value
    ;;


    --stats|generate_stats)
    LIBPATH="$2"
    shift # past argument
    shift # past value
    ;;


    add_image)
    LIBPATH="$2"
    shift # past argument
    shift # past value
    ;;


    add_articles)
    #Ajout d'un article
    for var in "$@"
    do
        sed -i "1i\ $var
" donnees/Articles.csv
    done
    shift # past argument
    shift # past value
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
    shift # past argument
    shift # past value
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
            exit 0
        fi
    done < $FILE
    IFS=$OLDIFS
    echo "Erreur d'authentification !"
    exit 0
    shift # past argument
    shift # past value
    ;;


    add_comment)
    shift
    for var in "$@"
    do
        sed -i "1i\ $var <br>" donnees/Commentaires.csv
        sed -i "/<p id='commentaire'>/ a\ $var<br>" www/index.html  
    done
    shift # past value
    ;;


    ?)
    echo "Le parametre ${2} n'existe pas"
    shift # past argument
    shift # past value
    ;;


    --default)
    DEFAULT=YES
    shift # past argument
    ;;

esac
done