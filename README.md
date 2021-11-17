# GeekoDoc

[![Validating GeekoDoc](https://github.com/openSUSE/geekodoc/actions/workflows/validate.yml/badge.svg)](https://github.com/openSUSE/geekodoc/actions/workflows/validate.yml)

## What is GeekoDoc?

GeekoDoc is a RELAX NG schema and a subset of DocBook 5. It restricts the
content model of some elements and attributes to make it easier to
write documents.

Valid GeekoDoc documents are also valid DocBook 5 documents.

## GeekoDoc Versions

GeekoDoc comes in two versions that are currently very similar.
Their main difference is that GeekoDoc 2 restricts `xml:id` attributes
to a more SEO-friendly subset of characters. More changes are to be
expected in the future.

In general, we recommend using GeekoDoc 2 for all new projects.

* GeekoDoc 1: available via the URI `urn:x-suse:rng:v1:geekodoc-flat`
* GeekoDoc 2: available via the URI `urn:x-suse:rng:v2:geekodoc-flat`

## Additional versions of GeekoDoc

* New, versioned URIs:
  * Available for GeekoDoc 1 and GeekoDoc 2
  * General syntax: `urn:x-suse:FORMAT:VERSION:SCHEMA`
    * FORMAT: can be `rnc` or `rng`
    * VERSION: can be `v1` or `v2`
    * SCHEMA: `geekodoc-flat`
  * Includes the following URIs:

        urn:x-suse:rnc:v1:geekodoc-flat
        urn:x-suse:rng:v1:geekodoc-flat
        urn:x-suse:rnc:v2:geekodoc-flat
        urn:x-suse:rng:v2:geekodoc-flat

* Old, unversioned URIs (do not use for new projects):
  * Only available for GeekoDoc 1
  * General syntax: `urn:x-suse:rng:FILE`
  * Includes the following URIs:

        urn:x-suse:rng:geekodoc5.rnc
        urn:x-suse:rng:geekodoc5-flat.rnc
        urn:x-suse:rng:geekodoc5.rng
        urn:x-suse:rng:geekodoc5-flat.rng

## Using GeekoDoc with DAPS

To use GeekoDoc for validating your XML documents with DAPS, add the
following line in your `~/.config/daps/dapsrc` and replace `<URI>`
with one of the URIs above:

    DOCBOOK5_RNG_URI="<URI>"

It is possible to add the previous line into a DC file.

## Creating Flat GeekoDoc

Creating the flat GeekoDoc schema requires the `rnginline` tool from
<https://github.com/h4l/rnginline/>.

Use one of the following methods to install `rnginline`:

* Install from an RPM package
* Install it in a Python virtual environment

### Installing rnginline from RPM Package on openSUSE

The following procedure can be used for the latest openSUSE Leap release:

1. Add the `devel:languages:python` repository:

   * for openSUSE Leap:

         sudo zypper ar https://download.opensuse.org/repositories/devel:/languages:/python/openSUSE_Leap_\$releasever/devel:languages:python.repo

   * for openSUSE Tumbleweed:

         sudo zypper ar https://download.opensuse.org/repositories/devel:/languages:/python/openSUSE_Tumbleweed/devel:languages:python.repo

2. Install the package:

       sudo zypper in python3-rnginline

The executable can be found in `/usr/bin/rnginline`.

### Installing rnginline using a Python Virtual Environment

1. Install the RPM packages `python3-devel`, `libxml2-devel`, and `libxslt-devel`.
   On openSUSE, run:

       sudo zypper in python3-devel libxml2-devel libxslt-devel

2. Create a Python3 virtual environment:

       python3 -m venv .env3

3. Activate the virtual environment:

       source .env3/bin/activate

   You should see a changed prompt (look for the `(.env3)` part).

4. Install the `rnginline` library from PyPi:

       pip install rnginline

The executable can be found in `.env3/bin/rnginline`.

### Creating a Flat GeekoDoc Schema

1. Update your GitHub repository.

2. Run `./build.sh`.

3. Find the built schema in `dist/geekodoc/rng/`.

### Installing it on Debian/Ubuntu

To install GeekoDoc on Debian or Ubuntu from scratch, do the following steps:

1. [Create a virtual Python environment with rnginline](#Installing-rnginline-using-a-Python-Virtual-Environment).

2. [Create a Flat Geekodoc Schema](#Creating-a-Flat-GeekoDoc-Schema)

3. Copy the XML catalog file to the standard location:

       cp -v catalog.d/geekodoc.xml /etc/xml/geekodoc.xml

4. Adapt the paths in the catalog file:

       sed -i 's#"\.\./#"/usr/share/xml/#' /etc/xml/geekodoc.xml

5. Create the target directory and copy the schema files:

       mkdir -p /usr/share/xml/rng
       cp -v geekodoc/rng/*-flat.rn? /usr/share/xml/rng

6. Adapt the main XML catalog:

       sudo xmlcatalog --noout --add delegateSystem \
           https://github.com/openSUSE/geekodoc/ /etc/xml/geekodoc.xml /etc/xml/catalog
       sudo xmlcatalog --noout --add delegateURI "urn:x-suse:rng:" \
           /etc/xml/geekodoc.xml /etc/xml/catalog
       sudo xmlcatalog --noout --add delegateSystem "urn:x-suse:rng:" \
           /etc/xml/geekodoc.xml /etc/xml/catalog

7. Test the installation:

       xmlcatalog /etc/xml/catalog \
           https://github.com/openSUSE/geekodoc/raw/master/geekodoc/rng/geekodoc5-flat.rnc \
           urn:x-suse:rng:geekodoc5.rng \
           urn:x-suse:rnc:v1:geekodoc-flat \
           urn:x-suse:rng:v1:geekodoc-flat \
           urn:x-suse:rnc:v2:geekodoc-flat \
           urn:x-suse:rng:v2:geekodoc-flat

   You should get something like this:

        /usr/share/xml/geekodoc/rng/geekodoc5-flat.rnc
        No entry for SYSTEM urn:x-suse:rng:geekodoc5.rng
        /usr/share/xml/geekodoc/rng/geekodoc5-flat.rng

## Supporting Vim

To work with RELAX NG and vim, you need a `.vim` file. This file
is generated from the flat RNG schema.

To extract all relevant information for Vim, use the `rng2vim` tool
from <https://github.com/jhradilek/rng2vim>.

    rng2vim geekodoc5-flat.rng geekodoc

The file `geekodoc.vim` can be used with vim.

## Creating an Archive for Open Build Service

If you develop on GeekoDoc and would like to create an archive file
for OBS, use the following steps:

1. Configure first the `bzip` command (this has to be done only once):

       git config tar.tar.bz2.command "bzip2 -c"

2. Create an archive and save it in your OBS directory (`OBSDIR`):

       git archive --format=tar.bz2 --prefix=geekodoc-2.0.1/ -o <OBSDIR>/geekodoc-2.0.1.tar.bz2 HEAD
