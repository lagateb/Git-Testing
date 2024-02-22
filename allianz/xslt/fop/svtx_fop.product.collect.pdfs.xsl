<?xml version="1.0" ?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:xe="http://www.censhare.com/xml/3.0.0/xmleditor"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:svtx="http://www.savotex.com"
                xmlns:my="http://www.censhare.com">

  <xsl:output method="xml" indent="yes" omit-xml-declaration="no" encoding="UTF-8"/>

  <!-- parameter -->
  <xsl:param name="transform"/>

  <xsl:variable name="rootAsset" select="asset[1]" as="element(asset)?"/>

  <xsl:template match="/asset[starts-with(@type, 'product.')]">
    <xsl:variable name="article" select="$rootAsset/cs:child-rel()[@key='user.']/cs:asset()[@censhare:asset.type='article.*']" as="element(asset)*"/>

    <!-- maybe filter by wf -->
    <xsl:for-each select="$article/cs:child-rel()[@key='user.main-content.']">
      <cs:command name="com.censhare.api.event.Send">
        <cs:param name="source">
          <event target="CustomAssetEvent" param2="0" param1="1" param0="{@id}" method="svtx-text-create-pdf"/>
        </cs:param>
      </cs:command>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>







