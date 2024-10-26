# prolog_interpreter


#L'infératrice

Nous tenons à nous excuser du retard pour le du Readme qui n'a pas été rendu dans les délais demandés.

Le projet n'a pas pu être terminé dans le temps imparti, et il restait un problème  lors de la récursion pour la lecture de certaine requêtes.

Nous avons implémenté la solution pour résoudre le problème, mais n'avons pas eu le temps de finir de débugger. Ainsi, vous verrez des fonctions pour renommer des variables au tout début de la fonction convert_1_rule ; ces fonctions permettent de résoudre le problème, mais nous n'avons pas eu le temps d'aller jusqu'au bout.



# FEATURES PRINCIPALES

Le rôle de l'infératrice est, étant donné un ensemble de règles, de donner des réponses à des questions en se basant sur cet ensemble de règles. Au début, l'infératrice ne sait rien faire. Mais elle peut tout faire, pourvu que vous lui ayez appris à le faire.
Exemple : Vous vous demandez combien fait 1+1.
Vous apprenez à l'infératrice à faire des additions sur les entiers (fichier 2_arith.inf), puis vous écrivez la requête suivante : plus(1, 1, A).
L'infératrice vous donnera la valeur de A telle que ça marche.


# DEPENDANCES ET COMMANDE DE COMPILATION :
Pour compiler le projet, il suffit de taper la commande `make inferatrice` dans un terminal ouvert dans le dossier courant du projet.
Ce projet est écrit entièrement en OCaml, vous allez donc avoir besoin d'avoir installé OCaml. Une version 4.13 suffit.
Pour exécuter les tests, vous allez avoir besoin d'avoir installé alcotest.



# GUIDE DE L'UTILISATION DE L'EXECUTABLE :

Notre projet se conclut en un fichier exécutable du nom de inferatrice.
Pour l'utiliser, il convient de lui passer en argument un fichier de règles (.inf) comme ceux donnés en exemple dans l'archive. Ces règles vont ensuite vous permettre de lancer des requêtes à l'infératrice afin d'obtenir des informations inférées à partir des règles.

Pour lancer une requête, le syntaxe est celle des termes. Veillez à bien terminer vos requêtes par un point. Si votre requête contient des variables, et qu'elle admet des solutions, alors l'infératrice affichera l'état de ces variables, puis vous demandera si vous voulez qu'elle continue à chercher des solutions.
Si la requête ne contient pas de variables, l'infératrice affichera l'état de variables utilisées dans les règles permettant de rendre la requête vraie.
Dans tous les cas, si aucune solution n'existe, il sera affiché "Fin des solutions pour cette requête".

Prenez garde lorsque vous interagissez avec l'interpréteur en console, car notre exécutable ne supporte pas l'édition de lignes. Vous ne pourrez pas retourner en arrière dans une ligne que vous écrivez, il vous faudra effacer et récrire. L'édition de ligne n'est pas supportée par des exécutables Linux en général, si on n'inclut pas spécifiquement le fonctionnalité de le faire.





# Terme:
Ce fichier permet la manipulation bas niveau des termes (affichage, création de nouvelles variables, binding des variables).

Nous avons opté pour représenter les variables par des entiers, afin de pouvoir en créer une nouvelle facilement.
Nous utilisons une table de hachage globale pour lier une variable à un terme.
Nous avons gardé le type `obs_t` pour le type `t`
La fonction égalité vérifie récursivement que les fonctions sont bien les mêmes et que les variables représentent les mêmes termes.

# Unify
Ce fichier contient la fonction unify dont le rôle est, étant donnés deux termes, de binder des variables appartenant aux termes dans le but de les unifier (les rendre égaux). Si deux termes ne peuvent pas être unifiés, la fonction échoue et lance une exception.
Le challenge principale de l'unification était de vérifier que les variables représentaient bien la même chose.
Pour cela, si les termes ne sont pas déjà égaux, on vérifie que l'un des deux n'est pas déjà lié à un terme dans la table de hachage global et on le lie au 1er terme. Si les deux sont déjà liées, l'unification est impossible.
Il faut aussi prendre en compte le cas où une variable s'auto-référence, pour éviter une boucle infinie (par exemple avec `X` et `f(X)` )

# Convert
Le rôle de ce fichier est de transformer un ensemble de règles en une fonction permettant d'utiliser ces règles afin de créer des query à partir de requêtes (atomes).
Un premier problème c'est imposé à cause du type des `atom_t` qui utilisaient des `string` pour les variables, on a donc utilisé une 2ème table de hachage qui a chaque string associé un entier, correspondant à une variable de Term
On fabriquait ensuite une`Query` correcte en associant correctement les nouvelles variables de l'hypothèse à celle déjà connu en plus de cette nouvelle hypothèse

# Query
La fonction principale de ce fichier est la fonction search. Cette fonction est la fonction principale du projet. Elle prend en argument une requête et cherche à rendre vraie cette requête en unifiant des termes, en affectant des variables. A chaque solution trouvée par search, les variables sont affichées utilisant la fonction de traitement du résultat passée en argument.
