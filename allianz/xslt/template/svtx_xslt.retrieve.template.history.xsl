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
    <!-- retrieving the media asset -->
    <xsl:variable name="mediaAssetId">
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

    <xsl:variable name="mediaAsset" select="cs:get-asset($mediaAssetId)"/>


    <!-- /asset_feature[@feature='censhare:resource-key']/@value_string" -->

    <xsl:copy-of select="svtx:get-change-history($mediaAsset)"/>

  </xsl:template>

</xsl:stylesheet>
