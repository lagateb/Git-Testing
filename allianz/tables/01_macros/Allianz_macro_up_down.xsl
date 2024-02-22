<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:csc="http://www.censhare.com/censhare-custom"
                xmlns:svtx="http://www.savotex.com"

                exclude-result-prefixes="cs csc">



  <!-- output -->
  <xsl:output method="xml" omit-xml-declaration="yes" indent="no"/>

  <!-- asset match -->
  <xsl:template match="asset">
      <xsl:message>=== Hallo upDown-zeile</xsl:message>
      <xsl:variable name="time" select="current-time()"/>


    <data>
      <source id="{@id}"   time="{$time}" name="{@name}" type="{@type}" >

      </source>
    </data>

  </xsl:template>

</xsl:stylesheet>
