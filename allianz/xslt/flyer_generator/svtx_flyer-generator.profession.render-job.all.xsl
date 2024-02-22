<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                                 xmlns:xs="http://www.w3.org/2001/XMLSchema"
                                 xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                                 xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                                 xmlns:svtx="http://www.savotex.com"
                                 exclude-result-prefixes="#all"
                                 version="2.0">

  <!-- ========== Imports ========== -->
  <xsl:import href="censhare:///service/assets/asset;censhare:resource-key=svtx:flyer-generator.util/storage/master/file"/>
  <!-- only in IDE -->
  <xsl:import href="svtx_flyer-generator.util.xsl" use-when="false()"/>

  <!-- root match -->
  <xsl:template match="/">
    <xsl:message>RENDER ALL JOB PROFESSIONS</xsl:message>
    <xsl:variable name="query" as="element(query)">
      <query type="asset">
        <condition name="censhare:asset.type" value="{$PROFESSION_ASSET_TYPE}"/>
        <condition name="censhare:asset.domain" value="{$FLYER_GENERATOR_DOMAIN}"/>
        <condition name="{$PDF_RENDERING_PENDING}" value="1"/>
      </query>
    </xsl:variable>
    <xsl:for-each select="cs:asset($query)">
      <cs:command name="com.censhare.api.transformation.AssetTransformation">
        <cs:param name="key" select="'svtx:flyer-generator.profession.render-job'"/>
        <cs:param name="source" select="."/>
      </cs:command>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>