<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <!-- parameters -->
  <xsl:param name="context-id"/>

  <xsl:template match="/">
    <query type="asset">
      <condition name="censhare:asset.type" value="text.public.*"/>
      <or>
        <relation target="parent" type="user.web-usage.">
          <target>
            <condition name="censhare:asset.type" value="article.*"/>
            <relation target="child" type="user.main-content.">
              <target>
                <condition name="censhare:asset.id" value="{$context-id}"/>
              </target>
            </relation>
          </target>
        </relation>
        <relation target="parent" type="user.web-usage.">
          <target>
            <condition name="censhare:asset.type" value="article.*"/>
            <relation target="child" type="user.main-content.*">
              <target>
                <condition name="censhare:asset.type" value="text.*"/>
                <relation target="child" type="variant.1.">
                  <target>
                    <condition name="censhare:asset.id" value="{$context-id}"/>
                  </target>
                </relation>
              </target>
            </relation>
          </target>
        </relation>
      </or>
      <not>
        <condition name="censhare:asset.domain" value="root.allianz-leben-ag.archive.*"/>
      </not>
      <sortorders>
        <grouping mode="none"/>
        <order ascending="true" by="censhare:asset.name"/>
      </sortorders>
    </query>
  </xsl:template>

</xsl:stylesheet>
