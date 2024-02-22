<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <!-- parameters -->
  <xsl:param name="context-id"/>
  <xsl:template match="/">
    <xsl:variable name="assetId" select="if ($context-id) then $context-id else asset/@id"/>
    <query type="asset">
      <condition name="svtx:media-channel" op="NOTNULL"/>
      <condition name="censhare:target-group" op="NOTNULL"/>
      <relation target="parent" type="variant.*">
        <target>
          <condition name="svtx:media-channel" op="NOTNULL"/>
          <relation target="parent" type="user.*">
            <target>
              <condition name="censhare:asset.id" op="=" value="{$assetId}"/>
            </target>
          </relation>
        </target>
      </relation>
      <sortorders>
        <grouping mode="none"/>
        <order ascending="true" by="censhare:asset.name"/>
      </sortorders>
    </query>
  </xsl:template>
</xsl:stylesheet>
