# Makefile to create "flat" RELAX NG schemas
#
# Dependencies
#  Our main file is geekodoc-v?.rnc. It depends on:
#    * transclusion.rnc
#      a failed attempt to work with transclusions; can be probably removed
#    * its.rnc
#      integration of ITS 2.0 markup, see http://www.w3.org/TR/its20/
#    * docbook.rnc
#      the upstream schema file
#
# Process
#  geekodoc.rnc # (1)
#  +--> geekodoc.rng #(2)
#       +--> geekodoc-flat.rni # (3)
#            +--> geekodoc-flat.rng # (4)
#                 +--> geekodoc-flat.rnc # (5)
#
# (1) This is our main file; all changes to the upstream schema go here
# (2) We need to create the XML format (RNG) first to process it with
#     our XML tools
# (3) The flat.rni file contains the "raw" representation of the
#     schema in one file; it is an intermediate file and is automatically
#     removed
# (4) Apply cleanups to flat.rni to create flat.rng
# (5) The end result, which can be used independently from DocBook or Geekodoc
#     source files
#
# Authors:
#   Thomas Schraitle <toms@opensuse.org>
#   Stefan Knorr <sknorr@suse.de>
# Date:
#   2015-2020
#
# Requirements:
# * trang
# * docbook_5 (from obs://Publishing)
# * python3-rnginline (from obs://devel:languages:python/python3-rnginline)

BUILD_DIR  := build
BUILD_GD   := $(BUILD_DIR)/geekodoc

VERSIONS   := geekodoc-v-1.0-db5.1 geekodoc-v-2.0-db5.1


.PHONY: all
all: $(VERSIONS)

.PHONY: $(VERSIONS)
$(VERSIONS):geekodoc-v-%: $(BUILD_GD)/%/geekodoc.rnc | $(BUILD_GD)/%

$(BUILD_GD) $(BUILD_TEMP):%:
	mkdir -p $@

$(BUILD_TEMP)/%.rng: %.rnc $(ALL_ITS) $(ALL_TRANS)
	@echo "* Converting RNC $< -> RNG $@"
	@trang $< $@


%-flat.rni: %.rng
	@echo "* Flattening $< -> $@"
	rnginline $< $@

.INTERMEDIATE: $(BUILD_GD)/%.rni
$(BUILD_GD)/*/*.rng:%.rng: $(BUILD_GD)/%.rni
	@echo '* Cleaning up schema contents $< -> $@'
	xmllint -o $@ --nsclean --format $<

$(BUILD_GD)/*/*.rnc:build/geekodoc/1.0-db5.1/%.rnc: %.rng
	@echo "* Converting $< -> $@"
	trang $< $@
	@sed -i -r 's_\s+$$__' $@




PHONY: clean
clean:
	@rm -rfv $(BUILD_DIR) 2> /dev/null || true

# === Directories
#GEEKODOC_DIR := geekodoc
#GEEKODOC_RNG_DIR := $(GEEKODOC_DIR)/rng
#GEEKODOC1_PATH := $(GEEKODOC_RNG_DIR)/5.1_1
#GEEKODOC2_PATH := $(GEEKODOC_RNG_DIR)/5.1_2
#XSLT_DIR := $(GEEKODOC_DIR)/xsl

## == DocBook RELAX NGs
#DOCBOOKXI_RNG_PATH  := /usr/share/xml/docbook/schema/rng/5.1/docbookxi.rng
#DOCBOOKXI_RNC := $(notdir $(DOCBOOKXI_RNC_PATH))
#DOCBOOKXI_RNG := $(notdir $(DOCBOOKXI_RNG_PATH))

## === Naming
## The naming was quite bad, so geekodoc5 version 1 refers to DocBook5,
## not Geekodoc v5;
## we'll provide a compatibility link from geekodoc-v1 -> geekodoc5
#GEEKODOC1_NAME := geekodoc-v1
## Here it contains the "real" version:
#GEEKODOC2_NAME := geekodoc-v2
## The RNG filename to validate with:
#RELAXNG_RNG := relaxng.rng

# GEEKODOC1_DB_LINK := $(GEEKODOC1_PATH)/$(notdir $(DOCBOOKXI_RNC_PATH))
# GEEKODOC2_DB_LINK := $(GEEKODOC2_PATH)/$(notdir $(DOCBOOKXI_RNC_PATH))

# === Files
#SCH_FIX := $(XSLT_DIR)/sch-fix.xsl

#RELAXNG_BASE := $(GEEKODOC_RNG_DIR)/$(RELAXNG_RNG)

