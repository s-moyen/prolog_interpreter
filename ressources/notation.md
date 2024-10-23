* Barême de Notation

* Documentation & Lancement (Makefile) (/3 points) 

+ Est-ce que le projet est bien documenté (readMe) ?                    /1 point
Un bon readMe de projet devrait indiquer : dépendances de compilation, commandes de compilation et d'utilisation, petit guide d'utilisation de l'éxécutable, présentation succinte des différents fichiers du projet, résumé des features principales. Ça n'a pas besoin d'être très long (et c'est même mieux que ça ne le soit pas), en revanche si vous avez ajouté une feature avec une utilisation spéciale (nouvelles commandes dans l'éxécutables par exemple), il est très important de documenter leur utilisation.
+ Est-ce que la compilation se lance correctement ?                     /1 point
Pas d'erreur, pas de warning.
+ Est-ce que les tests se lancent facilement ?                          /1 point

* Qualité du code (/4 points)

+ Les noms de fonctions et de variables sont-ils bien choisis ?         /1 point
+ Le code est-il bien indenté ?                                         /1 point
`ocp-indent -i` est votre ami et faites attention aux lignes trop longues (> 100 caractères)
+ Y-a-t'il des commentaires de documentation ?
     Permettent-ils de bien comprendre ?                                /1 point
Je m'attends à avoir un commentaire de documentation `(** *)` pour chaque fonction et des commentaires `(* *)` qui éclaircissent les parties un peu techniques.
+ Est-ce que le code est facile à comprendre ?                          /1 point
Pensez aux annotations de type, entre autre. Réfléchissez à la création de fonctions auxiliaires pour casser vos gros corps de fonctions. Faites attention à l'aération du fichier.
(une grande mélancolie s'emparera de moi si je dois relire un énorme bloc de code peu organisé)
	

* Tests (/3 points)

+ Est-ce que toutes les fonctions sont testées ?                     /1 point
Si vous avez ajouté des fonctions, celles-ci doivent être testées. Rajoutez également des tests au fichier proposé.
+ Est-ce que les cas de test sont variés ?                           /1 point
+ Est-ce qu'il y a des run_time tests (asserts) ?                    /1 point
Si vos fonctions se basent implicitement sur une propriété des données, un invariant, etc. n'hésitez pas à le renseigner avec un `assert`


* Fonctionnalités et fonctionnement du code (/10 points)

+ Unify /2
+ Term /2
+ Query /2
+ Convert /2
	
	
+ Jeux de règles /1
J'aimerais bien que vous construisiez au moins un jeu de règle supplémentaire. Le top ce serait un jeu provenant du cours de PROG1 mais vous êtes libre d'en ajouter un autre.

+ Features spéciales, extensions, traits particuliers de votre infératrice /1


