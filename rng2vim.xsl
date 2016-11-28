<?xml version="1.0" encoding="UTF-8"?>
<!--

-->
<xsl:stylesheet version="1.0"
 xmlns:rng = "http://relaxng.org/ns/structure/1.0"
 xmlns:a="http://relaxng.org/ns/compatibility/annotations/1.0" 
 xmlns:s="http://purl.oclc.org/dsdl/schematron"
 xmlns:d = "http://docbook.org/ns/docbook"
 xmlns:xlink = "http://www.w3.org/1999/xlink"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
 
 <xsl:output method="text"/>
 <xsl:strip-space elements="*"/>
 
 <xsl:key name="rng.element"
  match="rng:define[rng:element[@name] or rng:element[rng:name]]"
  use="@name"/>
 
 <xsl:key name="rng.attribute"
  match="rng:define[rng:attribute[@name] or rng:attribute[rng:name]]"
  use="@name"/>
 
 <xsl:key name="rng.define" match="rng:define" use="@name"/>
 
 <xsl:param name="schemaname">geekodoc5</xsl:param>
 
 <xsl:variable name="xml.ns">http://www.w3.org/XML/1998/namespace</xsl:variable>
 <xsl:variable name="xlink.ns">http://www.w3.org/1999/xlink</xsl:variable>


 <!-- =================================================================== -->
 <xsl:template name="vim.header">
  <xsl:text>let g:xmldata_</xsl:text>
  <xsl:value-of select="$schemaname"/>
  <xsl:text> = {&#10;</xsl:text>
  <xsl:text>\ 'vimxmlentities': [''],&#10;</xsl:text>
 </xsl:template>
 
 <xsl:template name="vim.footer">
  <xsl:text>}&#10;</xsl:text>
  <xsl:text>" vim:ft=vim:ff=unix&#10;</xsl:text>
 </xsl:template>

 
 <!-- =================================================================== -->
 <xsl:template match="/">
  <xsl:call-template name="vim.header"/>
  
  <xsl:apply-templates select=".//rng:start[1]"/>
  <!--<xsl:apply-templates select=".//rng:define[rng:element/@name]">
   <xsl:sort select="rng:element/@name"/>
  </xsl:apply-templates>-->

  <xsl:call-template name="vim.footer"/>
 </xsl:template>
 
 <xsl:template match="rng:start">
  <xsl:variable name="refs.inside.start" select=".//rng:ref"/>
  <xsl:call-template name="start.elements">
   <xsl:with-param name="refnodes" select="$refs.inside.start"/>
  </xsl:call-template>
  <!-- Find all element definitions -->
  <xsl:apply-templates select="//rng:define[rng:element[rng:name]]"><!-- rng:ref -->
   <xsl:sort select="rng:element/rng:name"/><!-- current()/@name -->
  </xsl:apply-templates>
 </xsl:template>
 
 <xsl:template name="start.elements">
  <xsl:param name="refnodes"/>
  <xsl:message>Found <xsl:value-of select="count($refnodes)"/> allowed elements for start.</xsl:message>
  <xsl:variable name="tmp.rootnodes">
   <xsl:for-each select="$refnodes">
    <xsl:sort select="./@name"/>
    <xsl:variable name="rng.element.node" select="key('rng.element', current()/@name)"/>
    <xsl:variable name="ref.name" select="($rng.element.node/rng:element/@name |
                                           $rng.element.node/rng:element/rng:name)[1]"/>
    <xsl:if test="$ref.name != ''">
      <xsl:value-of select='concat("&apos;", $ref.name, "&apos;")'/>
      <xsl:text>, </xsl:text>
    </xsl:if>
   </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="rootnodes">
   <xsl:variable name="root" select="normalize-space($tmp.rootnodes)"/>
   <xsl:variable name="lastchar" select="substring($root,string-length($root),1)"/>
   <xsl:choose>
    <xsl:when test="$lastchar = ','">
     <xsl:value-of select="substring($root, 1, string-length($root)-1)"/>
    </xsl:when>
    <xsl:otherwise><xsl:value-of select="$root"/></xsl:otherwise>
   </xsl:choose>
  </xsl:variable>
  
  <xsl:text>\ 'vimxmlroot': [</xsl:text>
  <xsl:value-of select="$rootnodes"/>
  <xsl:text>],&#10;</xsl:text>
 </xsl:template>

 <xsl:template match="rng:ref">
  <xsl:variable name="rng.element.node" select="key('rng.element', @name)"/>
  <xsl:variable name="rng.element.name" select="($rng.element.node/rng:element/@name
     |$rng.element.node/rng:element/rng:name)[1]"/>
<!--  <xsl:variable name="rng.attribute.node" select="key('rng.attribute', @name)"/>
  <xsl:variable name="rng.attribute.name" select="($rng.element.node/rng:attribute/@name
     |$rng.element.node/rng:attribute/rng:name)[1]"/>
-->  
  <xsl:message> ref: <xsl:value-of select="@name"/>:<xsl:value-of select="$rng.element.name"/></xsl:message>
  
  <xsl:text>'</xsl:text>
  <xsl:value-of select="$rng.element.name"/>
  <xsl:text>'</xsl:text>
  
