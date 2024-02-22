<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions" xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus" xmlns:svtx="http://www.savotex.com" exclude-result-prefixes="#all" version="2.0">
  
  <xsl:template match="/asset">
    <xsl:variable name="textAssets" select="if (starts-with(@type, 'text.')) then . else cs:child-rel()[@key='user.main-content.']" as="element(asset)*"/>
    <xsl:variable name="owner" select="svtx:getAssetOwner(($textAssets, .))" as="element(party)*"/>
    <xsl:value-of select="string-join($owner/@display_name, ', ')"/>
  </xsl:template>

  <xsl:function name="svtx:getAssetOwner" as="element(party)*">
    <xsl:param name="assets" as="element(asset)*"/>
    <xsl:variable name="ownerIds" select="$assets/asset_feature[@feature='censhare:owner']/@value_long" as="xs:long*"/>
    <xsl:for-each select="distinct-values($ownerIds)">
      <xsl:variable name="id" select="." as="xs:long?"/>
      <xsl:variable name="party" select="cs:master-data(&apos;party&apos;)[@id=$id]" as="element(party)?"/>
      <xsl:copy-of select="$party"/>
    </xsl:for-each>
  </xsl:function>


</xsl:stylesheet>
