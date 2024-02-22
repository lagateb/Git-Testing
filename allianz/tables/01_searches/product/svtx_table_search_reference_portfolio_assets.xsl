<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions" xmlns:svtx="http://www.savotex.com">
  <xsl:param name="context-id"/>
  <xsl:param name="filterAssetName" select="&apos;&apos;"/>
  <xsl:param name="assetType" select="&apos;all&apos;"/>
  <xsl:param name="workflowStepID" select="&apos;all&apos;"/>
  <!-- root match -->
  <xsl:template match="/">
    <xsl:variable name="partyID" select="system-property(&apos;censhare:party-id&apos;)"/>
    <query type="asset">
      <condition name="censhare:asset.type" value="product.capital-investment.portfolio."/>
      <xsl:if test="$filterAssetName">
        <condition name="censhare:text.name" op="=" value="{$filterAssetName}"/>
      </xsl:if>
    </query>
  </xsl:template>
</xsl:stylesheet>