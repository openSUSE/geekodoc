<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt">
 <sch:title>Schematron Schema for GeekoDoc</sch:title>
 <sch:p>GeekoDoc Schematron</sch:p>

 <sch:ns prefix="a" uri="http://relaxng.org/ns/compatibility/annotations/1.0"/>
 <sch:ns prefix="ctrl" uri="http://nwalsh.com/xmlns/schema-control/"/>
 <sch:ns prefix="db" uri="http://docbook.org/ns/docbook"/>
 <sch:ns prefix="html" uri="http://www.w3.org/1999/xhtml"/>
 <sch:ns prefix="its" uri="http://www.w3.org/2005/11/its"/>
 <sch:ns prefix="mml" uri="http://www.w3.org/1998/Math/MathML"/>
 <sch:ns prefix="rng" uri="http://relaxng.org/ns/structure/1.0"/>
 <sch:ns prefix="s" uri="http://purl.oclc.org/dsdl/schematron"/>
 <sch:ns prefix="svg" uri="http://www.w3.org/2000/svg"/> 
 <sch:ns prefix="xlink" uri="http://www.w3.org/1999/xlink"/>

 <sch:pattern>
  <sch:title>General Checks</sch:title>
  <sch:rule id="spaces-in-xmlid" context="*/@xml:id" see="spaces-in-xmlid">
   <sch:assert test="not(contains(., ' '))">No spaces in xml:id's!</sch:assert>
  </sch:rule>
 </sch:pattern>

 <sch:pattern id="list-with-title-and-xmlid">
  <sch:title>All lists with a title should have a xml:id</sch:title>
  <sch:rule id="itemizedlist-title-and-xmlid" context="db:itemizedlist[db:title]">
   <sch:assert test="@xml:id">an <sch:value-of select="local-name()"/> with a title must have a xml:id attribute</sch:assert>
  </sch:rule>
  <sch:rule id="orderedlist-title-and-xmlid" context="db:orderedlist[db:title]">
   <sch:assert test="@xml:id">an <sch:value-of select="local-name()"/> with a title must have a xml:id attribute</sch:assert>
  </sch:rule>
  <sch:rule id="variablelist-title-and-xmlid" context="db:variablelist[db:title]">
   <sch:assert test="@xml:id">an <sch:value-of select="local-name()"/> with a title must have a xml:id attribute</sch:assert>
  </sch:rule>
  <sch:rule id="procedure-title-and-xmlid" context="db:procedure[db:title]">
   <sch:assert test="@xml:id">a <sch:value-of select="local-name()"/> with a title must have a xml:id attribute</sch:assert>
  </sch:rule>
 </sch:pattern>
</sch:schema>