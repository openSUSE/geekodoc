<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Fix Schematron patterns

   Parameters:
     None

   Input:
     DocBook 5.x RNG schema with wrong Schematron pattern rules (see below).

   Output:
     DocBook 5.x RNG schema with the correct Schematron pattern rules.

   Background:
      Some DocBook 5 schemas contain expressions like "<s:pattern name="foo">"
      These are not compatible with ISO Schematron which does not have a "name"
      attribute.
      This stylesheet replaces such patterns by <s:pattern><s:title>foo</s:title>

   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright 2017 SUSE Linux GmbH

-->
<xsl:stylesheet version="1.0"
 xmlns:s="http://purl.oclc.org/dsdl/schematron"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

 <xsl:template match="node() | @*" name="copy">
  <xsl:copy>
   <xsl:apply-templates select="@* | node()"/>
  </xsl:copy>
 </xsl:template>

 <xsl:template match="s:pattern[@name]">
  <s:pattern>
   <s:title><xsl:value-of select="@name"/></s:title>
   <xsl:apply-templates/>
  </s:pattern>
 </xsl:template>
</xsl:stylesheet>