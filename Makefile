MAKEFLAGS     += --warn-undefined-variables
SHELL         := /bin/bash
.DEFAULT_GOAL := help
.ONESHELL:

# Destiné à la personnalisation de certaines variables.
# Voir le modèle Makefile.local.template.
-include Makefile.ini

# Le visionneur de fichier texte
ifeq ($(PAGER),less)
    ifeq ($(origin PAGER),environment)
        PAGER += -F
    endif
else ifeq ($(shell which less),)
    PAGER ?= cat
else
    PAGER ?= less -F
endif

# Le visionneur de PDF
kernel := $(shell uname)
ifeq ($(kernel),Linux)
    PDF_VIEWER ?= xdg-open
else ifeq ($(kernel),Darwin)
    PDF_VIEWER ?= open
endif

# Les PDF générés sont de la forme $(book)-$(FORMAT)-$(REVISION).pdf
book := ETG-solutions

# Dossier où se passe la compilation
BUILD_DIR ?= build

# Dossier où vont les pdfs
PDF_DIR ?= pdfs

# Fichiers maîtres
MAIN_FILES := $(wildcard ETG-solutions-*.tex)

# Les versions disponibles
VERSIONS_ALL := $(sort $(MAIN_FILES:$(book)-%.tex=%))

# Options de pdflatex
pdflatex_opts := -file-line-error

# Options de latexmk
latexmk_opts := -outdir=$(BUILD_DIR) -recorder -pdf \
				-pdflatex="pdflatex $(pdflatex_opts) %O %S" \
				-e '$$pdf_previewer="$(PDF_VIEWER) %O %S";'

# La variable VERSION_DEV désigne la version préférée pour développer. Elle est
# destinée au fichier Makefile.ini. Sur la ligne de commande, on peut utiliser
# la variable VERSION.
VERSION_DEV ?= $(word 1,$(VERSIONS_ALL))
VERSION     ?= $(VERSION_DEV)
VERSION_DEV := $(VERSION)

# Liste des versions à compiler.
# VERSIONS sur la ligne de commande, l'alias VERSIONS_PDF dans le ficher
# Makefile.ini.
VERSIONS_PDF ?= $(VERSIONS_ALL)
VERSIONS     ?= $(VERSIONS_PDF)
VERSIONS_PDF := $(VERSIONS)

# Nom du fichier maître en fonction de la version
# $(call source-main,version)
source-main = $(book)-$1.tex

# Révision
GIT_DESCRIBE := $(shell git describe --always --long --dirty)
GIT_DATE 	 := $(shell git log -1 --format=%ad --date=short)
REVISION     := $(subst -,,$(GIT_DATE))-$(GIT_DESCRIBE)

# Nom du fichier de développement en fonction de la version
# $(call target-dev,version)
target-dev = $(BUILD_DIR)/$(book)-$1.pdf

# Nom de l'ébauche en fonction de la version
# $(call target-pdf,version))
target-pdf = $(PDF_DIR)/$(book)-$1-$(REVISION).pdf

# Les PDF de développement
TARGET_DEV 	:= $(call target-dev,$(VERSION_DEV))
TARGETS_DEV_ALL := $(VERSIONS_ALL:%=$(call target-dev,%))

# Les PDF générés par la cble pdfs
TARGETS_PDF     := $(VERSIONS_PDF:%=$(call target-pdf,%))
TARGETS_PDF_ALL := $(VERSIONS_ALL:%=$(call target-pdf,%))

# Pour colorer certains messages
red   := $(shell tput setaf 1)
green := $(shell tput setaf 2)
reset := $(shell tput sgr0)

empty :=
space := $(empty) $(empty)
comma := ,

# Variable dont l'évaluation produit un retour à la ligne
define newline
$(empty)
$(empty)
endef

# $(call uppercase,texte)
uppercase = $(shell echo $1 | tr '[:lower:]' '[:upper:]')

# $(call intercalate,list,separator)
intercalate = $(subst $(space),$2,$1)

# $(call init,list)
init = $(wordlist 1,$(shell echo $(words $1) - 1 | bc),$1)

# $(call join-with-conj,list,conjunction)
define join-with-conj
$(call intercalate,$(call init,$1),$(comma)$(space))$(space)$2$(space)$(lastword $1)
endef

# Largeur de la première colonne de la page d'aide
help_width := 18

