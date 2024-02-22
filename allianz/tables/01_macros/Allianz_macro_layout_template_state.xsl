<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:csc="http://www.censhare.com/censhare-custom"
                xmlns:svtx="http://www.savotex.com"

                exclude-result-prefixes="cs csc">

  <xsl:include href="censhare:///service/assets/asset;censhare:resource-key=svtx:xslt.lib.template.history/storage/master/file"/>

  <!-- output -->
  <xsl:output method="xml" omit-xml-declaration="yes" indent="no"/>

  <!-- asset match -->
  <xsl:template match="asset">
    <xsl:variable name="templateStateInformation" select="svtx:get-template-state-of-asset(.)"/>

    <xsl:variable name="templateState">
      <xsl:choose>
        <xsl:when test="exists($templateStateInformation//*[@state='updated-template'])">
          <xsl:value-of select="'updated-template'"/>
        </xsl:when>
        <xsl:when test="exists($templateStateInformation//*[@state='new-template'])">
          <xsl:value-of select="'new-template'"/>
        </xsl:when>
        <xsl:when test="exists($templateStateInformation//*[@state='ok'])">
          <xsl:value-of select="'ok'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'unknown'"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <data>
      <source id="{@id}" name="{@name}" type="{@type}" state="{$templateState}" history="{string-join($templateStateInformation//@history, '&#10;&#13;')}">
        <xsl:if test="@type = 'presentation.issue.'">
          <xsl:for-each select="$templateStateInformation/media">
            <xsl:if test="not(@state = 'ok')">
              <slide><xsl:value-of select="@id"/></slide>
            </xsl:if>
          </xsl:for-each>
        </xsl:if>
      </source>
    </data>

  </xsl:template>

</xsl:stylesheet>
