<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:svtx="http://www.savotex.com"
                exclude-result-prefixes="cs censhare svtx xs">

  <xsl:include href="censhare:///service/assets/asset;censhare:resource-key=svtx:xslt.lib.template.history/storage/master/file"/>

  <xsl:param name="asset-id"/>
  <xsl:param name="context-id"/>

  <!-- asset match -->
  <xsl:template match="/" priority="10">
    <xsl:variable name="productAssetId">
      <xsl:choose>
        <xsl:when test="$asset-id">
          <xsl:value-of select="$asset-id"/>
        </xsl:when>
        <xsl:when test="$context-id">
          <xsl:value-of select="$context-id"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="asset/@id"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- get layout/presentation media of product-asset -->
    <xsl:variable name="childMediaQuery">
      <query>
        <or>
          <condition name="censhare:asset.type" value="layout.*"/>
          <condition name="censhare:asset.type" value="presentation.*"/>
        </or>
        <and>
          <relation direction="parent">
            <target>
              <and>
                <condition name="censhare:asset.id" op="=" value="{$productAssetId}"/>
              </and>
            </target>
          </relation>
        </and>
        <sortorders>
          <grouping mode="none"/>
          <order ascending="true" by="censhare:asset.name"/>
        </sortorders>
      </query>
    </xsl:variable>

    <xsl:variable name="directChildMediaAssets" select="cs:asset($childMediaQuery)"/>

    <result>
      <xsl:for-each select="$directChildMediaAssets">
        <xsl:copy-of select="svtx:get-template-state-of-asset(.)"/>
      </xsl:for-each>
    </result>

  </xsl:template>

</xsl:stylesheet>
