<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xi="http://www.w3.org/2001/XInclude"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:svtx="http://www.savotex.com"
                exclude-result-prefixes="#all">

  <!-- output -->
  <xsl:output method="xhtml" indent="yes" encoding="UTF-8" omit-xml-declaration="yes"/>

  <!-- parameter -->
  <xsl:param name="language" select="if (asset/@language) then asset/@language else 'en'"/>
  <xsl:param name="mode" select="()"/>
  <xsl:param name="device" select="'none'"/>
  <xsl:param name="app" select="'none'"/>
  <xsl:param name="scale" select="1.0"/>

  <!-- variables -->
  <xsl:variable name="debug" select="false()" as="xs:boolean"/>
  <xsl:variable name="rootAsset" select="asset[1]" as="element(asset)?"/>
  <xsl:variable name="parentArticle" select="$rootAsset/cs:parent-rel()[@key='user.main-content.']/cs:asset()[@censhare:asset.type='article.*']" as="element(asset)?"/>
  <xsl:variable name="urlPrefix" select="if ($mode = 'browser') then '/ws/rest/service/' else if ($mode='cs5') then '/censhare5/client/rest/service/' else '/service/'" as="xs:string"/>
  <xsl:variable name="contentXml">
    <cs:command name="com.censhare.api.transformation.AssetTransformation">
      <cs:param name="key" select="'svtx:escape.linebreak.special.characters'"/>
      <cs:param name="source" select="$rootAsset"/>
    </cs:command>
  </xsl:variable>

  <xsl:variable name="previewMapping">
    <entry type="article.vorteile." key="svtx:html-preview.allianz-de.vorteile"/>
    <entry type="article.produktbeschreibung." key="svtx:html-preview.allianz-de.produktbeschreibung"/>
    <entry type="article.funktionsgrafik." key="svtx:html-preview.allianz-de.funktionsgrafik-quer"/>
    <entry type="article.nutzenversprechen." key="svtx:html-preview.allianz-de.nutzenversprechen"/>
    <entry type="article.productdetails." key="svtx:html-preview.allianz-de.produktdetails"/>
    <entry type="article.zielgruppenmodul." key="svtx:html-preview.allianz-de.zielgruppen-modul"/>
    <entry type="article.header." key="svtx:html-preview.allianz-de.header"/>
  </xsl:variable>

  <!-- asset match -->
  <xsl:template match="/asset">
    <html>
      <head>
        <title><xsl:value-of select="$rootAsset/@name"/> (Transformation Baustein)</title>
        <xsl:variable name="cssAsset" select="cs:get-resource-asset('svtx:cs5.article-text-preview.css')"/>
        <xsl:if test="$cssAsset">
          <link rel="stylesheet" type="text/css" href="{concat('/censhare5/client/rest/service/assets/asset/id/', $cssAsset/@id, '/version/', $cssAsset/@version, '/storage/master/file/csTextAssetPreview.css')}"/>
        </xsl:if>
        <meta http-equiv="Content-type" content="text/html;charset=UTF-8" />
      </head>
      <body style="{if ($device='none' or $mode='cs5') then '' else 'background-color:#f8f8f8'}">
        <xsl:variable name="resourceAssetKey" select="$previewMapping/entry[@type = $parentArticle/@type]/@key" as="xs:string?"/>
        <xsl:if test="$contentXml and $resourceAssetKey">
          <xsl:copy-of select="svtx:getHtmlPreview($resourceAssetKey, $contentXml/article/content)"/>
        </xsl:if>
      </body>
    </html>
  </xsl:template>

  <!-- -->
  <xsl:function name="svtx:getCheckedOutAsset" as="element(asset)?">
    <xsl:param name="asset" as="element(asset)?"/>
    <xsl:copy-of select="if (exists($asset) and $asset/@checked_out_by) then cs:get-asset($asset/@id, 0, -2) else $asset"/>
  </xsl:function>

  <!-- -->
  <xsl:function name="svtx:getCheckedOutMasterStorage" as="element(storage_item)?">
    <xsl:param name="asset" as="element(asset)?"/>
    <xsl:variable name="checkedOutAsset" select="svtx:getCheckedOutAsset($asset)"/>
    <xsl:copy-of select="$checkedOutAsset/storage_item[@key='master']"/>
  </xsl:function>

  <!-- -->
  <xsl:function name="svtx:getHtmlPreview">
    <xsl:param name="key" as="xs:string"/>
    <xsl:param name="input"/>
    <cs:command name="com.censhare.api.transformation.AssetTransformation">
      <cs:param name="key" select="$key"/>
      <cs:param name="source" select="$input"/>
      <cs:param name="xsl-parameters">
        <cs:param name="format" select="'html'"/>
        <cs:param name="device" select="$device"/>
        <cs:param name="app" select="$app"/>
        <cs:param name="scale" select="$scale"/>
        <cs:param name="mode" select="$mode"/>
      </cs:param>
    </cs:command>
  </xsl:function>
</xsl:stylesheet>
