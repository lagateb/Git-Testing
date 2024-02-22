<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:svtx="http://www.savotex.com"
                exclude-result-prefixes="#all"
                version="2.0">

  <xsl:param name="snippetId" select="39146"/>
  <xsl:param name="placeAssetId" select="40657"/>
  <xsl:param name="xOffset" select="-3"/>
  <xsl:param name="yOffset" select="114"/>

  <xsl:param name="moveTargetGroup" select="'Stärken'"/>
  <xsl:param name="moveTargetGroupDummy" select="'StärkenDummy'"/>
  <xsl:param name="moveX" select="0.0"/>
  <xsl:param name="moveY" select="63.099"/>


  <xsl:template match="/asset[@type = 'layout.']">

    <xsl:variable name="existsConfigAssetWithCD21" select="./asset_element/xmldata/group[contains(@configuration-asset, 'cd21')]/@configuration-asset"/>
    <xsl:variable name="moveY" select="if ($existsConfigAssetWithCD21) then 58.95 else 63.099"/>
    <xsl:variable name="yOffset" select="if ($existsConfigAssetWithCD21) then 110 else 114"/>

    <xsl:for-each select="svtx:getAssetElements(., $moveTargetGroup)">
      <xsl:variable name="box" select="xmldata/box"/>
      <xsl:variable name="x" select="$box/@page_x + svtx:mm2pt($moveX)"/>
      <xsl:variable name="y" select="$box/@page_y + svtx:mm2pt($moveY)"/>
      <xsl:if test="not($box/@uid = 'b1361' or $box/@uid = 'b1823')">
        <command document_ref_id="1" method="move-box" uid="{$box/@uid}" parent_uid="{$box/@page}" width="{$box/@width}" height="{$box/@height}" xoffset="{$x}" yoffset="{$y}"/>
      </xsl:if>
    </xsl:for-each>

    <xsl:for-each select="svtx:getAssetElements(., $moveTargetGroupDummy)">
      <xsl:variable name="box" select="xmldata/box"/>
      <xsl:variable name="x" select="$box/@page_x + svtx:mm2pt($moveX)"/>
      <xsl:variable name="y" select="$box/@page_y + svtx:mm2pt($moveY)"/>
      <xsl:if test="not($box/@uid = 'b1361' or $box/@uid = 'b1823')">
        <command document_ref_id="1" method="move-box" uid="{$box/@uid}" parent_uid="{$box/@page}" width="{$box/@width}" height="{$box/@height}" xoffset="{$x}" yoffset="{$y}"/>
      </xsl:if>
    </xsl:for-each>

    <command document_ref_id="1" method="place-snippet" parent_uid="p1" snippet_asset_element_id="0" snippet_asset_id="{ $snippetId }" place_asset_id="{ $placeAssetId }" xoffset="{ svtx:mm2pt($xOffset) }" yoffset="{  svtx:mm2pt($yOffset) }"/>
  </xsl:template>

  <!-- -->
  <xsl:function name="svtx:getAssetElements" as="element(asset_element)*">
    <xsl:param name="layout" as="element(asset)?"/>
    <xsl:param name="group" as="xs:string?"/>
    <xsl:copy-of select="$layout/asset_element[xmldata/group[lower-case(@group-name) eq lower-case($group)]]"/>
  </xsl:function>

  <!-- -->
  <xsl:function name="svtx:mm2pt" as="xs:double">
    <xsl:param name="mm" as="xs:double"/>
    <xsl:sequence select="$mm div 0.3527777778"/>
  </xsl:function>

  <!-- -->
  <xsl:function name="svtx:pt2mm" as="xs:double">
    <xsl:param name="pt" as="xs:double"/>
    <xsl:sequence select="$pt * 0.3527777778"/>
  </xsl:function>
</xsl:stylesheet>
