#
# Makefile to create Novdoc schemas
#
# Author:
#   Thomas Schraitle <toms@opensuse.org>
#
# Requirements:
# * trang
# * python3-rnginline (from obs://home:thomas-schraitle/python3-rnginline)


.SUFFIXES: .rng rnc

SCHEMA := novdocx
SCHEMAXI := novdocxi
DTDPATH := ../dtd
BASEDTD := $(SCHEMA).dtd
BASETMPDTD := $(BASEDTD).tmp
DTD := $(DTDPATH)/$(BASEDTD)

.PHONY: all clean

all: $(SCHEMA).rng $(SCHEMAXI).rng $(SCHEMAXI)-flat.rnc $(SCHEMAXI)-flat.rng

clean:
	rm $(SCHEMA)*.rng $(SCHEMAXI)*.rng \
	   $(SCHEMA)-core.rn? \
	   $(SCHEMAXI)-flat.rn? 2>/dev/null || true

.INTERMEDIATE: $(SCHEMA)-flat.rni $(SCHEMAXI)-flat.rni
.INTERMEDIATE: $(BASETMPDTD)


$(BASETMPDTD): $(DTD)
	sed 's:\(%[ \t]*ISO[^\.]*\.module[ \t]*\)"INCLUDE":\1"IGNORE":g' \
< $< > $@


$(SCHEMAXI)-flat.rni: $(SCHEMAXI).rng
	@echo "* Flattening $< -> $@"
	rnginline $< $@

$(SCHEMAXI)-flat.rng: $(SCHEMAXI)-flat.rni
	@echo '* Cleaning up schema contents $< -> $@'
	xmllint -o $@ --nsclean --format $<

$(SCHEMAXI)-flat.rnc: $(SCHEMAXI)-flat.rng
	@echo "* Converting $< -> $@"
	trang $< $@
	sed -i -r 's_\s+$$__' $@

$(SCHEMA).rng: $(SCHEMA).rnc $(SCHEMA)-core.rnc
	@echo "Converting with trang: $< -> $@"
	trang -I rnc $< $@

$(SCHEMAXI).rng: $(SCHEMAXI).rnc $(SCHEMA)-core.rnc
	@echo "Converting with trang: $< -> $@"
	trang -I rnc $< $@

$(SCHEMA)-core.rnc: $(BASETMPDTD)
	trang -I dtd -i no-generate-start $< $@

$(SCHEMA)-core.rng: $(BASETMPDTD)
	trang -I dtd -i no-generate-start $< $@
