<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="cs censhare xs">

  <xsl:template match="/asset[@type='article.funktionsgrafik.']">
    <xsl:variable name="query">
      <query limit="1" type="asset">
        <condition name="censhare:asset-flag" value="is-template"/>
        <condition name="censhare:asset.type" value="article.funktionsgrafik."/>
        <condition name="censhare:template-hierarchy" value="root.content-building-block."/>
      </query>
    </xsl:variable>
    <xsl:variable name="template" select="cs:asset($query)" as="element(asset)?"/>
    <xsl:variable name="textL" select="($template/cs:child-rel()[@key='user.main-content.']/cs:asset()[@censhare:asset.type='text.size-l.'])[1]" as="element(asset)?"/>
    <xsl:variable name="product" select="(cs:parent-rel()[@key='user.']/cs:asset()[@censhare:asset.type='product.*'])[1]" as="element(asset)?"/>
    <xsl:if test="exists($textL)">
      <xsl:variable name="clonedXml"/>
      <cs:command name="com.censhare.api.assetmanagement.CloneAndCleanAssetXml" returning="clonedXml">
        <cs:param name="source" select="$textL"/>
      </cs:command>
      <xsl:variable name="newAssetXml">
        <asset name="{$product/@name} - {$textL/@name}" wf_id="10" wf_step="10">
          <xsl:copy-of select="$clonedXml/@* except $clonedXml/(@name, @wf_step, @wf_id)"/>
          <xsl:copy-of select="$clonedXml/node()"/>
          <parent_asset_rel key="user.main-content." parent_asset="{@id}"/>
        </asset>
      </xsl:variable>
      <cs:command name="com.censhare.api.assetmanagement.CheckInNew">
        <cs:param name="source" select="$newAssetXml"/>
      </cs:command>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
