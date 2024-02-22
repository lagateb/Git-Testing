<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:svtx="http://www.savotex.com"
                exclude-result-prefixes="#all"
                version="2.0">
                
  <xsl:import href="censhare:///service/assets/asset;censhare:resource-key=svtx:xsl.indesign.util/storage/master/file" />

  <xsl:template match="/asset">
  	<xsl:variable name="checkedOutAsset" select="svtx:getCheckedOutAsset(.)" as="element(asset)?"/>
    <xsl:variable name="masterStorage" select="$checkedOutAsset/storage_item[@key='master']" as="element(storage_item)?"/>
    <xsl:if test="$masterStorage">
      <xsl:variable name="xmlContent" select="doc($masterStorage/@url)"/>
      <xsl:apply-templates select="$xmlContent"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="text()">
    <xsl:value-of select="svtx:cleanAllSpecialBreaks(.)"/>
  </xsl:template>
  
</xsl:stylesheet>
