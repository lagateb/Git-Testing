<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:svtx="http://www.savotex.com">

  <!-- root match -->
  <xsl:template match="asset" name="media-of-products">
    <query>
        <and>
          <or>
              <condition name="censhare:asset.type" value="layout.*"/>
              <condition name="censhare:asset.type" value="presentation.*"/>
          </or>
          <or>
            <relation direction="parent">
              <target>
                  <condition name="censhare:asset.id" op="=" value="{@id}"/>
              </target>
            </relation>
            <relation direction="parent" type="variant.*">
              <target>
                <or>
                  <condition name="censhare:asset.type" value="layout.*"/>
                  <condition name="censhare:asset.type" value="presentation.*"/>
                  <condition name="censhare:asset.type" value="extended-media.html.*"/>
                </or>
                <relation direction="parent">
                  <target>
                    <condition name="censhare:asset.id" op="=" value="{@id}"/>
                  </target>
                </relation>
              </target>
            </relation>
          </or>
        </and>
      <sortorders>
        <grouping mode="none"/>
        <order ascending="true" by="censhare:asset.name"/>
      </sortorders>
    </query>
  </xsl:template>
</xsl:stylesheet>
