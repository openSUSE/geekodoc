#
# Makefile to create "flat" RELAX NG schemas
#
# Author:
#   Thomas Schraitle <toms@opensuse.org>
#
# Requirements:
# * trang
# * docbook_5 (from obs://Publishing)
# * python3-rnginline (from obs://devel:languages:python/python3-rnginline)


.SUFFIXES: .rng rnc

SUSESCHEMA := geekodoc5
SUSESCHEMA_RNC := $(SUSESCHEMA)-flat.rnc
SUSESCHEMA_RNG := $(patsubst %.rnc, %.rng, $(SUSESCHEMA_RNC))
DOCBOOKXI_RNC_PATH  := /usr/share/xml/docbook/schema/rng/5.1/docbookxi.rnc
DOCBOOKXI_RNG_PATH  := $(patsubst %.rnc, %.rng, $(DOCBOOKXI_RNC_PATH))
DOCBOOKXI_RNC := $(notdir $(DOCBOOKXI_RNC_PATH))
DOCBOOKXI_RNG := $(patsubst %.rnc, %.rng, $(DOCBOOKXI_RNC))


.PHONY: all clean

all: $(SUSESCHEMA_RNC) $(SUSESCHEMA_RNG)

clean:
	rm $(DOCBOOKXI_RNC) $(DOCBOOKXI_RNG) $(SUSESCHEMA)*.rng \
	transclusion.rng \
	2>/dev/null || true


#
# HINT:
# We can't just link it from the system, we need to apply
# a stylesheet to fix some Schematron pattern rules first
# (see openSUSE/geekodoc#22)
# From here we can create the RNC. Here it is a visual
# presentation:
#
# DB RNG --[XSLT]--> DB RNG2 --[trang]--> DB RNC
#
$(DOCBOOKXI_RNG): $(DOCBOOKXI_RNG_PATH)
	@echo "* Fixing DocBook RNG schema..."
	xsltproc --output $@ ../xsl/sch-fix.xsl $<

$(DOCBOOKXI_RNC): $(DOCBOOKXI_RNG)
	@echo "* Converting DocBook $< -> $@"
	trang $< $@

# .INTERMEDIATE: $(SUSESCHEMA).rng
$(SUSESCHEMA).rng: $(SUSESCHEMA).rnc $(DOCBOOKXI_RNC)
	@echo "* Converting $< -> $@"
	trang $< $@

.INTERMEDIATE: $(SUSESCHEMA)-flat.rni
$(SUSESCHEMA)-flat.rni: $(SUSESCHEMA).rng
	@echo "* Flattening $< -> $@"
	rnginline $< $@

# .INTERMEDIATE: $(SUSESCHEMA)-flat.rng
$(SUSESCHEMA_RNG): $(SUSESCHEMA)-flat.rni
	@echo '* Cleaning up schema contents $< -> $@'
	xmllint -o $@ --nsclean --format $<

$(SUSESCHEMA_RNC): $(SUSESCHEMA_RNG)
	@echo "* Converting $< -> $@"
	trang $< $@
	@sed -i -r 's_\s+$$__' $@
