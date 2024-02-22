<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:svtx="http://www.savotex.com">

  <!-- root match -->
  <xsl:template match="/">
    <xsl:variable name="partyId" select="system-property('censhare:party-id')"/>
    <query>
      <and>
        <condition name="censhare:asset.type" value="text.*"/>
        <condition name="censhare:asset-flag" op="!=" value="is-template"/>
        <condition name="censhare:asset.created_by" value="{$partyId}"/>
        <relation direction="parent" type="user.main-content.">
          <target>
            <and>
              <condition name="censhare:asset-flag" op="!=" value="is-template"/>
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
