#
# Makefile to create "flat" RELAX NG schemas
#
# Author:
#   Thomas Schraitle <toms@opensuse.org>
#
# Requirements:
# * trang
# * rng2srng
# * docbook_5
# * python3-rnginline (from obs://devel:languages:python3/python3-rnginline)


.SUFFIXES: .rng rnc

SUSESCHEMA := geekodoc5
DOCBOOKXI_RNC_PATH  := /usr/share/xml/docbook/schema/rng/5.1/docbookxi.rnc
DOCBOOKXI_RNC := $(notdir $(DOCBOOKXI_RNC_PATH))
DOCBOOKXI_RNG := $(patsubst .rnc,.rng,$(DOCBOOKXI_RNC))


.PHONY: all clean

all: $(SUSESCHEMA)-flat.rnc $(SUSESCHEMA)-flat.rng $(SUSESCHEMA).vim

clean:
	rm $(SUSESCHEMA)-flat.rn{c,g} \
	   $(SUSESCHEMA).vim \
	   $(DOCBOOKXI_RNC) $(DOCBOOKXI_RNG) 2>/dev/null || true


$(DOCBOOKXI_RNC): $(DOCBOOKXI_RNC_PATH)
	@echo "* Linking $< -> $@"
	ln -sf $<

$(SUSESCHEMA).rng: $(SUSESCHEMA).rnc $(DOCBOOKXI_RNC)
	@echo "* Converting $< -> $@"
	trang $< $@

.INTERMEDIATE: $(SUSESCHEMA)-flat.rni
$(SUSESCHEMA)-flat.rni: $(SUSESCHEMA).rng
	@echo "* Flattening $< -> $@"
	rnginline $< $@

$(SUSESCHEMA)-flat.rng: $(SUSESCHEMA)-flat.rni
	echo '* Cleaning up schema contents $< -> $@'
	xmllint -o $@ --nsclean --format $<

$(SUSESCHEMA)-flat.rnc: $(SUSESCHEMA)-flat.rng
	@echo "* Converting $< -> $@"
	trang $< $@
	@sed -i -r 's_\s+$$__' $@

# .INTERMEDIATE: $(SUSESCHEMA)-flat.srng
$(SUSESCHEMA)-flat.srng: $(SUSESCHEMA)-flat.rng
	echo '* Creating Simplified RNG version'
	rng2srng $< | xmllint --format - > $@

$(SUSESCHEMA).vim: $(SUSESCHEMA)-flat.srng
	echo '* Creating VIM XML Omni Datafile...'
	xsltproc -o $@ ../../rng2vim.xsl $<
