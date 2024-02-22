<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:svtx="http://www.savotex.com"
                xmlns:xi="http://www.w3.org/2001/XInclude"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions">

  <xsl:import href="censhare:///service/assets/asset;censhare:resource-key=svtx:xsl.indesign.util/storage/master/file" />

  <!-- parameters -->
  <xsl:param name="transform"/>

  <xsl:template match="asset">
    <xsl:variable name="mainContent" select="(cs:child-rel()[@key='user.main-content.']/cs:asset()[@censhare:asset.type='text.*'])[1]" as="element(asset)?"/>
    <xsl:variable name="currentContentAsset" select="svtx:getCheckedOutAsset($mainContent)" as="element(asset)?"/>
    <xsl:variable name="masterStorage" select="$currentContentAsset/storage_item[@key='master']" as="element(storage_item)?"/>
    <xsl:variable name="contentXml" select="if ($masterStorage) then doc($masterStorage/@url) else ()"/>
    <xsl:variable name="imageUrl" select="$contentXml/article/content/picture[1]/@xlink:href" as="xs:string?"/>
    <xsl:variable name="id" select="svtx:getAssetIdFromCenshareUrl($imageUrl)" as="xs:string?"/>
    <assets>
      <xsl:copy-of select="if ($id castable as xs:long) then cs:get-asset(xs:long($id)) else ()"/>
    </assets>
  </xsl:template>

</xsl:stylesheet>
