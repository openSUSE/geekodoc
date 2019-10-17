#
# Makefile to create "flat" RELAX NG schemas
#
# Dependencies
#  Our main file is geekodoc-v?.rnc. It depends on:
#    * transclusion.rnc
#      a failed attempt to work with transclusions; can be probably removed
#    * its.rnc
#      integration of ITS 2.0 markup, see http://www.w3.org/TR/its20/
#    * docbook.rnc
#      well, our main schema file
#
# Process Flow
#  geekodoc-v?.rnc # (1)
#  +--> geekodoc-v?.rng #(2)
#       +--> geekodoc-v?-flat.rni # (3)
#            +--> geekodoc-v?-flat.rng # (4)
#                 +--> geekodoc-v?-flat.rnc # (5)
#
# (1) This is our main file; all changes goes here
# (2) We need to create the XML format (RNG) first to process it with
#     our XML tools
# (3) The flat.rni file contains the "raw" representation of the
#     schema in one file; it is an intermediate file and is automatically
#     removed
# (4) Some cleanup applied to flat.rni creates the flat.rng
# (5) The end result which is independant from any DocBook or Geekodoc
#     resources
#
# Author:
#   Thomas Schraitle <toms@opensuse.org>
# Date:
#   ?-2019
#
# Requirements
# * trang
# * docbook_5 (from obs://Publishing)
# * python3-rnginline (from obs://devel:languages:python/python3-rnginline)


.SUFFIXES: .rnc rng

# === Directories
GEEKODOC_DIR := geekodoc
GEEKODOC_RNG_DIR := $(GEEKODOC_DIR)/rng
GEEKODOC1_PATH := $(GEEKODOC_RNG_DIR)/5.1_1
GEEKODOC2_PATH := $(GEEKODOC_RNG_DIR)/5.1_2
XSLT_DIR := $(GEEKODOC_DIR)/xsl

# == DocBook RELAX NGs
DOCBOOKXI_RNC_PATH  := /usr/share/xml/docbook/schema/rng/5.1/docbookxi.rnc
DOCBOOKXI_RNG_PATH  := $(patsubst %.rnc, %.rng, $(DOCBOOKXI_RNC_PATH))
DOCBOOKXI_RNC := $(notdir $(DOCBOOKXI_RNC_PATH))
DOCBOOKXI_RNG := $(notdir $(DOCBOOKXI_RNG_PATH))

# === Naming
# The naming was quite bad, so geekodoc5 version 1 refers to DocBook5,
# not Geekodoc v5;
# we'll provide a compatibility link from geekodoc-v1 -> geekodoc5
GEEKODOC1_NAME := geekodoc-v1
# Here it contains the "real" version:
GEEKODOC2_NAME := geekodoc-v2
# The RNG filename to validate with:
RELAXNG_RNG := relaxng.rng

# GEEKODOC1_DB_LINK := $(GEEKODOC1_PATH)/$(notdir $(DOCBOOKXI_RNC_PATH))
# GEEKODOC2_DB_LINK := $(GEEKODOC2_PATH)/$(notdir $(DOCBOOKXI_RNC_PATH))

# === Files
SCH_FIX := $(XSLT_DIR)/sch-fix.xsl

RELAXNG_BASE := $(GEEKODOC_RNG_DIR)/$(RELAXNG_RNG)

GEEKODOC1_BASE := $(GEEKODOC1_PATH)/$(GEEKODOC1_NAME)
GEEKODOC2_BASE := $(GEEKODOC2_PATH)/$(GEEKODOC2_NAME)

GEEKODOC1_RNC := $(GEEKODOC1_BASE).rnc
GEEKODOC1_FLAT_RNC := $(GEEKODOC1_BASE)-flat.rnc
GEEKODOC1_FLAT_RNG := $(patsubst %.rnc, %.rng, $(GEEKODOC1_FLAT_RNC))
GEEKODOC1_FLAT_RNI := $(patsubst %.rnc, %.rni, $(GEEKODOC1_FLAT_RNC))
GEEKODOC2_RNC := $(GEEKODOC2_BASE).rnc
GEEKODOC2_FLAT_RNC := $(GEEKODOC2_BASE)-flat.rnc
GEEKODOC2_FLAT_RNG := $(patsubst %.rnc, %.rng, $(GEEKODOC2_FLAT_RNC))
GEEKODOC2_FLAT_RNI := $(patsubst %.rnc, %.rni, $(GEEKODOC2_FLAT_RNC))
GEEKODOC1_RNG := $(GEEKODOC1_BASE).rng
GEEKODOC2_RNG := $(GEEKODOC2_BASE).rng


# == Targets
# Our targets we need to build:
# TARGETS := $(GEEKODOC1_FLAT_RNC) $(GEEKODOC2_FLAT_RNC) $(DOCBOOKXI_RNC)

ALL_DOCBOOK := $(GEEKODOC1_PATH)/$(DOCBOOKXI_RNC) \
               $(GEEKODOC2_PATH)/$(DOCBOOKXI_RNC)

