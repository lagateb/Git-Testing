<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:svtx="http://www.savotex.com">

  <!-- root match -->
  <xsl:template match="asset" name="child-media-of-products">
    <query>
    	<or>
    		<condition name="censhare:asset.type" value="layout.*"/>
    		<condition name="censhare:asset.type" value="presentation.*"/>
    	</or>
      <and>
        <relation direction="parent">
          <target>
            <and>
              <condition name="censhare:asset.id" op="=" value="{@id}"/>
            </and>
          </target>
        </relation>
      </and>
      <sortorders>
        <grouping mode="none"/>
        <order ascending="true" by="censhare:asset.name"/>
      </sortorders>
    </query>
  </xsl:template>
</xsl:stylesheet>
