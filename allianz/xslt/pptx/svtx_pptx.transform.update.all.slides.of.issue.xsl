<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:svtx="http://www.savotex.com" xmlns:sxl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all"
                version="2.0">

  <xsl:import href="censhare:///service/assets/asset;censhare:resource-key=svtx:update.slide.from.template/storage/master/file" />
  <xsl:include href="censhare:///service/assets/asset;censhare:resource-key=svtx:xslt.lib.template.history/storage/master/file"/>

  <xsl:variable name="inputAsset" select="asset[1]" as="element(asset)?"/>

  <xsl:template match="/asset[@type = 'presentation.issue.']">
    <xsl:message>==== svtx:pptx.transform.update.all.slides.of.issue</xsl:message>
    <xsl:variable name="rootAsset" select="." as="element(asset)?"/>
    <xsl:variable name="slides" select="svtx:get-template-state-of-asset($rootAsset)"/>

    <!-- todo nur zu aktualisierende slides, weil es echt zu lange dauert.... -->
    <xsl:for-each select="$slides/media">
      <xsl:variable name="slideInfo" select="."/>

      <xsl:if test="$slideInfo/@state  ne 'ok'">
        <xsl:variable name="slide" select="cs:get-asset($slideInfo/@id)"/>
        <xsl:message>Update slide <xsl:value-of select="$slide/@id"/></xsl:message>
        <xsl:apply-templates select="$slide"/>
      </xsl:if>
    </xsl:for-each>

  </xsl:template>

</xsl:stylesheet>
