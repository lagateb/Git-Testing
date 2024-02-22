<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:svtx="http://www.savotex.com"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="#all">

  <xsl:template match="/asset">
    <cs:command name="com.censhare.api.assetmanagement.Update">
      <cs:param name="source">
        <asset domain="root.allianz-leben-ag.archive.">
          <xsl:copy-of select="@* except @domain"/>
          <xsl:copy-of select="node()"/>
        </asset>
      </cs:param>
    </cs:command>
  </xsl:template>
</xsl:stylesheet>