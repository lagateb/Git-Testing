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
      <condition name="censhare:asset.type" value="article.*"/>
      <condition name="censhare:asset-flag" value="is-template"/>
      <condition name="censhare:template-hierarchy" value="root.content-building-block.recurring-modules.*"/>
      <xsl:if test="$filterAssetName">
        <condition name="censhare:text.name" op="=" value="{$filterAssetName}"/>
      </xsl:if>
      <xsl:if test="$assetType !=  &apos;all&apos;">
        <condition name="censhare:asset.type" op="=" value="{$assetType}"/>
      </xsl:if>
      <xsl:if test="not($workflowStepID=&apos;all&apos;)">
        <condition name="censhare:asset.wf_step" op="=" value="{$workflowStepID}"/>
      </xsl:if>
      <sortorders>
        <order ascending="true" by="(CASE WHEN (t0.type=&apos;article.header.&apos;) THEN 100 WHEN (t0.type=&apos;article.produktbeschreibung.&apos;) THEN 200 WHEN (t0.type=&apos;article.funktionsgrafik.&apos;) THEN 220 WHEN (t0.type=&apos;article.vorteile.&apos;) THEN 300 WHEN (t0.type=&apos;article.fallbeispiel.&apos;) THEN 400 WHEN (t0.type=&apos;article.nutzenversprechen.&apos;) THEN 500 WHEN (t0.type=&apos;article.zielgruppenmodul.&apos;) THEN 510 WHEN (t0.type=&apos;article.productdetails.&apos;) THEN 530 WHEN (t0.type=&apos;article.staerken.&apos;) THEN 560 WHEN (t0.type=&apos;article.flexi-module.&apos;) THEN 570 WHEN (t0.type=&apos;article.optional-module.&apos;) THEN 620 WHEN (t0.type=&apos;article.free-module.&apos;) THEN 630 WHEN (t0.type=&apos;layout.&apos;) THEN 700 WHEN (t0.type=&apos;presentation.issue.&apos;) THEN 800 ELSE 999 END)"/>
        <order by="censhare:asset.name"/>
      </sortorders>
    </query>
  </xsl:template>
</xsl:stylesheet>