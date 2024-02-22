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
  <xsl:param name="target-asset-id"/>
  
  <xsl:template match="asset">

    <xsl:variable name="mainContentAsset" as="element(asset)?">
      <cs:command name="com.censhare.api.transformation.AssetTransformation" returning="result">
        <cs:param name="key" select="'svtx:indesign.dynamic.search.main-content'"/>
        <cs:param name="source" select="."/>
        <cs:param name="xsl-parameters">
          <cs:param name="target-asset-id" select="$target-asset-id"/>
        </cs:param>
      </cs:command>
      <xsl:copy-of select="$result/assets/asset[1]"/>
    </xsl:variable>
      <!--
       <xsl:variable name="mainContentAsset" as="element(asset)?">
           <xsl:call-template name="svtx:getMainContentAsset">
               <xsl:with-param name="asset" select="."/>
               <xsl:with-param name="size" select="'s'"/>
           </xsl:call-template>
       </xsl:variable>
    -->
      <xsl:variable name="currentContentAsset" select="svtx:getCheckedOutAsset($mainContentAsset)" as="element(asset)?"/>
    <xsl:variable name="masterStorage" select="$currentContentAsset/storage_item[@key='master']" as="element(storage_item)?"/>
    <xsl:variable name="contentXml" select="if ($masterStorage) then doc($masterStorage/@url) else ()"/>
    <xsl:variable name="imageUrl" select="$contentXml/article/content/seals/seal[1]/logo[1]/@xlink:href" as="xs:string?"/>
    <xsl:variable name="id" select="svtx:getAssetIdFromCenshareUrl($imageUrl)" as="xs:string?"/>
    <assets>
      <xsl:copy-of select="if ($id castable as xs:long) then cs:get-asset(xs:long($id)) else ()"/>
    </assets>
  </xsl:template>

</xsl:stylesheet>