ALL_ITS := $(GEEKODOC1_PATH)/its.rnc $(GEEKODOC2_PATH)/its.rnc
ALL_TRANS := $(GEEKODOC1_PATH)/transclusion.rnc $(GEEKODOC2_PATH)/transclusion.rnc

ALL_OTHER := $(ALL_DOCBOOK) $(ALL_ITS) $(ALL_TRANS)

ALL_GEEKODOC := $(GEEKODOC1_FLAT_RNC) $(GEEKODOC2_FLAT_RNC)


# == More Targets
ALL_RNI := $(GEEKODOC1_FLAT_RNI) $(GEEKODOC2_FLAT_RNI)
ALL_RNG := $(GEEKODOC1_FLAT_RNG) $(GEEKODOC2_FLAT_RNG)
ALL_RNC := $(GEEKODOC1_FLAT_RNC) $(GEEKODOC2_FLAT_RNC)


.PHONY: all clean
all:    $(ALL_GEEKODOC) $(ALL_OTHER)

clean:
	@rm -v $(ALL_OTHER) $(ALL_RNG) $(ALL_RNI) $(ALL_RNC) \
	$(GEEKODOC1_RNG) $(GEEKODOC2_RNG) \
	2>/dev/null || true


$(TARGETS): % : $(ALL_GEEKODOC)
	@echo "Building targets: $< => $@"


# ----------------------

%.rng: %.rnc  $(ALL_ITS) $(ALL_TRANS)
	@echo "* Converting RNG $< -> RNC $@"
	@trang $< $@


%-flat.rni: %.rng
	@echo "* Flattening $< -> $@"
	rnginline $< $@

.INTERMEDIATE: %-flat.rni
%-flat.rng: %-flat.rni
	@echo '* Cleaning up schema contents $< -> $@'
	xmllint -o $@ --nsclean --format $<

%-flat.rnc: %-flat.rng
	@echo "* Converting $< -> $@"
	trang $< $@
	@sed -i -r 's_\s+$$__' $@

$(ALL_ITS): $(GEEKODOC_RNG_DIR)/its.rnc
	@echo "* Copying ITS schema  $< -> $@"
	@cp $< $@

$(ALL_TRANS): $(GEEKODOC_RNG_DIR)/transclusion.rnc
	@echo "* Copying Transclusion schema  $< -> $@"
	@cp $< $@

#
# HINT:
# The DocBook project delivered some broken file in regards
# to Schematron patterns.
# This have been fixed in OBS, but just in case we still
# get an old, unfixed DocBook, we apply the stylesheet
# (see openSUSE/geekodoc#22)
#
# From here we can create the RNC. Here it is a visual
# presentation of the process flow:
#
# DB5 RNG --[XSLT]--> DB5 RNG2 --[trang]--> DB5 RNC
#

$(GEEKODOC_RNG_DIR)/$(DOCBOOKXI_RNG): $(DOCBOOKXI_RNG_PATH)
	@echo "* Fixing DocBook RNG schema..."
	xsltproc --output $@ $(SCH_FIX) $<

$(GEEKODOC_RNG_DIR)/$(DOCBOOKXI_RNC): $(GEEKODOC_RNG_DIR)/$(DOCBOOKXI_RNG)
	@echo "* Converting DocBook $< -> $@"
	trang $< $@

$(ALL_DOCBOOK): $(GEEKODOC_RNG_DIR)/$(DOCBOOKXI_RNC)
	@echo "* Copying DocBook schema  $< -> $@"
	@cp $< $@


### Old part, will be removed
# == Old variables
# SUSESCHEMA := geekodoc5
# SUSESCHEMA_RNC := $(SUSESCHEMA)-flat.rnc
# SUSESCHEMA_RNG := $(patsubst %.rnc, %.rng, $(SUSESCHEMA_RNC))
#
# # .INTERMEDIATE: $(SUSESCHEMA).rng
# $(SUSESCHEMA).rng: $(SUSESCHEMA).rnc $(DOCBOOKXI_RNC)
# 	@echo "* Converting $< -> $@"
# 	trang $< $@
#
# .INTERMEDIATE: $(SUSESCHEMA)-flat.rni
# $(SUSESCHEMA)-flat.rni: $(SUSESCHEMA).rng
# 	@echo "* Flattening $< -> $@"
# 	rnginline $< $@
#
# # .INTERMEDIATE: $(SUSESCHEMA)-flat.rng
# $(SUSESCHEMA_RNG): $(SUSESCHEMA)-flat.rni
# 	@echo '* Cleaning up schema contents $< -> $@'
# 	xmllint -o $@ --nsclean --format $<
#
# $(SUSESCHEMA_RNC): $(SUSESCHEMA_RNG)
# 	@echo "* Converting $< -> $@"
# 	trang $< $@
# 	@sed -i -r 's_\s+$$__' $@
#
