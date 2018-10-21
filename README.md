Éléments de théorie des groupes - Solutions des exercices
=========================================================

L'objectif du projet est de proposer des solutions aux 238 exercices du livre de Josette Calais, *Éléments de théorie des groupes*, Presses Universitaires de France, 2014.

Les énoncés ne sont pas inclus pour des raisons légales.

Licence
-------

Ce travail est mis à disposition selon les termes de la [licence Creative
Commons Attribution - Pas d'utilisation commerciale - Partage à l'identique 3.0
France](http://creativecommons.org/licenses/by-nc-sa/3.0/fr/).

Compilation
-----------

Pour compiler le livre vous avez besoin d'une distribution LaTeX et idéalement des programmes `make` et `latexmk`.
Sous Debian GNU/Linux et dérivées (Ubuntu, ...), veuillez installer les paquets `texlive`, `texlive-latex-extra`, `make` et `latexmk`. 

Le livre est disponible dans plusieurs formats. Pour le compiler au format A5, exécutez la commande
    
    make a5

Vous devriez obtenir un fichier `ETG-solutions-a5.pdf`. 
La commande `make help` affiche les autres formats disponibles.

Si vous n'avez pas `make` et ne souhaitez pas l'installer, vous pouvez toujours compiler le livre en lançant vous même la commande `latexmk` ou `pdflatex`. 
Tout d'abord il vous faut créer un fichier `version.tex` contenant
    
    \newcommand{\OPTversion}{???}

Ensuite pour obtenir le livre au format XXX, lancez la commande

    latexmk -recorder -pdf ETG-solutions-XXX.tex

Si vous ne disposez pas de `latexmk` (normalement fourni par les principales distributions LaTeX), c'est un peu plus laborieux : lancez une première fois

    pdflatex ETG-solutions-XXX.tex 

puis 
    
    bibtex ETG-solutions-XXX
    
et pour finir, exécutez deux fois 
    
    pdflatex ETG-solutions-XXX.tex

N'oubliez de remplacer XXX par a5, a4 ou tout autre format disponible.

Si vous n'aimez pas la ligne de commande vous pouvez faire exécuter ces commandes par votre éditeur favori (TeXStudio, TeXnicCenter, TeXShop, ...).