define make_help_message
define help_message
USAGE
$(shell \
	awk 'BEGIN { FS="##\\s" } \
		/^##\smake\s[a-z\-]+(\s(\[[A-Z\-]+=[a-z\-]+\])*)?/ \
		{ printf "  %s\\n",$$2 }' $(MAKEFILE_LIST)) \

CIBLES
$(shell \
	awk 'BEGIN { FS="##\\s|\\s:\\s" } /^##\s[a-z\-]+\s:\s/ \
		{ printf  "  %-$(help_width)s %s\\n", $$2, $$3 }' \
		$(MAKEFILE_LIST)) \

VERSIONS
$(shell \
	$(foreach v,$(VERSIONS_ALL), \
		awk 'BEGIN { FS="%"; } /^%/ \
			{ printf "  %-$(help_width)s%s\\n", "$v", $$2 }' \
			$(call source-main,$v);)) \

VARIABLES PRINCIPALES
$(shell \
	awk 'BEGIN { FS="#\\s!?|\\s:\\s" } /^#\s![A-Z_]+\s:\s/ \
		{ printf "  %-$(help_width)s %s\\n", $$2, $$3 }' \
		Makefile.ini.template)
endef
export help_message
endef

$(eval $(call make_help_message))

# $(call validate-version,version)
define validate-version
$(if $(filter $1,$(VERSIONS_ALL)),,
	$(error $(red)Version $1 inconnue. \
		Les versions disponibles sont \
		$(call join-with-conj,$(VERSIONS_ALL),et)$(reset)))
endef


.SILENT:

.PHONY: FORCE_MAKE
FORCE_MAKE:

.PHONY: validate/version-dev validate/versions-pdf
validate/version_dev validate/versions_pdf: validate/%:
	$(foreach v,$($(call uppercase,$*)),$(call validate-version,$v))

.PHONY: validate/pdf-viewer
validate/pdf-viewer:
ifeq ($(shell which $(PDF_VIEWER)),)
	$(error $(red)Visionneur de PDF non disponible$(reset))
endif

.PHONY: revision.tex
.INTERMEDIATE: revision.tex
revision.tex:
	$(file > $@,\newcommand{\gitDescribe}{$(GIT_DESCRIBE)})
	$(file >> $@,\newcommand{\gitDate}{$(GIT_DATE)})

.PRECIOUS: $(TARGET_DEV)
$(TARGETS_DEV_ALL): $(call target-dev,%): $(call source-main,%) revision.tex
	latexmk $(latexmk_opts) $<

$(TARGETS_PDF_ALL): $(call target-pdf,%): $(call target-dev,%) FORCE_MAKE
	mkdir -p $(@D)
	cp -uv $< $@

## pdfs : Compile une version du livre
## make pdfs [VERSIONS="$(VERSIONS_PDF)"]
.PHONY: pdfs
pdfs: latexmk_opts += -silent
pdfs: validate/versions_pdf $(TARGETS_PDF)
ifeq ($(words $(TARGETS_PDF)),1)
	echo -e "$(green)Le fichier suivant a été crée avec succès :"
else
	echo -e "$(green)Les fichiers suivants ont été crées avec succès :"
endif
	$(foreach f,$(TARGETS_PDF),(echo -e "  - $f");)
	printf "$(reset)"

## dev : Compile pour éditer
## make dev [VERSION=$(VERSION_DEV)] [PDF_VIEWER=$(PDF_VIEWER)]
.PHONY: dev
dev: latexmk_opts += -pvc
dev: validate/version_dev $(TARGET_DEV)

## view : all + ouvre les PDF dans le visionneur
## make view [PDF_VIEWER=$(PDF_VIEWER)]
.PHONY: view
view: pdfs validate/pdf-viewer
	$(foreach f,$(TARGETS_PDF),($(PDF_VIEWER) $f &);)

## clean : Supprime le dossier $(BUILD_DIR)/
## make clean | cleanall
.PHONY: clean
clean:
	rm -frv $(BUILD_DIR)

## cleanall : clean + supprime le dossier $(PDF_DIR)/
.PHONY: cleanall
cleanall: clean
	rm -frv $(PDF_DIR)

## help : Affiche l'aide
## make help [PAGER=$(PAGER)]
.PHONY: help
help:
	(printf "$$help_message") | $(PAGER)
