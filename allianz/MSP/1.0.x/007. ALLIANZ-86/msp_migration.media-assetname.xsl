<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:msp="http://www.mspag.com"
                xmlns:corpus="http://www.censhare.com" version="2.0"
                exclude-result-prefixes="cs msp corpus">

  <xsl:variable name="debug" select="false()" as="xs:boolean"/>

  <xsl:variable name="query" as="element(query)">
    <query type="asset" limit="1000">
      <not>
        <condition name="censhare:asset.name" op="LIKE" value="*.*"/>
      </not>
      <condition name="msp:alz.media.filename" op="NOTNULL"/>
      <condition name="msp:alz.media.mmc-id" op="NOTNULL"/>
    </query>
  </xsl:variable>

  <xsl:template match="/">
    <xsl:for-each select="cs:asset($query)">
      <xsl:variable name="current" select="current()" as="element(asset)"/>
      <xsl:variable name="updateAsset" as="element(asset)">
        <asset>
          <xsl:copy-of select="$current/@*"/>
          <xsl:attribute name="name" select="$current/asset_feature[@feature = 'msp:alz.media.filename']/@value_string"/>
          <xsl:copy-of select="$current/*"/>
        </asset>
      </xsl:variable>
      <xsl:copy-of select="if ($debug) then $updateAsset else msp:updateAsset($updateAsset)"/>
    </xsl:for-each>
  </xsl:template>

  <xsl:function name="msp:updateAsset">
    <xsl:param name="asset" as="element(asset)"/>
    <cs:command name="com.censhare.api.assetmanagement.Update" returning="result">
      <cs:param name="source" select="$asset"/>
    </cs:command>
    <xsl:copy-of select="$result" />
  </xsl:function>

</xsl:stylesheet>
