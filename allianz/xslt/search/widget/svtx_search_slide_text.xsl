<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:svtx="http://www.savotex.com">

    <xsl:param name="context-id"/>


    <xsl:function name="svtx:isForPPTX" as="xs:boolean">
        <xsl:param name="textAsset" as="element(asset)" />
        <xsl:variable name="article" select="($textAsset/cs:parent-rel()[@key = 'user.main-content.']/cs:asset()[@censhare:asset.type = 'article.*'])[1]" as="element(asset)?"/>
        <xsl:variable name="pptx" select="($article/cs:parent-rel()[@key = 'target.']/cs:asset()[@censhare:asset.type = 'presentation.slide.'])[1]" as="element(asset)?"/>
        <xsl:variable name="textCount" select="count($article/child_asset_rel[@key='user.main-content.'])"/>
        <!-- asset_feature  feature="svtx:text-size" value_key="size-s"      type="text.size-s." -->
        <xsl:choose>
            <xsl:when test="not($pptx)"><xsl:value-of select="false()"/></xsl:when>
            <xsl:when test="$textCount=1"><xsl:value-of select="true()"/></xsl:when>
            <xsl:otherwise>
                <xsl:variable name="size" select="$pptx/asset_feature[@feature='svtx:text-size']/@value_key"/>
                <xsl:value-of select="if (($size) and contains($textAsset/@type,$size)) then true() else false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="svtx:getTextIDs" as="xs:string*">
        <xsl:message>==== svtx:textIds <xsl:copy-of select="asset/cs:child-rel()[@key='target.']"/>    </xsl:message>
        <xsl:choose>
            <xsl:when test="asset/@type = 'presentation.slide.'">
                <xsl:message>==== getTextId presentation slide</xsl:message>
                <xsl:variable name="ids" as="xs:string*">
                    <xsl:for-each  select="asset/cs:child-rel()[@key='target.']/cs:child-rel()[@key='user.main-content.']">
                        <xsl:if test="svtx:isForPPTX(.)">
                            <xsl:value-of select="@id"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:value-of select="$ids"/>
            </xsl:when>
            <xsl:otherwise> </xsl:otherwise>
        </xsl:choose>


        <!--                                                                                                                     slide -->

    </xsl:function>


    <!-- root match -->
    <xsl:template match="/">
        <xsl:message>==== svtx:table_search_slide_text<xsl:value-of select="$context-id"/> </xsl:message>

        <xsl:variable name="textIds" select="svtx:getTextIDs()"/>
        <xsl:message>==== svtx:textIds <xsl:value-of select="$textIds"/>    </xsl:message>
        <xsl:message>==== svtx:searchmedia asset <xsl:value-of select="asset/@id"/></xsl:message>
        <query type="asset" >
            <and>
                <condition name="censhare:asset.id" op="in"  value="{string-join($textIds, ' ')}" sepchar=" "/>
                <!--31162
                    <condition name="censhare:asset.type" op="=" value="presentation.slide."/>
                -->

            </and>


        </query>

    </xsl:template>
</xsl:stylesheet>
