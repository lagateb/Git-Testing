<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:svtx="http://www.savotex.com">
    <xsl:param name="context-id"/>



    <!-- root match -->
    <xsl:template match="/">
        <xsl:message>==== svtx:table_search_article_text_child_child_dummy <xsl:value-of select="$context-id"/> </xsl:message>

        <query type="asset">
            <condition name="censhare:asset.id" op="=" value="-1"/>
        </query>

    </xsl:template>
</xsl:stylesheet>
