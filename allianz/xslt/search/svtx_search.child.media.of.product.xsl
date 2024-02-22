<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:svtx="http://www.savotex.com">

  <!-- root match -->
  <xsl:template match="asset" name="child-media-of-products">
    <query>
        <and>
          <condition name="censhare:asset.type" value="presentation.slide.*"/>
          <relation direction="parent">
            <target>
                <condition name="censhare:asset.id" op="=" value="{@id}"/>

            </target>


          </relation>
        </and>
      <sortorders>
          <!-- parent_asset_rel  key="target." sorting="24" -->
        <grouping mode="none"/>

      </sortorders>
    </query>
  </xsl:template>
</xsl:stylesheet>
