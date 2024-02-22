<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions" xmlns:msp="http://www.mspag.com/xpath-functions">

  <xsl:variable name="serverName" select="system-property('censhare:server-name')"/>

  <xsl:variable name="serverBaseURL">
    <xsl:choose>
      <xsl:when test="contains($serverName, 'dev-contenthub')">
        <xsl:value-of select="'https://dev.hub.contentoo.media/censhare5/client/asset/'"/>
      </xsl:when>
      <xsl:when test="contains($serverName, 'qs')">
        <xsl:value-of select="'https://qs.hub.contentoo.media/censhare5/client/asset/'"/><!-- TODO: unchecked -->
      </xsl:when>
      <xsl:when test="contains($serverName, 'master')"><!-- TODO: unchecked -->
        <xsl:value-of select="'https://hub.contentoo.media/censhare5/client/asset/'"/>
      </xsl:when>
    </xsl:choose>
  </xsl:variable>

  <xsl:template match="/">
    <xsl:variable name="asset" select="asset"/>
    <xsl:message>### create report file for imported asset <xsl:value-of select="$asset/@id"/></xsl:message>
    <xsl:variable name="out_xml">
      <censhare_asset>
        <promotion>
          <text>
            <AssetID name="AssetID"><xsl:value-of select="$asset/@id"/></AssetID>
            <AssetDeeplink name="AssetDeeplink"><xsl:value-of select="$serverBaseURL"/><xsl:value-of select="$asset/@id"/></AssetDeeplink>
            <MaterialID name="MaterialID"><xsl:value-of select="$asset/asset_feature[@feature='msp:alz-mmc.promotion-id']/@value_string"/></MaterialID>
            <MaterialNumber name="MaterialNumber"><xsl:value-of select="$asset/asset_feature[@feature='msp:alz-mmc.promotion-number']/@value_string"/></MaterialNumber>
            <MaterialName name="MaterialName"><xsl:value-of select="$asset/asset_feature[@feature='msp:alz-mmc.promotion-name']/@value_string"/></MaterialName>
          </text>
        </promotion>
      </censhare_asset>
    </xsl:variable>

    <xsl:variable name="filename" select="concat('cs_deeplink_', $asset/@id, '_', format-dateTime(current-dateTime(), '[Y]-[M01]-[D01]_[H01]-[m01]-[s01]'), '.xml')"/>

    <cs:command name="com.censhare.api.io.CreateVirtualFileSystem" returning="out_vfs"/>

    <xsl:variable name="filepath" select="concat($out_vfs, $filename)"/>

    <cs:command name="com.censhare.api.io.WriteXML">
      <cs:param name="source" select="$out_xml"/>
      <cs:param name="dest" select="$filepath"/>
      <cs:param name="output">
        <output indent="yes"/>
      </cs:param>
    </cs:command>

    <cs:command name="com.censhare.api.io.CloseVirtualFileSystem" returning="end">
      <cs:param name="id" select="$out_vfs"/>
    </cs:command>

    <cs:command name="com.censhare.api.context.SetProperty">
      <cs:param name="name" select="'censhare:result-file-locator'"/>
      <cs:param name="value" select="$filepath"/>
    </cs:command>

  </xsl:template>

</xsl:stylesheet>
