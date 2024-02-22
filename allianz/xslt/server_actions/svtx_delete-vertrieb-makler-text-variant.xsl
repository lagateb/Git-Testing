<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:svtx="http://www.savotex.com"
                exclude-result-prefixes="#all"
                version="2.0">

  <xsl:variable name="rootAsset" select="asset[1]" as="element(asset)?"/>

  <xsl:template match="/asset[starts-with(@type, 'text.')]">
    <xsl:variable name="variantRelation" select="parent_asset_rel[@key='variant.1.'][asset_rel_feature[@feature='svtx:text-variant-type']]" as="element(parent_asset_rel)?"/>
    <xsl:if test="$variantRelation">
      <xsl:variable name="parentAsset" select="cs:get-asset($variantRelation/@parent_asset)[1]" as="element(asset)?"/>
      <xsl:if test="starts-with($parentAsset/@type, 'text.')">
        <xsl:copy-of select="$parentAsset"/>
        <!-- delete variant -->
        <cs:command name="com.censhare.api.assetmanagement.Delete">
          <cs:param name="source" select="$rootAsset/@id"/>
          <cs:param name="state" select="'physical'"/>
        </cs:command>
        <!-- event pptx on parent-->
        <cs:command name="com.censhare.api.event.Send">
          <cs:param name="source">
            <event target="CustomAssetEvent" param2="0" param1="1" param0="{$parentAsset/@id}" method="svtx-update-pptx-slide"/>
          </cs:param>
        </cs:command>
      </xsl:if>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>