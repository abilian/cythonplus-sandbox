# Benchmark d'un framework basé sur le modèle acteurs

## Objectif

ActorStaticFileServer vise à répliquer les fonctionnalités de deux outils python fréquemment associés: Gunicorn et Whitenoise.

- Le logiciel Whitenoise est un composant classique d'une configuration python utilisant Flask ou Django. Whitenoise répond aux requêtes de fichiers statiques. Whitenoise accélère ces transactions en utilisant un cache des entêtes HTTP et des statistiques des fichiers (taille, dernière date de modification). Cet outil est entièrement écrit en python.

- Gunicorn est un serveur HTTP (WSGI), réputé rapide, écrit en python. Gunicorn peut utiliser plusieurs modes de parallélisation, notamment des workers (prefork).

L'objectif est de fournir un serveur basé sur Cython+ et le modèle acteur pour réaliser le même service que la combinaison de ces deux outils et de comparer les performances obtenues.

Whitenoise: https://github.com/evansd/whitenoise

Gunicorn: https://github.com/benoitc/gunicorn


## ActorStaticFileServer

Cet applicatif remplit les deux fonctions:

  - serveur web HTTP/1.1 ou HTTP/1.0
  - accélération de la distribution de fichiers statiques.

Le serveur web utilise le modèle acteur pour paralléliser les réponses aux requêtes.
L'index des fichiers statiques reprend les fonctionalités de Whitenoise. L'analyse initiale du dossier des fichiers statique est parallélisée selon le modèle acteur.


## Installation et test

- Prérequis:
    - serveur Linux, environnement de compilation c++ GNU (testé sur Ubuntu LTS 2020),
    - python 3.8+,
    - cython+ installé (https://lab.nexedi.com/nexedi/cython).


- Installation:

  L'installation et les tests sont réalisés par les scripts présents dans le dossier `benchmark.

  - Le script `constants.sh` contient différents paramètres de configuration de l'environnement de test. Par défaut l'installation utilise le répertoire `~/tmp` de l'utilisateur courant.

  Le script `all_install.sh` chaîne les scripts:

  - `install_packages.sh`, installation de gunicorn, flask (v1.1), whitenoise (5.30), wrk (test de charge du serveur).
  - `fetch_many_images.sh`, téléchargement d'une banque d'images de tests depuis http://imagedatabase.cs.washington.edu/groundtruth/
  - `copy_750_images.sh`, copie les images dans un site de test local


     ./all_install.sh


- Benchmark

  Le script `all_build_bench.sh` chaîne tous les scripts trouvés dans le sous-dossier `bench_scripts`:

  - `bench_actor_static_server_auto.sh`, `bench_actor_static_server_workers_1.sh`, ...


     ./all_build_bench.sh


  Les tests consistent à envoyer des requêtes de fichiers statiques aléatoires (seed de départ identique) pendant 30 secondes. Les résultats des tests sont disponibles dans le dossier `benchmark/results`. Le bilan final de `wrk` permet la comparaison des performances des différentes configurations.
