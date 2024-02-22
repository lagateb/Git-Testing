<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:svtx="http://www.savotex.com">
  
  <!-- search for child goal assets of asset with given context-id sorted by name -->
  
  <!-- parameters -->
  <xsl:param name="context-id"/>
  
  <!-- root match -->
  <xsl:template match="asset">
    <xsl:variable name="assetIds" as="xs:string*">
      <xsl:for-each select="cs:child-rel()/cs:asset()[@censhare:asset.type='article.*']">
        <xsl:if test="svtx:getCompletionPercentage(.) eq 100.0">
          <xsl:value-of select="@id"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <query>
      <condition name="censhare:asset.id" op="IN" value="{string-join($assetIds, ',')}" sepchar=","/>
      <sortorders>
        <grouping mode="none"/>
        <order ascending="true" by="censhare:asset.name"/>
      </sortorders>
    </query>
  </xsl:template>
  
  <xsl:function name="svtx:getCompletionPercentage" as="xs:double">
    <xsl:param name="rootAsset" as="element(asset)"/>
    <xsl:choose>
      <!-- if no wf step/id entry -->
      <xsl:when test="not($rootAsset/(@wf_step, @wf_id))">
        <xsl:value-of select="0.0"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="wfStep" select="cs:master-data('workflow_step')[@wf_id=$rootAsset/@wf_id and @wf_step=$rootAsset/@wf_step][1]"/>
        <xsl:value-of select="$wfStep/@completion_percentage"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

</xsl:stylesheet>
