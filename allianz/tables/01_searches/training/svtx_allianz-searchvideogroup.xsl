<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<!-- Sucht die Startgruppe der Schulungs Videos Ressourcen-Schlüssel svtx:allianz-schulungsvideos
     und holt die erste Eben -->
  <xsl:template match="/">
    <query type="asset" >
      <condition name="censhare:asset.type" value="video.*" />
      <relation target="parent" type="user.*">
        <target>
          <condition name="censhare:resource-key" value="svtx:allianz-schulungsvideos"/>
        </target>
      </relation>
    </query>
  </xsl:template>
</xsl:stylesheet>
