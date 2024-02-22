<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                exclude-result-prefixes="#all"
                version="2.0">

  <!-- parameters -->
  <xsl:param name="target-asset-id"/>
  <!-- Defines a search for the main content assets -->
  <xsl:template match="asset">
    <xsl:variable name="targetAssetId" select="if ($target-asset-id) then xs:integer($target-asset-id) else ()"/>
    <xsl:variable name="mainContent" select="cs:child-rel()[@key='user.main-content.']/cs:asset()[@censhare:asset.type='text.*']" as="element(asset)*"/>
    <assets>
      <xsl:choose>
        <xsl:when test="count($mainContent) eq 1">
          <xsl:copy-of select="$mainContent"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="type" select="@type" as="xs:string?"/>
          <xsl:variable name="targetLayout" select="cs:get-asset($targetAssetId)" as="element(asset)?"/>
          <xsl:variable name="templateLayoutId" select="$targetLayout/asset_feature[@feature='svtx:layout-template'][1]/@value_asset_id" as="xs:long?"/>
          <xsl:variable name="templateLayoutKey" select="$targetLayout/asset_feature[@feature='svtx:layout-template-resource-key']/@value_asset_key_ref" as="xs:string?"/>
          <xsl:variable name="templateLayout" select="if ($templateLayoutKey) then cs:get-resource-asset($templateLayoutKey) else cs:get-asset($templateLayoutId)" as="element(asset)?"/>
          <xsl:variable name="channelTemplate" select="($templateLayout/cs:parent-rel()[@key='user.layout.']/cs:asset()[@censhare:asset.type='channel.'])[1]" as="element(asset)?"/>
          <xsl:variable name="articleTemplate" select="($channelTemplate/cs:child-rel()[@key='target.']/cs:asset()[@censhare:asset.type=$type])[1]" as="element(asset)?"/>
          <xsl:variable name="rel" select="$channelTemplate/child_asset_rel[@key='target.' and @child_asset=$articleTemplate/@id][1]" as="element(child_asset_rel)?"/>
          <xsl:variable name="textKey" select="$rel/asset_rel_feature[@feature='svtx:text-size']/@value_key" as="xs:string?"/>
          <xsl:variable name="predefinedType" select="if ($textKey eq 'size-s') then 'text.size-s.'
                                   else if ($textKey eq 'size-m') then 'text.size-m.'
                                   else if ($textKey eq 'size-l') then 'text.size-l.'
                                   else if ($textKey eq 'size-xl') then 'text.size-xl.'
                                   else ('text.')"/>
          <xsl:copy-of select="$mainContent[@type=$predefinedType][1]"/>
        </xsl:otherwise>
      </xsl:choose>
    </assets>

  </xsl:template>
</xsl:stylesheet>
