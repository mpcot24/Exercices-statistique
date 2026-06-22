# Exercices-statistique
Exercices pour le cours ACT-2000 Analyse statistique des risques actuariels à l'École d'actuariat de l'Université Laval

## Procédure de conversion du recueil `.Rnw` vers `quarto`

Cette procédure permet de convertir un recueil d'exercice en format `.Rnw` vers le format `quarto`.

Pour créer un nouvel exercice ou en retirer un, il suffit de commencer à l'étape 6.

1. Ouvrir le fichier maître du recueil d'exercices `.Rnw` et repérer les
scripts `.Rnw` qui sont appelés (habituellement un par chapitre du cours).

2. Donner un nom de fichier `\filename` et un titre `\title` à chaque exercice dans les scripts `.Rnw` individuels du recueil original.
Insérer ces commandes après `\begin{exercice}`.

- Le fichier de conversion ira lire chacun des fichiers individuels et créera un répertoire par chapitre. 
- Dans chaque répertoire, il y aura un petit fichier `.qmd` par exercice. Il est donc important de donner un nom de fichier
parlant à chaque exercice.
- Dans le nouveau recueil d'exercice `quarto`, chaque exercice sera identifié par un titre. C'est pourquoi il faut nommer chacun 
de ces exercices. 

```
\begin{exercice}
\filename{pivot_gamma}
\title{Pivot pour le paramètre d'échelle d'une loi gamma}
[Poursuivre avec le contenu de l'exercice]
...
\begin{sol}
[Solution de l'exercice]
\end{sol}
\end{exercice}

```

3. Regrouper tous les scripts de chapitres `.Rnw` à convertir en `.qmd` dans un même répertoire.

4. Dans le script `convert_rnw_to_quarto.R` aux lignes 26 et 27, indiquer le répertoire d'entrée où 
se trouvent les scripts des chapitres (celui choisi en 3.) et indiquer où exporter le matériel pour 
le nouveau recueil `quarto`.

5. Convertir les scripts d'exercices en quarto avec `source("convert_rnw_to_quarto.R")`.

6. S'assurer que le fichier `_quarto.yml` qui a été créé mène bien à la structure du recueil voulue.

- La structure sera un fichier qui appelle des fichiers `.qmd` pour chaque chapitre (dans le section `chapters` de l'en-tête).
- Le fichier `.qmd` de chaque chapitre appelle à son tour tous les scripts d'exercices créés dans la conversion.
- Pour retirer des exercices, commenter dans le fichier `.qmd` du chapitre.
- Pour ajouter des exercices, créer un exercice dans un fichier `.qmd` et ajouter un appel à ce fichier dans 
le `.qmd` associé à ce chapitre.
- Le script `index.qmd` constitue l'en-tête du recueil d'exercices qui sera créé. Si on veut ajouter des informations,
une introduction ou des instructions pour les étudiants, on peut les ajouter ici.

7. Pour produire le recueil d'exercices, il faut fixer son répertoire de travail au même endroit que le `_quarto.yml`. Dans la ligne
de commande, on fait `quarto render`. 

- Lors de la première exécution, il y a souvent quelques avertissements ou erreurs liés à la conversion.
- Il y a donc un peu de débogage à faire pour retirer ces erreurs. Souvent, ce sont des blocs de codes
qui ont été transférés du format `.Rnw` au `.qmd` sans ajouter une ligne vide. Répérer les ` ``` `; c'est souvent là que se trouvent
les erreurs.

8. Lire le `.html` rendu pour s'assurer que la conversion s'est bien déroulée, surtout pour les références entre exercices.

- Pour ouvrir le recueil, il faut ouvrir `index.html` dans le dossier `_book/` créé dans le processus. 
