# Éléments de théorie des groupes - Solutions des exercices


L'objectif du projet est de proposer des solutions aux 238 exercices du livre de Josette Calais, *Éléments de théorie des groupes*, Presses Universitaires de France, 2014.
Les énoncés ne sont pas inclus pour des raisons légales.

## Licence

Ce travail est mis à disposition selon les termes de la [licence Creative
Commons Attribution - Pas d'utilisation commerciale - Partage à l'identique 3.0
France](http://creativecommons.org/licenses/by-nc-sa/3.0/fr/).

## Compilation

Pour compiler le livre, il vous faut une distribution TeX (TeX Live, MacTeX, MiKTeX, …).
Un Makefile destiné au logiciel de construction Make est fourni.
Il est facultatif.

Sous Debian GNU/Linux et ses dérivées (Ubuntu, ...), installez les paquets `texlive`, `texlive-latex-extra`, `latexmk` et éventuellement `make`.

Le livre est disponible dans plusieurs versions.

### Avec Make

Pour compiler toutes les versions, exécutez la commande suivante depuis la racine du projet :

    make pdfs

La liste de toutes les tâches s'obtient avec la commande `make help` ou plus simplement `make`.
Le Makefile peut-être configuré via des variables à placer sur la ligne de commande.
Par exemple,

    make pdfs VERSIONS=a5

compile seulement la version prévue pour l'impression au format A5.
Les variables peuvent être mises dans un fichier `Makefile.ini` à la racine du projet.
Un modèle documenté est fourni.
Copiez `Makefile.ini.template` vers `Makefile.ini` et éditez ce dernier.
Les variables sur la ligne de commande sont prioritaires sur celles du fichier `Makefile.ini`.

### Sans Make

Créez à la racine du projet le fichier `revision.tex` contenant les lignes suivantes :

    \newcommand{\gitDescribe}{Version de <votre nom>}
    \newcommand{\gitDate}{\today}

À chaque version XXX du livre correspond un fichier maître `ETG-solutions-XXX.tex`.
Faîtes `ls ETG-solutions-*.tex` pour lister les fichiers maîtres et donc les versions disponibles.
Par exemple, pour imprimer le livre en noir et blanc au format A4, exécutez la commande

    latexmk -outdir=build --pdf ETG-solutions-a4.tex

Vous obtenez un fichier `ETG-solutions-a4.pdf` dans le dossier `build/`.
