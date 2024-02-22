<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:svtx="http://www.savotex.com">

  <!-- root match zeigt alle root.allianz-leben-ag.contenthub.public.-->
  <xsl:template match="/" name="child-none">
      <query>
          <condition name="censhare:asset.id" op="=" value="-3"/>
          <sortorders>
              <grouping mode="none"/>
              <order ascending="true" by="censhare:asset.name"/>
          </sortorders>
      </query>
  </xsl:template>
</xsl:stylesheet>
