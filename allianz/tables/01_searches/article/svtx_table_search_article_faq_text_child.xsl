<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:svtx="http://www.savotex.com">
    <xsl:param name="context-id" select="1"/>
    <!-- root match -->
    <xsl:template match="/">
        <query type="asset">
                <and>
                    <condition name="censhare:asset.type" value="nixda"/>

                    <relation direction="parent" type="user.main-content.">
                        <target>
                                <condition name="censhare:asset.id" op="=" value="{$context-id}"/>
                        </target>
                    </relation>
                </and>
        </query>
    </xsl:template>
</xsl:stylesheet>
