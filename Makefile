-include Makefile.ini
PDFLATEX = pdflatex
BIBTEX   = bibtex

SOURCE_DIR = book
BIBLIO     = $(SOURCE_DIR)/bibliographie.bib
BOOK       = ETG-solutions

SOURCE_FILES = $(shell find $(SOURCE_DIR)/ -type f -name '*.tex') 

LATEX_OPTS   = -halt-on-error -file-line-error

DEBUG ?= 0
ifeq ($(DEBUG),0)
	LATEX_OPTS += -interaction batchmode
endif

RERUN = "^LaTeX Warning: .* Rerun to get"

.PHONY: all a5 a4 clean distclean help

help:
	@echo "Usage: make [options] [cibles]"
	@echo
	@echo "Cibles disponibles :"
	@echo "         a5 : Compile au format A5"
	@echo "         a4 : Compile au format A4"
	@echo "        all : Compile dans tous les formats disponibles"
	@echo "      clean : Supprime les fichiers intermédiaires produit par la compilation"
	@echo "  distclean : Comme clean et supprime les fichiers cibles"
	@echo "       help : Affiche cette aide"
	@echo
	@echo "Option disponible :"
	@echo "  DEBUG=0|1 : Si DEBUG=1 pdflatex affiche une sortie détaillée."
	@echo "              Par défaut DEBUG=0."

all: a5 a4

a5: $(BOOK)-a5.pdf

a4: $(BOOK)-a4.pdf

$(BOOK)-%.pdf: $(BOOK)-%.tex main.tex opt-%.tex $(BIBLIO) maths.sty copyright.tex
	@$(PDFLATEX) $(LATEX_OPTS) $<
	@$(BIBTEX) $(basename $@)
	@$(PDFLATEX) $(LATEX_OPTS) $<
	@(while grep -q $(RERUN) $(basename $@).log; \
	do \
		$(PDFLATEX) $(LATEX_OPTS) $<; \
	done)
	@echo 
	@echo "\033[92mCible $@ créée avec succès.\033[0m"

clean:
	@rm -fv *.aux *.log *.toc *.bbl *.blg *.out

distclean: clean
	@rm -fv $(BOOK)-*.pdf

