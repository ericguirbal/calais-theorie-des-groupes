-include Makefile.ini

# Préfixe pour les noms des fichiers cibles
BOOK_FILE = ETG-solutions

# Options de pdflatex
LATEX_OPTS = -file-line-error

# Options de latexmk
LATEXMK_OPTS = -recorder -pdf -pdflatex="pdflatex $(LATEX_OPTS)"

# SILENT=0 ou 1 selon que l'on souhaite ou pas une sortie détaillée
# des commandes latexmk et pdflatex.
SILENT ?= 1
ifeq ($(SILENT),1)
	LATEXMK_OPTS += -silent
endif

# PVC=1 ou 0 selon que l'on souhaite ou pas une mise à jour
# automatique du PDF lorsqu'un fichier source est modfifié.
PVC ?=0
ifeq ($(PVC),1)
	LATEXMK_OPTS += -pvc
endif

# Version
VERSION = $(shell git describe --always --long --dirty)

.PHONY: all a5 a4 clean cleanall help version.tex

help:
	@echo "Usage: make [options] [cibles]"
	@echo
	@echo "Cibles disponibles :"
	@echo "          a5 : Compile au format A5"
	@echo "          a4 : Compile au format A4"
	@echo "         all : Compile dans tous les formats disponibles"
	@echo "       clean : Supprime les fichiers intermédiaires produit par la compilation"
	@echo "    cleanall : Comme clean et supprime les fichiers cibles"
	@echo "        help : Affiche cette aide"
	@echo
	@echo "Options disponibles :"
	@echo "     PVC=0|1 : Active la prévisualisation en continue du PDF si PVC=1 (défaut : PVC=0)"
	@echo "  SILENT=0|1 : Pour une sortie détaillée ou pas de la compilation."
	@echo "               Par défaut SILENT=1."

all: a5 a4

a5: $(BOOK_FILE)-a5.pdf 

a4: $(BOOK_FILE)-a4.pdf

$(BOOK_FILE)-%.pdf: version.tex
	@latexmk $(LATEXMK_OPTS) $(basename $@).tex
	@echo "\033[92mFichier $@ créée avec succès.\033[0m"

version.tex:
	@/bin/echo -n '\newcommand{\OPTversion}{' > version.tex
	@/bin/echo -n '$(VERSION)' >> version.tex
	@/bin/echo -n '}' >> version.tex

clean:
	@rm -fv *.aux *.log *.toc *.bbl *.blg *.out *.fls *.fdb_latexmk version.tex

cleanall: clean
	@rm -fv $(BOOK_FILE)-*.pdf

