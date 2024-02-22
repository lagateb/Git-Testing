<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:svtx="http://www.savotex.com">
    <xsl:param name="context-id"/>


    <xsl:function name="svtx:getallTargetGroupTextChilds" as="xs:string*">
        <!--<xsl:param name="cid"/> -->
        <xsl:if test="starts-with(asset/@type, 'article.')">
            <xsl:variable name="ids"
                          select="asset/cs:child-rel()[@key='variant.']/cs:asset()[@censhare:asset.type = 'article.*']/@id"/>
            <xsl:message>==== svtx:getallTextChilds
                <xsl:value-of select="$ids"/>
            </xsl:message>
            <xsl:value-of select="$ids"/>
        </xsl:if>
        <xsl:message>==== svtx:getallTextChilds Nicht fuer den Typ</xsl:message>
    </xsl:function>

    <xsl:function name="svtx:getAllTextVariants" as="xs:string*">
        <!-- article->text->variant.1.->text->id -->
        <xsl:variable name="ids" select="asset/cs:child-rel()[@key='user.main-content.']/cs:asset()[@censhare:asset.type = 'text.*']/cs:child-rel()[@key='variant.1.']/cs:asset()[@censhare:asset.type = 'text.*']/@id"/>
        <xsl:message>=== getAllTextVariants<xsl:value-of select="$ids"/></xsl:message>
        <xsl:value-of select="$ids"/>
    </xsl:function>

    <!-- root match -->
    <xsl:template match="/">
        <xsl:message>==== svtx:table_search_article_text_childs
            <xsl:value-of select="$context-id"/>
        </xsl:message>
        <xsl:message>==== svtx:table_search_article_text_childsasset
            <xsl:value-of select="/asset/@id"/>
        </xsl:message>
        <xsl:variable name="partyID" select="system-property('censhare:party-id')"/>
        <xsl:variable name="targetGroupTextIds" select="svtx:getallTargetGroupTextChilds()"/>
        <xsl:variable name="textVariantsIds" select="svtx:getAllTextVariants()"/>


        <query type="asset">
            <xsl:if test="starts-with(asset/@type, 'article.')">
                <xsl:message>==== wir bauen query</xsl:message>
                <and>
                    <condition name="censhare:asset.type" value="text.*"/>
                    <condition name="censhare:asset.domain" op="!=" value="root.allianz-leben-ag.contenthub.public."/>
                    <or>
                        <relation direction="parent" type="user.main-content.">
                            <target>
                                <or>
                                    <condition name="censhare:asset.id" op="=" value="{$context-id}"/>
                                </or>
                            </target>
                        </relation>

                        <xsl:if test="$targetGroupTextIds">
                            <xsl:message>==== variantIds Suche
                                <xsl:value-of select="$targetGroupTextIds"/>
                            </xsl:message>
                            <relation direction="parent" type="user.main-content.">
                                <target>
                                    <and>
                                        <condition name="censhare:asset.id" op="IN"
                                                   value="{string-join($targetGroupTextIds, ' ')}" sepchar=" "/>
                                    </and>
                                </target>
                            </relation>
                        </xsl:if>

                        <xsl:if test="$textVariantsIds">
                            <xsl:message>==== textVariantsIds Suche
                                <xsl:value-of select="$textVariantsIds"/>
                            </xsl:message>
                                        <condition name="censhare:asset.id" op="IN"
                                                   value="{string-join($textVariantsIds, ' ')}" sepchar=" "/>

                        </xsl:if>

                    </or>

                </and>
                <sortorders>
                    <grouping mode="none"/>
                    <!--
                     <order by="censhare:asset.id"/>
                    <order by="censhare:asset.type"/>
                    -->
                </sortorders>
            </xsl:if>
        </query>

    </xsl:template>
</xsl:stylesheet>
