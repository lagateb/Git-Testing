<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
  xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
  xmlns:csc="http://www.censhare.com/censhare-custom"
  exclude-result-prefixes="xs cs csc">

  <!-- output -->
  <xsl:output indent="yes" method="xhtml" omit-xml-declaration="no" encoding="UTF-8"/>
  
  <xsl:template match="/">
    <data>
      <xsl:variable name="existsMedia" select="count(asset/cs:child-rel()[@key='user.*']/cs:asset-id()[@censhare:asset.type='layout.*' or @censhare:asset.type='picture.*']) &gt; 0"/>
      <xsl:if test="asset/@type='promotion.'">
        <xsl:attribute name="value" select="if ($existsMedia) then 'Ja' else 'Nein'" />
        <xsl:attribute name="color" select="if ($existsMedia) then '#00CC00' else '#CC0000'" />
      </xsl:if>
    </data>
  </xsl:template>

</xsl:stylesheet>
