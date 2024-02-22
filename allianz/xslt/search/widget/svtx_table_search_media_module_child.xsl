<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:svtx="http://www.savotex.com">

    <!-- sucht die Texte, die zum Medium gehören -->
    <xsl:param name="context-id"/>



    <xsl:function name="svtx:getTextIDs" as="xs:string*">
        <xsl:choose>
            <xsl:when test="asset/@type = 'presentation.issue.'">
                <xsl:message>==== getArticleIDs presentation</xsl:message>
                <!-- presentation.issue alle-Relationen-Typ Target => Assets Type slide => Alle Relationen Artikel  -->
                <xsl:variable name="ids" select="asset/cs:child-rel()[@key='target.']/cs:asset()[@censhare:asset.type = 'presentation.slide.']/cs:child-rel()[@key='target.']/@id"/>
                <xsl:value-of select="$ids"/>
            </xsl:when>
            <xsl:when test="contains(asset/@type,'layout.')">
                <xsl:message>==== getArticleIDs layout</xsl:message>
                <xsl:variable name="ids" select="asset/cs:child-rel()[@key='actual.']/cs:asset()[@censhare:asset.type = 'text.*']/@id"/>
                <xsl:value-of select="$ids"/>
            </xsl:when>
            <xsl:otherwise> </xsl:otherwise>
        </xsl:choose>


        <!--                                                                                                                     slide -->

    </xsl:function>



    <!-- root match -->
    <xsl:template match="/">

        <xsl:variable name="partyID" select="system-property('censhare:party-id')"/>
        <message>==== svtx:table_search_media_module_childs <xsl:value-of select="$context-id"/> </message>
        <message>==== asset svtx:table_search_media_module_childs <xsl:value-of select="asset/@id"/> </message>

        <query type="asset" >
<and>
            <condition name="censhare:asset.type" value="text.*" />
    <relation direction="parent" >
        <target>
            <and>
                <condition name="censhare:asset.id" op="=" value="1"/>
            </and>
        </target>
    </relation>
<!--
    <condition name="censhare:asset.type" op="=" value="text.*"/>
-->
</and>
            <sortorders>
                <grouping mode="none"/>
                <!--
                 <order by="censhare:asset.id"/>
                <order by="censhare:asset.type"/>
                -->
            </sortorders>
        </query>

    </xsl:template>
</xsl:stylesheet>
