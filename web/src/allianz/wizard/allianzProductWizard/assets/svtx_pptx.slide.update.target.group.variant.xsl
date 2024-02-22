<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:svtx="http://www.savotex.com" xmlns:sxl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all"
                version="2.0">
  <xsl:variable name="debug" select="true()" as="xs:boolean"/>
  <xsl:variable name="rootAsset" select="asset[1]" as="element(asset)?"/>
  <xsl:variable name="targetGroupAssetId" select="$rootAsset/asset_feature[@feature='censhare:target-group']/@value_asset_id" as="xs:long?"/>

  <!-- either called on presentation.issue. or related presentation.slide. assets -->
  <xsl:template match="/">
    <xsl:if test="$targetGroupAssetId">
      <xsl:apply-templates/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="asset[@type = 'presentation.issue.']">
    <xsl:apply-templates select="cs:child-rel()[@key='target.']"/>
  </xsl:template>

  <xsl:template match="asset[@type = 'presentation.slide.']">
    <xsl:variable name="slide" select="." as="element(asset)?"/>
    <xsl:variable name="article" select="(cs:child-rel()[@key='target.']/cs:asset()[@censhare:asset.type='article.*'])[1]" as="element(asset)?"/>
    <xsl:if test="exists($article)">
      <xsl:variable name="isVariant" select="exists($article/parent_asset_rel[@key='variant.'])" as="xs:boolean"/>
      <xsl:variable name="hasVariant" select="exists($article/child_asset_rel[@key='variant.'])" as="xs:boolean"/>
      <xsl:if test="$isVariant=false() and $hasVariant=true()">
        <xsl:variable name="variantWithTargetGroup" select="($article/cs:child-rel()[@key='variant.']/cs:asset()[@censhare:asset.type='article.*' and @censhare:target-group=$targetGroupAssetId])[1]" as="element(asset)?"/>
        <xsl:if test="exists($variantWithTargetGroup)">
          <!-- update structure -->
          <xsl:copy-of select="$variantWithTargetGroup"/>
          <xsl:variable name="checkedOutSlideAsset" as="element(asset)?">
            <cs:command name="com.censhare.api.assetmanagement.CheckOut">
              <cs:param name="source">
                <xsl:copy-of select="$slide"/>
              </cs:param>
            </cs:command>
          </xsl:variable>
          <cs:command name="com.censhare.api.assetmanagement.CheckIn">
            <cs:param name="source">
              <asset>
                <xsl:copy-of select="$checkedOutSlideAsset/@*"/>
                <xsl:copy-of select="$checkedOutSlideAsset/node() except $checkedOutSlideAsset/child_asset_rel[@key='target.' and @child_asset=$article/@id]"/>
                <child_asset_rel child_asset="{$variantWithTargetGroup/@id}" key="target."/>
              </asset>
            </cs:param>
          </cs:command>
          <!-- send asset event to replace -->
          <xsl:variable name="mainContentId" select="($variantWithTargetGroup/child_asset_rel[@key='user.main-content.']/@child_asset)[1]" as="xs:long?"/>
          <xsl:if test="$mainContentId">
            <cs:command name="com.censhare.api.event.Send">
              <cs:param name="source">
                <event target="CustomAssetEvent" param2="0" param1="1" param0="{$mainContentId}" method="svtx-update-pptx-slide"/>
              </cs:param>
            </cs:command>
          </xsl:if>
        </xsl:if>
      </xsl:if>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>