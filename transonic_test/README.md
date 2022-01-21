# Backend CythonPlus pour Transonic

## Transonic

Transonic [https://transonic.readthedocs.io/en/latest/] est un projet qui vise
à optimiser les performances d'un code python au moyen de décorateurs placés devant
ses fonctions, classes ou méthodes.
Transonic réalise les optimisations via des backends Cython, Pythran ou Numba.


## Backend CythonPlus pour Transonic

Le dossier `transonic` de ce répertoire contient une version de transonic intégrant
un backend pour CythonPlus.
Le backend CythonPlus génère des fichiers `.pxd` et `.pyx` contenant une base de code
destinée au compilateur CythonPlus.


## Fonctionnalités

- Le décorateur à placer devant les fonctions ou classes à convertir : `@boost`.
- Les classes sont converties par défaut en `cypclass` simples, pour déclarer une
  `cypclass activable`, décorer avec `@boost(activable=True)`.
- Pour déclarer une fonction `nogil`, décorer avec `@boost(nogil=True)`.
- Lancer la commande:

   ```
   transonic nom_du_fichier.py -b cythonplus --no-compile
   ```

- Le résultat est dans le dossier local `__cythonplus__`

- Exemple: voir dans le dossier `exemple`.


## Limitations du backend CythonPlus

- Types

    Le code CythonPlus généré par le backend s'appuie sur les annotations (types) du
    code python pour définir les type statiques de CythonPlus. Les types reconnus par
    le backend sont les types Cython de base et les types définis dans le fichier
    cythonplus.toml. Pour utiliser des types personnalisés (des cypclass par exemples),
    il faut mettre à jour ce fichier.


- Adaptation du code python

    Le backend fait une conversion du code marqué par les décorateurs `@boost` et
    laisse inchangé le reste du code Python. Il est probable que le code Python inchangé
    nécessite des adaptations pour s'interfacer avec le code CythonPlus


- Doublons d'initialisation

    Le backend génère des initialisations par défaut pour les attributs et les variables
    locales. Il est probable que ces initialisations nécessitent une adaptation par
    rapport au initialisations préexistantes du code Python.


- Changement de syntaxe et de dépendances

    Bien que proche de Python, la syntaxe de CythonPlus diffère de celle de Python. De
    plus certaines classes Python ont des équivalents CythonPlus ayant des noms
    différent et des méthodes différentes. Ce backend CythonPlus ne gère pas ces
    changements entre Python et CythonPlus.
