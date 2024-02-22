<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:svtx="http://www.savotex.com">

  <xsl:param name="context-id"/>

  <xsl:template match="/">
    <query>
      <condition name="censhare:asset.type" value="text.*"/>
      <or>
        <and>
          <condition name="censhare:asset.domain" value="root.allianz-leben-ag.contenthub.public.*"/>
          <condition name="censhare:output-channel" op="NOTNULL"/>
        </and>
        <and>
          <condition name="censhare:asset.wf_id" value="10"/>
          <condition name="censhare:function.workflow-step" value="30"/>
        </and>
      </or>
      <or>
        <relation target="parent" type="user.*">
          <target>
            <condition name="censhare:asset.id" op="=" value="{$context-id}"/>
          </target>
        </relation>
        <relation target="parent" type="variant.*">
          <target>
            <condition name="censhare:asset.type" op="=" value="text.*"/>
            <relation target="parent" type="user.*">
              <target>
                <condition name="censhare:asset.id" op="=" value="{$context-id}"/>
              </target>
            </relation>
          </target>
        </relation>
      </or>

      <sortorders>
        <grouping mode="none"/>
        <order ascending="true" by="censhare:asset.name"/>
      </sortorders>
    </query>
  </xsl:template>
</xsl:stylesheet>
