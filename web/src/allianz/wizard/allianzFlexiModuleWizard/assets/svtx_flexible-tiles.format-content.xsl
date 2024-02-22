<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:svtx="http://www.savotex.com" exclude-result-prefixes="#all" version="2.0">

  <xsl:param name="tile-count" select="2"/> <!-- 2,3,4-->
  <xsl:param name="image-insert" select="'none'"/> <!-- image, icon, none -->
  <xsl:param name="use-link" select="false()"/> <!-- true, false-->
  <xsl:param name="use-picture" select="false()"/>
  <xsl:param name="use-body" select="true()"/>

  <xsl:output indent="no"/>
  <xsl:strip-space elements="*"/>

  <xsl:template match="/asset">
    <xsl:variable name="si" select="storage_item[@key='master']" as="element(storage_item)"/>
    <xsl:choose>
      <xsl:when test="$si">
        <xsl:apply-templates select="doc($si/@url)" mode="custom"/>
      </xsl:when>
      <xsl:otherwise>
        <article><content/></article>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="node()|@*" mode="custom">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*" mode="custom"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="body" mode="custom">
    <xsl:if test="$use-body">
      <xsl:copy>
        <xsl:apply-templates select="node()|@*" mode="custom"/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>

  <xsl:template match="calltoaction-link" mode="custom">
    <xsl:if test="$use-link">
      <xsl:copy>
        <xsl:apply-templates select="node()|@*" mode="custom"/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>

  <xsl:template match="picture" mode="custom">
    <xsl:if test="$use-picture">
      <xsl:copy>
        <xsl:apply-templates select="node()|@*" mode="custom"/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>

  <xsl:template match="bullet-list" mode="custom">
    <xsl:copy>
      <xsl:for-each select="1 to $tile-count">
        <item>
          <headline>Headline<xsl:text> </xsl:text><xsl:value-of select="position()"/>.<xsl:text> </xsl:text>Aufzählung</headline>
          <body1>
            <paragraph>Lorem ipsum dolor.</paragraph>
          </body1>
          <xsl:choose>
            <xsl:when test="$image-insert = 'image'">
              <picture/>
            </xsl:when>
            <xsl:when test="$image-insert = 'icon'">
              <icon/>
            </xsl:when>
          </xsl:choose>
          <xsl:if test="$use-link">
            <calltoaction-link url="https://savotex.com">Call-to-Action mit Link</calltoaction-link>
          </xsl:if>
        </item>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
