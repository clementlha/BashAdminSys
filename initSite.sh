#!/bin/bash

#Parametrage du help
if [ "$1" == "--help" ];then
	echo "salut"
	exit 0
fi

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
	fi
	cd ..
else
	echo "Le dossier images n'existe pas"
fi

# Génération du site
if [ "$1" == "build" ];then
  LOG=Etape.log

  mkdir www > /dev/null
  echo -n "le 'date +%d/%m/%Y' à 'date +%H:%M:%S' : Création du dossier \"www\" dans le répertoire courant" | tee -a $LOG
  cd www
  mkdir css > /dev/null
  echo "body {
    height: 600px;
    margin: 0;
    display: grid;
    grid-template-rows: 500px 100px;
    grid-template-columns: 1fr 30px 30px 30px 30px 30px 1fr;
    align-items: center;
    justify-items: center;
  }

  main#carousel {
    grid-row: 1 / 2;
    grid-column: 1 / 8;
    width: 100vw;
    height: 500px;
    display: flex;
    align-items: center;
    justify-content: center;
    overflow: hidden;
    transform-style: preserve-3d;
    perspective: 600px;
    --items: 5;
    --middle: 3;
    --position: 1;
    pointer-events: none;
  }

  div.item {
    position: absolute;
    width: 300px;
    height: 400px;
    background-color: coral;
    --r: calc(var(--position) - var(--offset));
    --abs: max(calc(var(--r) * -1), var(--r));
    transition: all 0.25s linear;
    transform: rotateY(calc(-10deg * var(--r)))
      translateX(calc(-300px * var(--r)));
    z-index: calc((var(--position) - var(--abs)));
  }

  div.item:nth-of-type(1) {
    --offset: 1;
    background-color: #90f1ef;
  }
  div.item:nth-of-type(2) {
    --offset: 2;
    background-color: #ff70a6;
  }
  div.item:nth-of-type(3) {
    --offset: 3;
    background-color: #ff9770;
  }
  div.item:nth-of-type(4) {
    --offset: 4;
    background-color: #ffd670;
  }
  div.item:nth-of-type(5) {
    --offset: 5;
    background-color: #e9ff70;
  }

  input:nth-of-type(1) {
    grid-column: 2 / 3;
    grid-row: 2 / 3;
  }
  input:nth-of-type(1):checked ~ main#carousel {
    --position: 1;
  }

  input:nth-of-type(2) {
    grid-column: 3 / 4;
    grid-row: 2 / 3;
  }
  input:nth-of-type(2):checked ~ main#carousel {
    --position: 2;
  }

  input:nth-of-type(3) {
    grid-column: 4 /5;
    grid-row: 2 / 3;
  }
  input:nth-of-type(3):checked ~ main#carousel {
    --position: 3;
  }

  input:nth-of-type(4) {
    grid-column: 5 / 6;
    grid-row: 2 / 3;
  }
  input:nth-of-type(4):checked ~ main#carousel {
    --position: 4;
  }

  input:nth-of-type(5) {
    grid-column: 6 / 7;
    grid-row: 2 / 3;
  }
  input:nth-of-type(5):checked ~ main#carousel {
    --position: 5;
  }" > css/style.css

  echo '<!DOCTYPE html>
  <html lang="en">
  <head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
    <link href="css/style.css" rel="stylesheet">	
  </head>
  <body>
    <body>
      
      
      

      <main id="carousel">
      
        


      </main>
    </body>
  </body>
  </html>' > index.html

  cd ..
  cd images/
  i=1
  for ls in *;do
    sed -i "14i\<input type='radio' name='position' />" ../www/index.html
    sed -i "22i\<div class='item'><img src='../images/$ls' alt='$ls' width='300' height='400'></div>" ../www/index.html
    echo $i
    let "i+=1"
  done
  cd ..
  #rm -R /Template/images/
  #cp -f /images/ Template/images/
  firefox ./www/index.html
fi

# Affichage des étapes du script (logs)
if [ "$1" == "--debug" ];then
	cat Etape.log
fi
