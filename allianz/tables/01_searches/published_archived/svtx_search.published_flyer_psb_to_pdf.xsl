<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:svtx="http://www.savotex.com">
   <xsl:param name="context-id"/>

  <!-- root match zeigt alle root.allianz-leben-ag.contenthub.public. des layouts-->

  <xsl:template match="/" name="published-media">
    <query>
        <and>
            <or>
            <condition name="censhare:asset.type" value="document.flyer.*"/>
            <condition name="censhare:asset.type" value="document.psb.*"/>
            </or>
            <!-- user.publication. -->
            <relation direction="parent">
                <target>
                    <and>
                        <condition name="censhare:asset.id" op="=" value="{$context-id}"/>
                    </and>
                </target>
            </relation>
            <condition name="censhare:asset.domain" op="=" value="root.allianz-leben-ag.contenthub.public."/>
        </and>
      <sortorders>
        <grouping mode="none"/>
        <order ascending="true" by="censhare:asset.type"/>
        <order ascending="true" by="censhare:asset.name"/>
      </sortorders>
    </query>
  </xsl:template>
</xsl:stylesheet>
