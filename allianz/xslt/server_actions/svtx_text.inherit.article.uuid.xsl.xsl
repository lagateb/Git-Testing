<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:svtx="http://www.savotex.com"
                xmlns:xi="http://www.w3.org/2001/XInclude"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions">

  <xsl:variable name="debug" select="false()" as="xs:boolean"/>

  <xsl:template match="asset[starts-with(@type, 'article.')]">
    <xsl:apply-templates select="cs:child-rel()[@key='user.main-content.']"/>
  </xsl:template>

  <xsl:template match="asset[starts-with(@type, 'text.') and not(asset_feature[@feature='svtx:inherit-parent-uuid'])]">
    <xsl:variable name="article" select="(cs:parent-rel()[@key='user.main-content.']/cs:asset()[@censhare:asset.type='article.*'])[1]" as="element(asset)?"/>
    <xsl:variable name="censhareUid" select="$article/asset_feature[@feature='censhare:uuid']/@value_string" as="xs:string?"/>
    <xsl:if test="$censhareUid">
      <xsl:variable name="updateUid" select="concat($censhareUid, '_', @type)" as="xs:string?"/>
      <cs:command name="com.censhare.api.assetmanagement.Update" returning="updatedAssetXml">
        <cs:param name="source">
          <asset>
            <xsl:copy-of select="@* | node()"/>
            <asset_feature feature="svtx:inherit-parent-uuid" value_string="{$updateUid}"/>
          </asset>
        </cs:param>
      </cs:command>
      <xsl:if test="$debug">
        <xsl:copy-of select="$updatedAssetXml"/>
      </xsl:if>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
