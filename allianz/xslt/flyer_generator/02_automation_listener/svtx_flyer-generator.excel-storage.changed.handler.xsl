<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:svtx="http://www.savotex.com"
                exclude-result-prefixes="#all"
                version="2.0">

  <xsl:template match="/asset[@type = 'product.']">
    <cs:command name="com.censhare.api.transformation.AssetTransformation">
      <cs:param name="key" select="'svtx:flyer-generator.import-jobs'"/>
      <cs:param name="source" select="."/>
    </cs:command>
    <cs:command name="com.censhare.api.transformation.AssetTransformation">
      <cs:param name="key" select="'svtx:flyer-generator.update-risk-group'"/>
      <cs:param name="source" select="."/>
    </cs:command>
  </xsl:template>
</xsl:stylesheet>