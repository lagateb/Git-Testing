<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:svtx="http://www.savotex.com"
                xmlns:xi="http://www.w3.org/2001/XInclude"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions">

  <xsl:import href="censhare:///service/assets/asset;censhare:resource-key=svtx:xsl.indesign.util/storage/master/file" />

  <!-- parameters -->
  <xsl:param name="transform"/>

  <xsl:template match="/asset">
    <xsl:variable name="mainContentAsset" as="element(asset)?">
      <xsl:call-template name="svtx:getMainContentAsset">
        <xsl:with-param name="asset" select="."/>
        <xsl:with-param name="size" select="'s'"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="currentContentAsset" select="svtx:getCheckedOutAsset($mainContentAsset)" as="element(asset)?"/>
    <xsl:variable name="masterStorage" select="$currentContentAsset/storage_item[@key='master']" as="element(storage_item)?"/>
    <xsl:variable name="contentXml" select="if ($masterStorage) then doc($masterStorage/@url) else ()"/>
    <xsl:variable name="contentUrl" select="$contentXml/article/content/calltoaction-link[1]/@url" as="xs:string?"/>
    <xsl:variable name="url" select="if ($contentUrl) then $contentUrl else ''" as="xs:string?"/>
    <xsl:variable name="hashedUrl" select="cs:hash($url)" as="xs:string"/>
    <xsl:variable name="existingQrCode" select="(cs:asset()[@censhare:asset.id_extern = $hashedUrl and @censhare:asset.type = 'picture.'])[1]" as="element(asset)?"/>
    <assets>
      <xsl:choose>
        <xsl:when test="exists($existingQrCode)">
          <xsl:copy-of select="$existingQrCode"/>
        </xsl:when>
        <xsl:when test="$url eq ''">
          <xsl:copy-of select="()"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="out"/>
          <cs:command name="com.censhare.api.io.CreateVirtualFileSystem" returning="out"/>
          <xsl:variable name="resultFile" select="concat($out, @id, '.png')"/>
          <cs:command name="com.censhare.api.transformation.BarcodeTransformation">
            <cs:param name="source" select="$url"/>
            <cs:param name="dest" select="$resultFile"/>
            <cs:param name="barcode-transformation">
              <barcode-transformation type="qr" file-format="png"
                                      height="20" module-width="50" margin="0"
                                      orientation="0" font="Courier" font-size="10"
                                      dpi="72" antialias="true"/>
            </cs:param>
          </cs:command>
          <!-- new asset -->
          <cs:command name="com.censhare.api.assetmanagement.CheckInNew">
            <cs:param name="source">
              <asset name="QR Code - Fallbeispiel - {$url}" type="picture.">
                <asset_element key="actual." idx="0"/>
                <asset_feature feature="censhare:asset.id_extern" value_string="{$hashedUrl}"/>
                <storage_item corpus:asset-temp-file-url="{$resultFile}" element_idx="0" key="master" mimetype="image/png"/>
              </asset>
            </cs:param>
          </cs:command>
          <cs:command name="com.censhare.api.assetmanagement.CommitOrFlush">
            <cs:param name="flush" select="true()"/>
          </cs:command>
        </xsl:otherwise>
      </xsl:choose>
    </assets>
  </xsl:template>
</xsl:stylesheet>
