<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:svtx="http://www.savotex.com"
                exclude-result-prefixes="#all"
                version="2.0">

  <!-- resource key from root layout template -->
  <xsl:param name="template-key" select="'svtx:indd.template.flyer.allianz'"/>

  <!-- mapping for asset types to layout groups -->
  <xsl:variable name="placementMapping" as="element(entry)*">

    <entry type="article.funktionsgrafik." group="Funktionsgrafik"/>
    <entry type="article.staerken." group="Stärken"/>
    <xsl:choose>
      <xsl:when test="$template-key = ('svtx:indd.template.flyer.allianz')">
        <entry type="article.nutzenversprechen." group="Nutzenversprechen"/>
        <entry type="article.fallbeispiel." group="Fallbeispiel"/>
        <entry type="article.produktbeschreibung." group="Produktbeschreibung"/>
        <entry type="article.vorteile." group="Vorteile"/>
        <entry type="article.header." group="Header"/>
      </xsl:when>
      <xsl:when test="$template-key = ('svtx:indd.template.bedarf_und_beratung.flyer.allianz')">
        <entry type="article.requirement-field-title." group="Header"/>
        <entry type="article.solution-overview." group="Lösungsübersicht"/>
        <entry type="article.what-is." group="WasIst"/>
        <entry type="article.reasons." group="Gründe"/>
        <entry type="article.key-facts." group="Keyfacts"/>
        <entry type="article.flexi-module." group="flyerSnippet"/>
      </xsl:when>
      <xsl:when test="$template-key = 'svtx:indd.template.twopager.allianz'">
        <entry type="article.produktbeschreibung." group="Produktbeschreibung"/>
        <entry type="article.zielgruppenmodul." group="Zielgruppenmodul"/>
        <entry type="article.productdetails." group="Produktdetails"/>
        <entry type="article.flexi-module." group="twoPagerSnippet"/>
        <entry type="article.vorteile." group="Vorteile"/>
        <entry type="article.header." group="Header"/>
      </xsl:when>
    </xsl:choose>
  </xsl:variable>

  <!-- match the article to place -->
  <xsl:template match="/asset[starts-with(@type, 'article.')]">
    <xsl:variable name="placeAsset" select="." as="element(asset)?"/>
    <xsl:variable name="placeGroup" select="$placementMapping[@type = $placeAsset/@type]/@group" as="xs:string?"/>
    <xsl:if test="$placeGroup">
      <command document_ref_id="1" method="place-collection" group_name="{ $placeGroup }" place_asset_id="{ $placeAsset/@id }"/>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>