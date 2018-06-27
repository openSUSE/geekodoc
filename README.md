# SUSE Schemas

[![Build Status](https://travis-ci.org/openSUSE/geekodoc.svg?branch=develop)](https://travis-ci.org/openSUSE/geekodoc)


## NovDoc

This is the Novdoc and Geekodoc schemas. Although Novdoc is technically not
based on DocBook the tags and structure are.

In general, XML instances of Novdoc should be compatible to DocBook.


## GeekoDoc

GeekoDoc is a RELAX NG schema and a subset of DocBook 5. Currently, it can be
used in two variants:

1. As the file `geekodoc5.rn{c,g}` which is based on `docbookxi.rn{c,g}`. In
   other words, the GeekoDoc schema cannot life without the DocBook schema.
2. As a single`geekodoc5-flat.rn{c,g}`. This file is independant from the
   DocBook schema and can be used without having DocBook 5 installed on
   your system.

Both variants contain the same structure, elements, and attributes. They
serve different purposes.


## Creating Flat GeekoDoc

Creating the flat GeekoDoc schema requires the `rnginline` tool at
https://github.com/h4l/rnginline/

Use one of the following methods to install `rnginline`:

* Install from an RPM package
* Install it in a Python virtual environment


### Installing rnginline from RPM Package

The following procedure can be used for the latest openSUSE Leap release:

1. Add the repository:

   ```
   $ sudo zypper ar https://download.opensuse.org/repositories/devel:/languages:/python/openSUSE_Leap_\$releasever/devel:languages:python.repo
   ```

2. Install it:

   ```
   $ sudo zypper in python3-rnginline
   ```

The executable can be found in `/usr/bin/rnginline`.


### Installing rnginline using a Python Virtual Environment

1. Install the RPM packages `python3-devel`, `libxml2-devel`, and `libxslt-devel`.

2. Create a Python3 virtual environment:

   ```
   $ python3 -m venv .env3
   ```

3. Activate the virtual environment:

   ```
   $ source .env3/bin/activate
   ```

   => You should see a changed prompt (look for the "(.env3)" part).

3. Install the `rnginline` library from PyPi:

   ```
   $ pip install rnginline
   ```


The executable can be found in `.env3/bin/rnginline`.


### Creating a Flat GeekoDoc Schema

1. Update your GitHub repository.

2. Change the directory to `geekodoc/rng`.

3. Run `make`.


## Supporting Vim

To work with RELAX NG and vim, you need a `.vim` file. This file
is generated from the flat RNG schema.

To extract all relevant information for Vim, use the `rng2vim` tool
from https://github.com/jhradilek/rng2vim.

```
$ rng2vim geekodoc5-flat.rng geekodoc
```

The file `geekodoc.vim` can be used with vim.
