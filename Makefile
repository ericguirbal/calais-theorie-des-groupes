-include Makefile.ini
PDFLATEX   	?= pdflatex
BIBTEX     	?= bibtex
PDFVIEWER  	?= mupdf -r 112

DIST_DIR     = dist
SOURCE_DIR   = book
BIBLIO       = $(SOURCE_DIR)/bibliographie.bib

BOOK         = book
MASTER       = main

SOURCE_FILES = $(shell find $(SOURCE_DIR)/ -type f -name '*.tex') 
LATEX_FILES  = lib/maths.sty

LATEX_OPTS   = -halt-on-error -jobname $(BOOK)

RERUN = "^LaTeX Warning: .* Rerun to get"

export SOURCE_DIR PAGE_COLOR TEXT_COLOR

.PHONY: pdf release view clean distclean

pdf: $(BOOK).pdf

$(BOOK).pdf: $(MASTER).tex $(BIBLIO)
	@$(PDFLATEX) $(LATEX_OPTS) $<
	@$(BIBTEX) $(basename $@)
	@$(PDFLATEX) $(LATEX_OPTS) $<
	@(while grep -q $(RERUN) $(basename $@).log; \
	do \
		$(PDFLATEX) $(LATEX_OPTS) $<; \
	done)

release: pdf
	cp $(BOOK).pdf $(DIST_DIR)/$(BOOK)-$$(date +"%Y%m%d").pdf

view: pdf
	$(PDFVIEWER) $(BOOK).pdf &

clean:
	rm -f *.aux *.log *.toc *.bbl *.blg *.out

distclean: clean
	rm -f $(BOOK).pdf
	rm -f $(DIST_DIR)/*

