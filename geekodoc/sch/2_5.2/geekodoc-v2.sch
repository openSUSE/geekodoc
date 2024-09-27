<?xml version="1.0" encoding="UTF-8"?>
<!--
   GeekoDoc Schematron schema v2

Purpose:
   Validate elements, attributes, or other structures that are difficult
   to validate in the GeekoDoc RNG schema.

Author:  Thomas Schraitle, 2023
-->
<s:schema xmlns:s="http://purl.oclc.org/dsdl/schematron"
  xmlns:db="http://docbook.org/ns/docbook"
  xmlns:pr="http://www.schematron-quickfix.com/validator/process"
   queryBinding="xslt"
>
  <s:ns prefix="db" uri="http://docbook.org/ns/docbook"/>
  <s:ns prefix="xlink" uri="http://www.w3.org/1999/xlink"/>
  <s:ns prefix="trans" uri="http://docbook.org/ns/transclusion"/>

  <!-- Variables -->
  <s:let name="meta-title-length" value="55"/>
  <s:let name="meta-description-length" value="150"/>

  <s:pattern>
    <s:title>Validate meta elements</s:title>
    <s:rule context="db:meta[@name='title']">
      <s:assert test="string-length(.) &lt;= $meta-title-length">
        The element meta[@name="title"] cannot have more than <s:value-of select="$meta-title-length"/> characters.
      </s:assert>
    </s:rule>

    <s:rule context="db:meta[@name='description']">
      <s:assert test="string-length(.) &lt;= $meta-description-length">
        The element meta[@name="description"] cannot have more than <s:value-of select="$meta-description-length"/> characters.
      </s:assert>
    </s:rule>
  </s:pattern>

</s:schema>