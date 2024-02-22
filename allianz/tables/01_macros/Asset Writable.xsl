<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:svtx="http://www.savotex.com"
                exclude-result-prefixes="#all"
                version="2.0">

  <!-- -->
  <xsl:template match="asset[starts-with(@type, 'article.')]">
    <xsl:choose>
      <xsl:when test="exists(asset_feature[@feature='svtx:recurring-module-of'])">
        <xsl:value-of select="'&lt;i class=&quot;cs-icon cs-icon-circle-ok cs-iconsize-400 cs-color-30&quot;&gt;&lt;/i&gt;'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'&lt;i class=&quot;cs-icon cs-icon-circle-remove cs-iconsize-400 cs-color-38&quot;&gt;&lt;/i&gt;'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- -->
  <xsl:template match="asset[starts-with(@type, 'text.')]">
    <xsl:apply-templates select="cs:parent-rel()[@key='user.main-content.']"/>
  </xsl:template>

  <!-- -->
  <xsl:template match="asset"/>

</xsl:stylesheet>
