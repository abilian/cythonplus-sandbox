## Eléments pour un langage "Cython++"

Syntaxe possible pour un nouveau langage... ayant la syntaxe de Python.

Idée directrice: privilégier hints Python et décorateurs aux syntaxes issues de Cython
et C++, afin d'avoir une bonne portabilité de code et une base d'utilisateurs élargie.
Rester proche de la syntaxe de Python permettrait de bénéficier des outils existants
(AST, pylint, ...)

-   Utilisation de décorateurs pour les déclarations "multithreading",
-   déclaration de types plus proche de `type hints` que du C/C++,
-   utilisation de fonction plutôt que de mots clés pour `consume`, `iso`, ...

Par rapport à un code Python natif, on choisit de rendre obligatoire:

-   usage systématique des `type hints` Python,
-   toute variable doit être déclarée (voire initialisée).

Par rapport à Cython+ actuel:

-   Un compilateur "indépendant" permettrait de s'affranchir de la contrainte de
    doubler toute la syntaxe pour avoir concomitamment les versions Python et Cython+
    (Str et str, cyplist et list, ...)
-   Syntaxe Python, notamment compréhension de liste et dictionnaire, methodes
    `sort`, `reverse` et fonction `sum`. (Peut-être sur liste ou iterateur, avec
    imbrication possible ou non, variable internes d'itération possiblement déclarée
    "à l'exterieur de la boucle"). Principe: il ne s'agit pas de viser une exhaustivité
    des fonctionnalités de Python, mais de minimiser les retouches à faire à un code
    porté.
-   La fonction `print()` est un cas particulier: cette fonction serait moins
    utilisée dans le code effectivement en production que sur les exemples et démos ?

## Concept de base

Un code Python simple pourrait être porté en Cython++ via l'ajout d'un décorateur.
Une classe non décorée `cypclass` serait une classe non éligible à être un acteur,
mais néanmoins `nogil` et statiquement typée (en bref: du Cython).

