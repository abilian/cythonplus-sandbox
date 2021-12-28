# Benchmark d'un framework basé sur le modèle acteurs

## Objectif

Le logiciel Whitenoise est un composat classique d'une configuration python utilisant Flask ou Django. Whitenoise intercepte et répond pour les reqûetes concernant des fichiers statiques. Whitenoise accélère ces requêtes en utilisant un cache des entêtes et des statitiques des fichiers (taille, dernière date de modification). Cet outil est entièrement écrit en python.

Gunicorn est un serveur HTTP (WSGI), réputé rapide écrit en python. Gunicorn peut utiliser plusieurs mode de parallélisation dont une mode prefork.

L'objectif est de fournir un serveur basé sur Cython+ et le modèle acteur pour réaliser le même service que la combinaison de ces deux outils et de comparer les performances obtenues.

Whitenoise: https://github.com/evansd/whitenoise
Gunicorn: https://github.com/benoitc/gunicorn


## Actor Static Server

Cet applicatif remplit les deux fonctions:

  - serveur web HTTP 1.1
  - accélération de la distribution de fichiers statiques

Le serveur web utilise le modèle acteur pour paralléliser les réponses aux requêtes sur les coeurs disponibles.
L'index des fichiers statiques reprend les fonctionalités de Whitenoise.


## Installation et test

- Prérequis:

    - serveur Linux, environnement de compilation c++ (testé sur Ubuntu LTS 2020)
    - python 3.8+
    - cython+ installé (https://lab.nexedi.com/nexedi/cython)

- dans le répertoire benchmark:


  Le script `constants.sh` contient différents paramètres de configuration de l'environnement de test. Par défaut l'installation utilise le répertoire `~/tmp` de l'utilisateur courant.

  Le script `all_install.sh` chaîne les scripts:

  - `install_packages.sh`, installation de gunicorn, flask (v1.1), whitenoise (5.30), wrk (test de charge du serveur).
  - `fetch_many_images.sh`, téléchargement d'une banque d'images de test depuis http://imagedatabase.cs.washington.edu/groundtruth/
  - `copy_750_images.sh`, copie les images dans un site de test local


     ./all_install.sh


  Le script `all_build_bench.sh` chaîne les scripts:

  - `build_gu_wn_python.sh`, `build_actor_static_server.sh` : installation et compilation des logiciels.
  - `bench_gu_wn_python.sh`, `bench_actor_static_server.sh` : lancement du comparatif.


     ./all_build_bench.sh


  Les tests consistent à envoyer des requ^tes sur des fichiers statiques aléatoires pendant 30 secondes et à comparer le nombre de requêtes servies par les différentes configurations. Les résultats sont disponibles dans le dossier `benchmars/results`.
