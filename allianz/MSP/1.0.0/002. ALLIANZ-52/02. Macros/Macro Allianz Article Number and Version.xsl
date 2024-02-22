<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
  xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
  xmlns:csc="http://www.censhare.com/censhare-custom"
  exclude-result-prefixes="xs cs csc">

  <!-- output -->
  <xsl:output indent="yes" method="xml" omit-xml-declaration="no" encoding="UTF-8"/>
  
  <xsl:template match="/">
    <data>
      <xsl:attribute name="value" select="concat(/asset/asset_feature[@feature='msp:alz-mmc.promotion-article-number']/@value_string, '_', /asset/asset_feature[@feature='msp:alz-mmc.promotion-version-number']/@value_string)" />
    </data>
  </xsl:template>

</xsl:stylesheet>