#GEEKODOC1_BASE := $(GEEKODOC1_PATH)/$(GEEKODOC1_NAME)
#GEEKODOC2_BASE := $(GEEKODOC2_PATH)/$(GEEKODOC2_NAME)

#GEEKODOC1_RNC := $(GEEKODOC1_BASE).rnc
#GEEKODOC1_FLAT_RNC := $(GEEKODOC1_BASE)-flat.rnc
#GEEKODOC1_FLAT_RNG := $(patsubst %.rnc, %.rng, $(GEEKODOC1_FLAT_RNC))
#GEEKODOC1_FLAT_RNI := $(patsubst %.rnc, %.rni, $(GEEKODOC1_FLAT_RNC))
#GEEKODOC1_RNG := $(GEEKODOC1_BASE).rng


# == Targets
# Our targets we need to build:
# TARGETS := $(GEEKODOC1_FLAT_RNC) $(GEEKODOC2_FLAT_RNC) $(DOCBOOKXI_RNC)

#ALL_DOCBOOK := $(GEEKODOC1_PATH)/$(DOCBOOKXI_RNC) \
#               $(GEEKODOC2_PATH)/$(DOCBOOKXI_RNC)

#ALL_ITS := $(GEEKODOC1_PATH)/its.rnc $(GEEKODOC2_PATH)/its.rnc
#ALL_TRANS := $(GEEKODOC1_PATH)/transclusion.rnc $(GEEKODOC2_PATH)/transclusion.rnc

#ALL_OTHER := $(ALL_DOCBOOK) $(ALL_ITS) $(ALL_TRANS)

#ALL_GEEKODOC := $(GEEKODOC1_FLAT_RNC) $(GEEKODOC2_FLAT_RNC)


## == More Targets
#ALL_RNI := $(GEEKODOC1_FLAT_RNI) $(GEEKODOC2_FLAT_RNI)
#ALL_RNG := $(GEEKODOC1_FLAT_RNG) $(GEEKODOC2_FLAT_RNG)
#ALL_RNC := $(GEEKODOC1_FLAT_RNC) $(GEEKODOC2_FLAT_RNC)


#.PHONY: all clean
#all:    $(ALL_GEEKODOC) $(ALL_OTHER)

#clean:
#	@rm -v $(ALL_OTHER) $(ALL_RNG) $(ALL_RNI) $(ALL_RNC) \
#	$(GEEKODOC1_RNG) $(GEEKODOC2_RNG) \
#	2>/dev/null || true


#$(TARGETS): % : $(ALL_GEEKODOC)
#	@echo "Building targets: $< => $@"


# ----------------------

#%.rng: %.rnc $(ALL_ITS) $(ALL_TRANS)
#	@echo "* Converting RNC $< -> RNG $@"
#	@trang $< $@


#%-flat.rni: %.rng
#	@echo "* Flattening $< -> $@"
#	rnginline $< $@

#.INTERMEDIATE: %-flat.rni
#%-flat.rng: %-flat.rni
#	@echo '* Cleaning up schema contents $< -> $@'
#	xmllint -o $@ --nsclean --format $<

#%-flat.rnc: %-flat.rng
#	@echo "* Converting $< -> $@"
#	trang $< $@
#	@sed -i -r 's_\s+$$__' $@

#$(ALL_ITS): $(GEEKODOC_RNG_DIR)/its.rnc
#	@echo "* Copying ITS schema $< -> $@"
#	@cp $< $@

#$(ALL_TRANS): $(GEEKODOC_RNG_DIR)/transclusion.rnc
#	@echo "* Copying Transclusion schema $< -> $@"
#	@cp $< $@

##
## The DocBook projects upstream schema includes broken Schematron patterns.
## This is fixed in the OBS-packaged version of the schema, but if we
## get an old, unfixed DocBook, apply the stylesheet
## (see openSUSE/geekodoc#22). We use this process flow:
##
## DB5 RNG --[XSLT]--> DB5 RNG2 --[trang]--> DB5 RNC
##

#$(GEEKODOC_RNG_DIR)/$(DOCBOOKXI_RNG): $(DOCBOOKXI_RNG_PATH)
#	@echo "* Fixing DocBook RNG schema..."
#	xsltproc --output $@ bin/schema-fix.xsl $<

#$(GEEKODOC_RNG_DIR)/$(DOCBOOKXI_RNC): $(GEEKODOC_RNG_DIR)/$(DOCBOOKXI_RNG)
#	@echo "* Converting DocBook $< -> $@"
#	trang $< $@

#$(ALL_DOCBOOK): $(GEEKODOC_RNG_DIR)/$(DOCBOOKXI_RNC)
#	@cp $< $@
