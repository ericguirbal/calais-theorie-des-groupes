-include Makefile.ini
PREPROCESSOR = bin/makelatex.pl
PERL        ?= perl
PDFLATEX   	?= pdflatex
BIBTEX     	?= bibtex
PDFVIEWER  	?= mupdf -r 112

DIST_DIR     = dist
BUILD_DIR    = build
SOURCE_DIR   = book
TEMPLATE     = lib/template.tex
BIBLIO       = $(SOURCE_DIR)/bibliographie.bib

LATEX_OPTS   = -halt-on-error -output-directory $(BUILD_DIR)

BOOK        ?= book
PAGE_COLOR  ?= White
TEXT_COLOR  ?= Black

SOURCE_FILES = $(shell find $(SOURCE_DIR)/ -type f -name '*.tex') 

RERUN = "^LaTeX Warning: .* Rerun to get"

export SOURCE_DIR PAGE_COLOR TEXT_COLOR

DEBUG ?= 0
ifeq ($(DEBUG),0)
	LATEX_OPTS += -interaction batchmode
endif

.PHONY: pdf release view clean distclean

pdf: $(BUILD_DIR)/$(BOOK).pdf

$(BUILD_DIR)/$(BOOK).pdf: $(BUILD_DIR)/$(BOOK).tex $(BIBLIO)
	@$(PDFLATEX) $(LATEX_OPTS) $<
	@$(BIBTEX) $(basename $<)
	@$(PDFLATEX) $(LATEX_OPTS) $<
	@(while grep -q $(RERUN) $(basename $@).log; \
	do \
		$(PDFLATEX) $(LATEX_OPTS) $<; \
	done)

tex: $(BUILD_DIR)/$(BOOK).tex  

$(BUILD_DIR)/$(BOOK).tex: $(SOURCE_FILES) $(TEMPLATE) $(PREPROCESSOR)
	mkdir -p $(BUILD_DIR)
	$(PERL) $(PREPROCESSOR) > $@

release: pdf
	cp $(BUILD_DIR)/$(BOOK).pdf $(DIST_DIR)/$(BOOK)-$$(date +"%Y%m%d").pdf

view: pdf
	$(PDFVIEWER) $(BUILD_DIR)/$(BOOK).pdf &

clean:
	rm -fr $(BUILD_DIR)

distclean: clean
	rm -fr $(DIST_DIR)/*

