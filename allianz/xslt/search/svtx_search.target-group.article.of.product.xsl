<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <!-- parameters -->
  <xsl:param name="context-id"/>

  <xsl:template match="/">
    <xsl:variable name="assetId" select="if ($context-id) then $context-id else asset/@id"/>
    <query type="asset">
      <condition name="censhare:asset.type" value="article.*"/>
      <condition name="censhare:asset-flag" op="ISNULL"/>
      <condition name="censhare:target-group" op="NOTNULL"/>
      <relation target="parent" type="variant.*">
        <target>
          <condition name="censhare:asset.type" value="article.*"/>
          <relation target="parent" type="user.*">
            <target>
              <condition name="censhare:asset.id" value="{$assetId}"/>
            </target>
          </relation>
        </target>
      </relation>
    </query>
  </xsl:template>

</xsl:stylesheet>
