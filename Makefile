PDFLATEX = pdflatex
BIBTEX   = bibtex

SOURCE_DIR = book
BIBLIO     = $(SOURCE_DIR)/bibliographie.bib
BOOK       = ETG-solutions

SOURCE_FILES = $(shell find $(SOURCE_DIR)/ -type f -name '*.tex') 

LATEX_OPTS   = -halt-on-error -file-line-error

RERUN = "^LaTeX Warning: .* Rerun to get"

.PHONY: a4 a5 clean distclean

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

clean:
	rm -f *.aux *.log *.toc *.bbl *.blg *.out

distclean: clean
	rm -f *.pdf

