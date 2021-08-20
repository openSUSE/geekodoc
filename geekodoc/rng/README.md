# README


## What?
This directory contains RELAX NG files to validate the SUSE
documentation.


## Where?

There are two incarnations of the SUSE schema:

* `geekodoc-v1.rnc`, `geekodoc-v2.rnc`
   These are the main files where development is taking place. 
   GeekoDoc v1 depends on `docbookxi.rnc` (version 5.1) whereas
   GeekoDoc v2 it depends on `dbitsxi.rnc` (version 5.2).
   Don't use this in a production environment.

* `geekodoc-v1-flat.rnc`, `geekodoc-v2-flat.rnc`
   These files are (auto-)generated. It doesn't contain any dependencies
   to DocBook 5.x anymore.
   Use this when writing your documents.

The schema itself is delivered both as RNC (compact RELAX NG) and as RNG
(XML).