<!--  <xsl:choose>
   <xsl:when test="$rng.element.node">
    <xsl:value-of select='concat("\ &apos;", $rng.element.name, "&apos;: [&#10;")'/>
    <!-\- TODO: Add here child elements -\->
    
    <xsl:text>\ {</xsl:text>
    <xsl:for-each select="$rng.element.node//rng:attribute">
     <xsl:variable name="attr.ns" select="(current()/rng:name/@ns | current()/@ns)[1]"/>
     <xsl:variable name="attr.name" select="(current()/rng:name | current()/@name)[1]"/>
     <xsl:variable name="attr.name.prefix">
      <xsl:choose>
       <xsl:when test="$attr.ns = $xml.ns">xml:</xsl:when>
       <xsl:when test="$attr.ns = $xlink.ns">xlink:</xsl:when>
       <xsl:otherwise/>
      </xsl:choose>
     </xsl:variable>
     <xsl:message>  attr:<xsl:value-of select="concat($attr.name.prefix, $attr.name)"/></xsl:message>
     <xsl:value-of select='concat("&apos;", $attr.name.prefix, $attr.name, "&apos;: ")'/>
     <xsl:text>[</xsl:text>
     <xsl:if test="current()//rng:value">
      <xsl:for-each select="current()//rng:value">
       <xsl:value-of select='concat("&apos;", ., "&apos;")'/>
       <xsl:if test="position() &lt; last()">, </xsl:if>
      </xsl:for-each>
     </xsl:if>
     <xsl:text>], </xsl:text>
    </xsl:for-each>
    <xsl:text>}&#10;</xsl:text>
    <xsl:text>\ ],&#10;</xsl:text>
   </xsl:when>
   <xsl:when test="$rng.attribute.node">
    <xsl:value-of select="$rng.attribute.name"/>
   </xsl:when>
   <xsl:otherwise>
    <xsl:message>WARN: Can't find appropriate node for <xsl:value-of select="@name"/></xsl:message>
    <xsl:variable name="def" select="key('rng.define', @name)"/>
   </xsl:otherwise>
  </xsl:choose>-->
 </xsl:template>


 <xsl:template match="rng:element">
  <xsl:value-of select='concat("\ ", @name, ": [&#10;")'/>
 </xsl:template>

 <xsl:template match="rng:define[rng:element[rng:name]]">
  <xsl:variable name="rng.element.name" select="(rng:element/@name
                                                 |rng:element/rng:name)[1]"/>
  <xsl:message>Found <xsl:value-of select="$rng.element.name"/></xsl:message>
      
  <xsl:text>\ </xsl:text>
  <xsl:value-of select='concat("&apos;", $rng.element.name, "&apos;")'/>
  <xsl:text>: [&#10;</xsl:text>
  
  <!-- Possible child elements -->
  <!--  \ ['title', 'para'],-->
  <xsl:text>\ [</xsl:text>
  <xsl:for-each select=".//rng:ref">
   <xsl:apply-templates select="."/>
   <xsl:if test="position() &lt; last()">, </xsl:if>
  </xsl:for-each>
  <xsl:text>],&#10;</xsl:text>
  
  <!-- Possible attributes -->
  <xsl:text>\ {</xsl:text>
  <xsl:for-each select=".//rng:attribute">
   <xsl:variable name="attr.ns" select="(rng:name/@ns | @ns)[1]"/>
   <xsl:variable name="attr.name" select="(rng:name | @name)[1]"/>
   <xsl:variable name="attr.name.prefix">
    <xsl:choose>
     <xsl:when test="$attr.ns = $xml.ns">xml:</xsl:when>
     <xsl:when test="$attr.ns = $xlink.ns">xlink:</xsl:when>
     <xsl:otherwise/>
    </xsl:choose>
   </xsl:variable>
   <xsl:message> attr:<xsl:value-of
     select="concat($attr.name.prefix, $attr.name)"/></xsl:message>
   <xsl:value-of
    select='concat("&apos;", $attr.name.prefix, $attr.name, "&apos;: ")'/>
   <xsl:text>[</xsl:text>
   <xsl:if test="current()//rng:value">
    <xsl:for-each select="current()//rng:value">
     <xsl:value-of select='concat("&apos;", ., "&apos;")'/>
     <xsl:if test="position() &lt; last()">, </xsl:if>
    </xsl:for-each>
   </xsl:if>
   <xsl:text>], </xsl:text>
  </xsl:for-each>
    <xsl:text>}&#10;</xsl:text>
  <xsl:text>\ ],&#10;</xsl:text>
 </xsl:template>

 <xsl:template match="rng:attribute">
  
 </xsl:template>

 <xsl:template match="rng:define[rng:element/@name]">
  <xsl:variable name="element.name" select="rng:element/@name"/>
  <xsl:variable name="all.attribs" select=".//rng:attribute"/>
  <xsl:variable name="all.refs" select=".//rng:ref"/>
  <!--
   \ 'abstract': [
   \ ['title', 'para'],
   \ { 'os': [], 'id': [], 'vendor': [], 'xml:base': [], 'arch': [], 'condition': []}
   \ ],  
  --> 
  <xsl:message>define <xsl:value-of select="$element.name"/></xsl:message>
  <xsl:value-of select='concat("\ ", $element.name, ": [&#10;")'/>
  
  <xsl:text>\ [</xsl:text>
  <xsl:for-each select="$all.refs">
   <xsl:apply-templates select="."/>
  </xsl:for-each>
  <xsl:text>],&#10;</xsl:text>
  
  <!--<xsl:text>{ </xsl:text>
  <xsl:for-each select="$all.attribs">
   
  </xsl:for-each>
  <xsl:text>},&#10;</xsl:text>-->
  
  <xsl:text>\ ],&#10;</xsl:text>
 </xsl:template>
 
 <xsl:template match="rng:*">
  <xsl:apply-templates/>
 </xsl:template>
 
 <xsl:template match="a:documentation
                      |s:*
                      |rng:define[@name='suse.schema.version']
                      |rng:value
                      |rng:data/rng:param"/>
</xsl:stylesheet>