<?xml version="1.0" encoding="UTF-8"?>
<s:schema xmlns:s="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt">
 <s:title>Schematron Schema for GeekoDoc</s:title>
 <s:p>GeekoDoc Schematron</s:p>

 <s:ns prefix="a" uri="http://relaxng.org/ns/compatibility/annotations/1.0"/>
 <s:ns prefix="ctrl" uri="http://nwalsh.com/xmlns/schema-control/"/>
 <s:ns prefix="db" uri="http://docbook.org/ns/docbook"/>
 <s:ns prefix="html" uri="http://www.w3.org/1999/xhtml"/>
 <s:ns prefix="its" uri="http://www.w3.org/2005/11/its"/>
 <s:ns prefix="mml" uri="http://www.w3.org/1998/Math/MathML"/>
 <s:ns prefix="rng" uri="http://relaxng.org/ns/structure/1.0"/>
 <s:ns prefix="s" uri="http://purl.oclc.org/dsdl/schematron"/>
 <s:ns prefix="svg" uri="http://www.w3.org/2000/svg"/> 
 <s:ns prefix="xlink" uri="http://www.w3.org/1999/xlink"/>

 <s:pattern>
  <s:title>General Checks</s:title>
  <s:rule id="spaces-in-xmlid" context="*/@xml:id" see="spaces-in-xmlid">
   <s:assert test="not(contains(., ' '))">No spaces in xml:id's!</s:assert>
  </s:rule>
 </s:pattern>

 <s:pattern id="list-with-title-and-xmlid">
  <s:title>All lists with a title should have a xml:id</s:title>
  <s:rule id="itemizedlist-title-and-xmlid" context="db:itemizedlist[db:title]">
   <s:assert test="@xml:id">an <s:value-of select="local-name()"/> with a title must have a xml:id attribute</s:assert>
  </s:rule>
  <s:rule id="orderedlist-title-and-xmlid" context="db:orderedlist[db:title]">
   <s:assert test="@xml:id">an <s:value-of select="local-name()"/> with a title must have a xml:id attribute</s:assert>
  </s:rule>
  <s:rule id="variablelist-title-and-xmlid" context="db:variablelist[db:title]">
   <s:assert test="@xml:id">an <s:value-of select="local-name()"/> with a title must have a xml:id attribute</s:assert>
  </s:rule>
  <s:rule id="procedure-title-and-xmlid" context="db:procedure[db:title]">
   <s:assert test="@xml:id">a <s:value-of select="local-name()"/> with a title must have a xml:id attribute</s:assert>
  </s:rule>
 </s:pattern>

 <s:pattern id="list-checks">
  <s:title>Checks for amount of child elements in lists</s:title>
  <s:rule id="procedure-one-step" context="db:procedure">
   <s:assert test="not(count(db:step) = 1)">A procedure must contain more than one step</s:assert>
  </s:rule>
  <s:rule id="orderedlist-one-listitem" context="db:orderedlist">
   <s:assert test="not(count(db:listitem) = 1)">An orderedlist must contain more than one listitems</s:assert>
  </s:rule>
  <s:rule id="itemizedlist-one-listitem" context="db:itemizedlist">
   <s:assert test="not(count(db:listitem) = 1)">An orderedlist must contain more than one listitems</s:assert>
  </s:rule>
  <s:rule id="simplelist-one-member" context="db:simplelist">
   <s:assert test="not(count(db:member) = 1)">A simplelist must contain more than one member</s:assert>
  </s:rule>
 </s:pattern>
</s:schema>