Corollaire sur la portabilité Python -> Cython++:
_Un code "Cython++" devrait pouvoir être compris par CPython, (moyennant la définition
de décorateurs factices et d'alias de types)._ Cette règle viserait à assurer une
bonne portabilité de Python vers Cython++, même si tout code Python ne serait pas
compatible avec Cython++.

## Essai sur les exemples du tutoriel

Pour obtenir un code Python légal, on utilise ici un module fake.py qui permet de
définir des classes et méthode en lieu et place d'implémentation d'un compilateur
spécifique.

Les annotations Python mises en oeuvre utilisent notamment Annotated (défini ici:
<https://peps.python.org/pep-0593/https://peps.python.org/pep-0593/>) qui permet d'asssocier à un type une série d'arguments, par exemple un range de validité, une classe personalisée,
ou autre. En l'occurence, cela permet de représenter le type `lock` du Cython+ actuel.

### Exemple "Hello World"

**Version "Cython++"**, compatible Python :

```Python
from fake import cypclass
```

> `cypclass`est ici un décorateur sans effet réel, permettant juste à CPython de
>  valider le code. Pour la version Cython++, il faudrait évidemment retirer cette
>   ligne.

```Python
@cypclass
class HelloWorld:
    message: str

    def __init__(self):
        self.message = "Hello World!"

    def print_message(self) -> None:  # option: "-> None" par défaut ?
        print(self.message)


def main():
    hello: HelloWorld

    hello = HelloWorld()
    hello.print_message()
```

* * *

**Version Cython+ commentée:**

    from libc.stdio cimport printf
    from helloworld.stdlib.string cimport Str

> Aucun import ici: les équivalents aux classes Python de base seraient
> importés systématiquement sans avoir à les déclarer (list, dict, str, print...)
>
>  Dans Cython et Cython+, les types scalaires (la plupart...) sont déjà importés
>  silencieusement (int, float, ...)

```Python
cdef cypclass HelloWorld:
```

> remplacé par `@cypclass`

```Python
    Str message
```

> => syntaxe Python `message: str`

```Python
    __init__(self):
```

> garder le `def` même pour `__init__`

```Python
        self.message = Str("Hello World!")
```

> interpreter `""` directement comme un `Str`

```Python
    void print_message(self):
```

> préferer la syntaxe Python `-> None`. Il est acceptable de rendre les annotation
> "typing" obligatoires.

```Python
        printf("%s\n", self.message.bytes())
```

> il est souhaitable que print deviennt un alias de printf (ou progressiveent d'une
> implémentation plus proche de `print`, aka saut de ligne, gestion des arguments
> multiples)

```Python
def main():
    cdef HelloWorld hello
```

> préferer la syntaxe Python `hello: HelloWorld`.

```Python
    with nogil:
```

> par rapport à cette syntaxe, ou à une déclaration nogil dans la signature, il
> serait acceptable
> d'avoir en Cython++ un mode "nogil" par défaut, et, un décorateur "withgil"
>   optionnel pour des fonctions d'interface avec Python

```Python
        hello = HelloWorld()
        hello.print_message()
```

> inchangé :-)

* * *

### Exemple "Containers"

**Version "Cython++"**, compatible Python :

```Python
class Containers:
    some_list: list[int]
    some_dict: dict[int, float]
    another_dict: dict[str, int]
```

> Classe "non cypclass" (pas de décorateur `@cypclass`). Déclaration obligatoire des
>   attributs au format hints Python .

```Python
    def __init__(self):
        # self.some_list = []
        # self.some_dict = {}
        # self.another_dict = {}
        self.some_list = list[int]()
        self.some_dict = dict[int, float]()
        self.another_dict = dict[str, int]()
```

> Python permet une initialisation sur la base des "hints". En pratique, ce serait
> probablement un changement à faire dans le code Python en cas de portage.

```Python
    def load_values(self) -> None:
        # self.some_list.append(1)
        # self.some_list.append(20)
        # self.some_list.append(30)
        self.some_list = [1, 20, 30]
        # self.some_dict[1] = 0.1234
        # self.some_dict[20] = 3.14
        self.some_dict = {1: 0.1234, 20: 3.14}
        self.another_dict["a"] = 1
        self.another_dict["foo"] = self.some_list[1]
```

> Il semble souhaitable de disposer de la syntaxe de création de liste / dict via
>   énumération. (Pour des types homogènes et des variables déclarés.) Néanmoins une
> série de `.append()` reste accptable dans le cadre proposé.

```Python
    def show_content(self) -> None:
        print("-------- containers quick example, version 1 --------")
        print("some_listst:")
        for i in self.some_list:
            print(f"  {i} ", end="")
        print()
```

> Si on dispose d'une fonction print() évoluée reprenant le formatage Python

```Python
        print("some_dict:")
        for k, v in self.some_dict.items():
            print(f"  {k}: {v}")
```

> Non nécessaire: parcours de dictionnaire avec un tuple implicite. cf contournement:

```Python
        print("another_dict:")
        for item2 in self.another_dict.items():
            print(f"  {item2[0]}: {item2[1]}")
```

> Il est accaptable de devoir "ouvrir" le tuple. Par contre, la syntaxe `item.first`
>   `item.second` est problématique dans le cadre proposé de compatibilité avec Python.

```Python
def main():
    c: Containers

    c = Containers()
    c.load_values()
    c.show_content()
```

* * *

**Version Cython+ commentée:**

```python
from libc.stdio cimport printf
from libCythonplus.dict cimport cypdict
from libCythonplus.list cimport cyplist

from .stdlib.string cimport Str
```

> Imports de types de base qui seraient à masquer en Cython++.

```python
cdef cypclass Containers:
    cyplist[int] some_list
    cypdict[int, float] some_dict
    cypdict[Str, int] another_dict

    __init__(self):
        self.some_list = cyplist[int]()
        self.some_dict = cypdict[int, float]()
        self.another_dict = cypdict[Str, int]()

    void load_values(self):
        self.some_list.append(1)
        self.some_list.append(20)
        self.some_list.append(30)
        self.some_dict[1] = 0.1234
        self.some_dict[20] = 3.14
        self.another_dict[Str("a")] = 1
        self.another_dict[Str("foo")] = self.some_list[1]
```

> La succession de `.append()` reste obligatoire en Cython+.

```python
    void show_content(self):
        printf("-------- containers quick example, version 1 --------\n")
        printf("some_list:\n")
        for i in self.some_list:
            printf("  %d ", i)
        printf("\n")

        printf("some_dict:\n")
        for item1 in self.some_dict.items():
            printf("  %d: %f\n", <int>item1.first, <float>item1.second)
```

> Syntaxe `item1.first`, `item1.second`. (Le cast n'est peut-être pas nécessaire ici.)

```python
        printf("another_dict:\n")
        for item2 in self.another_dict.items():
            printf("  %s: %d\n", (<Str>item2.first).bytes(), <int>item2.second)
```

> Syntaxe `printf` avec contrainte sur le typage `char *`.

```python
def main():
    cdef Containers c
```

> Typage au format `cdef` de Cython non souhaitable pour Cython++.

```python
    with nogil:
        c = Containers()
        c.load_values()
        c.show_content()
```

* * *

### Exemple "list_sort_reverse_in_place"

**Version "Cython++"**, compatible Python :

En supposant les méthodes `sort()` et `reverse()` disponibles, le code est trivial.

```Python
IntList = list[int]
```

> Alias de type.

```Python
def print_list(lst: IntList) -> None:
    i: int

    for i in lst:
        print(f"{i} ", end="")
    print()
```

> En supposant disposer d'une fonction `print()` analogue à celle de Python.

```Python
def demo_sort() -> None:
    lst: IntList

    lst = IntList()
    # lst = IntList([20, 300, 10, 2, 1000, 1])

    print("-------- containers demo list sort / reverse --------")

    lst = [20, 300, 10, 2, 1000, 1]
```

> Une initialisation de liste suivie d'une affectation peut sembler lourde, mais
> serait acceptable. `IntList([20, 300, 10, 2, 1000, 1])` est possible.

```Python
    print("original list:")
    print_list(lst)

    print("reverse list in-place:")
    lst.reverse()  # raise some ActiveIteratorError if another iterator running
    print_list(lst)
```

> Le mode "nogil" est implicite. Donc l'accès en modification à l'objet liste doit
>  être sécurisé. Ici on suppose que l'implémentation permet une gestion d'exception.
>  cf. le test explicite dans la version Cython+.

```Python
    print("reverse list in-place:")
    lst.reverse()  # raise some ActiveIteratorError if another iterator running
    print_list(lst)

    print("sort list in-place:")
    lst.sort()  # raise some ActiveIteratorError if another iterator running
    print_list(lst)

    print("reverse list in-place:")
    lst.reverse()  # raise some ActiveIteratorError if another iterator running
    print_list(lst)


def main() -> None:
    demo_sort()
```

* * *

**Version Cython+ commentée:**

(Commentaires communs aux exemples précédents non repris.)

```Python
from libc.stdio cimport printf
from libcpp.algorithm cimport sort, reverse
```

> Utilisation de la bibliothèque `libcpp.algorithm` et les itérateurs C++.

```Pythonfrom libcythonplus.list cimport cyplist
# define a specialized type: list of int
ctypedef cyplist[int] IntList


cdef void print_list(IntList lst) nogil:
    for i in range(lst.__len__()):
        printf("%d ", <int>lst[i])
    printf("\n")


cdef void sort_list(IntList lst) nogil:
    if lst._active_iterators == 0:
        sort(lst._elements.begin(), lst._elements.end())
    else:
        with gil:
            raise RuntimeError("Modifying a list with active iterators")
```

> Implémentation d'une fonction `sort_list()` dédiée au type `int`, avec test
>   d'unicité de l'itérateur et gestion du GIL.

```Python
cdef void reverse_list(IntList lst) nogil:
    if lst._active_iterators == 0:
        reverse(lst._elements.begin(), lst._elements.end())
    else:
        with gil:
            raise RuntimeError("Modifying a list with active iterators")
```

> Idem.

```Python
cdef void demo_sort():
    cdef IntList lst

    lst = IntList()
    with nogil:
        printf("-------- containers demo list sort / reverse --------\n")

        lst.append(20)
        lst.append(300)
        lst.append(10)
        lst.append(2)
        lst.append(1000)
        lst.append(1)

        printf('original list:\n')
        print_list(lst)

        printf('reverse list in-place:\n')
        reverse_list(lst)
        print_list(lst)

        printf('reverse list in-place:\n')
        reverse_list(lst)
        print_list(lst)

        printf('sort list in-place:\n')
        sort_list(lst)
        print_list(lst)

        printf('reverse list in-place:\n')
        reverse_list(lst)
        print_list(lst)


def main():
    demo_sort()
```

* * *

### Exemple "fibonacci"

**Version Python d'origine:**

```Python
def fibo(n):
    a = 0.0
    b = 1.0
    for i in range(n):
        a, b = b, a + b
    return a


def fibo_list(level):
    return [fibo(n) for n in range(level + 1)]


def main(level=None):
    if not level:
        level = 1476
    result = fibo_list(int(level))
    print(f"Computed values: {len(result)=}, Fibonacci({level}) is: {result[-1]=}")
```

* * *

**Version "Cython++"**, compatible Python:

```Python
from fake import cypclass, consume, activate, SequentialMailBox, wlocked, Lock, double

IntDoubleDict = dict[int, double]


@cypclass
class Fibo:
```

> Le mot clé `activable` est omis: une `cypclass` est considérée comme activable par
> défaut.

```Python
    level: int
    results: Annotated(IntDoubleDict, Lock)
```

> Utilisation de Annotated pour marquer le type `lock`.

```Python
    def __init__(
        self,
        scheduler: Annotated(Scheduler, Lock),
        results: Annotated(IntDoubleDict, Lock),
        level: int,
    ):
        # self._active_result_class = NullResult
        self._active_queue_class = consume(SequentialMailBox(scheduler))
```

> Attributs issus de Cython+.

```Python
        self.level = level
        self.results = results

    def run(self) -> None:
        a: double
        b: double
        i: int

        a = 0.0
        b = 1.0
        for i in range(self.level):
            a, b = b, a + b
        with wlocked(self.results):
            self.results[self.level] = a
```

> Le contaxt manager `wlocked` est transparent dans la version Python "fake".

```Python
def fibo_list_cyp(
    scheduler: Annotated(Scheduler, Lock), level: int
) -> Annotated(IntDoubleDict, Lock):
    # nogil function (by default)
    results: Annotated(IntDoubleDict, Lock)
    n: int

    results = consume(IntDoubleDict())

    for n in range(level, -1, -1):  # reverse order to compute first the big numbers
        fibo = activate(consume(Fibo(scheduler, results, n)))
        fibo.run()  # remove the NULL argument

    scheduler.finish()
    return results


def fibo_list(level: int) -> list[int]:
    # nogil function (by default)

    results_cyp: IntDoubleDict
    result_py: list[int]
    scheduler: Annotated(Scheduler, Lock)
    i: int

    scheduler = Scheduler()
    results_cyp = consume(fibo_list_cyp(scheduler, level))
    del scheduler

    result_py = [
        item[1] for item in sorted((i, results_cyp[i]) for i in range(level + 1))
    ]
```

> Cette imbrication et l'objet non annoté `item` nécessiterait vraisembleblement
>   une adaptation pour un portage effectif vers "Cython++".
>
>  Remarque: il semblerait que ce soit le seul endroit ayant une difficulté de
>  portabilité.

```Python
    return result_py


def main(level_arg: int = 0) -> None:
    # nogil function (by default)
    result: list[int]
    level: int

    if level_arg > 0:
        level = level_arg
    else:
        level = 1476
    result = fibo_list(level)
    print(f"Computed values: {len(result)=}, Fibonacci({level}) is: {result[-1]=}")
```

* * *

**Version Cython+ d'origine:**

Le code de la version "Cython++" ci-dessus est basé sur cette implémentation.

```Python
from libcythonplus.dict cimport cypdict
from .scheduler.scheduler cimport SequentialMailBox, NullResult, Scheduler


cdef cypclass Fibo activable:
    long level
    lock cypdict[long, double] results

    __init__(self,
             lock Scheduler scheduler,
             lock cypdict[long, double] results,
             long level):
        self._active_result_class = NullResult
        self._active_queue_class = consume SequentialMailBox(scheduler)
        self.level = level
        self.results = results

    void run(self):
        cdef double a, b

        a = 0.0
        b = 1.0
        for i in range(self.level):
            a, b = b, a + b
        with wlocked self.results:
            self.results[self.level] = a


cdef lock cypdict[long, double] fibo_list_cyp(
        lock Scheduler scheduler,
        long level) nogil:
    cdef lock cypdict[long, double] results

    results = consume cypdict[long, double]()

    for n in range(level, -1, -1):  # reverse order to compute first the big numbers
        fibo = activate(consume Fibo(scheduler, results, n))
        fibo.run(NULL)

    scheduler.finish()
    return results


cdef list fibo_list(int level):
    cdef cypdict[long, double] results_cyp
    cdef list result_py
    cdef lock Scheduler scheduler

    scheduler = Scheduler()
    results_cyp = consume fibo_list_cyp(scheduler, level)
    del scheduler

    result_py = [item[1] for item in
                    sorted((i, results_cyp[i]) for i in range(level + 1))
                ]
    return result_py


def main(level=None):
    if not level:
        level = 1476
    result = fibo_list(int(level))
    # print(f"Computed values: {len(result)=}, Fibonacci({level}) is: {result[-1]=}")
    print(f"Computed values: len(result)={len(result)}, Fibonacci({level}) is: result[-1]={result[-1]}")
```

* * *
