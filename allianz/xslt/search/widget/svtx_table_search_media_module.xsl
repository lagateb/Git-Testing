<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:svtx="http://www.savotex.com">

    <xsl:param name="context-id"/>

    <!-- keine Parameter, da kein Toolbar nötig. Wenn doch, dann aus svtx_table_search_product_module bedienen"-->


    <xsl:function name="svtx:getArticleIDs" as="xs:string*">
        <xsl:choose>
            <xsl:when test="asset/@type = 'presentation.issue.'">
                <xsl:message>==== getArticleIDs presentation</xsl:message>
                <!-- presentation.issue alle-Relationen-Typ Target => Assets Type slide => Alle Relationen Artikel  -->
                <xsl:variable name="ids" select="asset/cs:child-rel()[@key='target.']/cs:asset()[@censhare:asset.type = 'presentation.slide.']/cs:child-rel()[@key='target.']/@id"/>
                <xsl:value-of select="$ids"/>
            </xsl:when>
            <xsl:when test="contains(asset/@type,'layout.')">
                <xsl:message>==== getArticleIDs layout</xsl:message>
                <xsl:variable name="ids" select="asset/cs:child-rel()[@key='actual.']/cs:asset()[@censhare:asset.type = 'text.*']/cs:parent-rel()[@key='user.main-content.']/@id"/>
                <xsl:value-of select="$ids"/>
            </xsl:when>
            <xsl:otherwise> </xsl:otherwise>
        </xsl:choose>


        <!--                                                                                                                     slide -->

    </xsl:function>

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

    <!-- wenn Variante, dann schauen, ob es eine Textvariante gibt, sonst Text Id
                                <child_asset_rel child_asset="32266" child_currversion="0" corpus:dto_flags="t" deletion="0" has_update_child_geometry="0" has_update_content="0" iscancellation="0" isversioned="0" key="variant.1." parent_asset="31778" parent_currversion="0" rowid="46780" sid="78150" variant_automatic="0" variant_update_flag="0">
        <asset_rel_feature asset_rel_sid="78150" corpus:dto_flags="t" feature="svtx:text-variant-type" isversioned="0" party="10" rowid="19619" sid="1900740" timestamp="2021-06-22T06:53:38Z" value_key="sales"/>
      </child_asset_rel>
                               -->
    <xsl:function name="svtx:getVariantID" as="xs:string">
        <xsl:param name="textAsset" as="element(asset)"/>
        <xsl:param name="variantName"/>
        <xsl:variable name="vid" select="$textAsset/child_asset_rel[@key='variant.1.']/asset_rel_feature[@feature='svtx:text-variant-type' and @value_key=$variantName]/../@child_asset" as="xs:string?"/>
        <xsl:choose>
            <xsl:when test="$vid"><xsl:value-of select="$vid"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="$textAsset/@id"/></xsl:otherwise>
        </xsl:choose>
    </xsl:function>




    <xsl:function name="svtx:getFAQTextIDs" as="xs:string*">
        <xsl:param name="pttxIssueAsset" as="element(asset)"/>
        <xsl:variable name="product" as="element(asset)">
            <xsl:choose>
                <xsl:when test="count($pttxIssueAsset/parent_asset_rel[@key='variant.'])>0">
                    <xsl:copy-of select="($pttxIssueAsset/cs:parent-rel()[@key = 'variant.']/cs:parent-rel()[@key = 'user.']/cs:asset()[@censhare:asset.type = 'product.*'])[1]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="($pttxIssueAsset/cs:parent-rel()[@key = 'user.']/cs:asset()[@censhare:asset.type = 'product.*'])[1]"/>
                </xsl:otherwise>
            </xsl:choose>

        </xsl:variable>
        <xsl:variable name="faqArticle" select="($product/cs:child-rel()[@key='user.']/cs:asset()[@censhare:asset.type = 'article.optional-module.faq.'])[1]"/>
        <xsl:if test="$faqArticle">
            <xsl:copy-of select="$faqArticle/cs:child-rel()[@key = 'user.main-content.']/cs:asset()[@censhare:asset.type = 'text.faq.']/asset_feature[@feature='svtx:faq.medium' and @value_asset_id=$pttxIssueAsset/@id]/../@id"/>
        </xsl:if>
    </xsl:function>

    <!--
    <asset_feature asset_id="31818" asset_version="3" corpus:dto_flags="pt" feature="svtx:text-variant-type" isversioned="1" party="10" rowid="1802962" sid="1900799" timestamp="2021-06-21T07:28:00Z" value_key="sales"/>
    -->

    <xsl:function name="svtx:getTextIDs" as="xs:string*">
        <xsl:choose>
            <xsl:when test="asset/@type = 'presentation.issue.'">
                <xsl:message>==== getTextIds presentation</xsl:message>
                <xsl:variable name="textType" select="asset/asset_feature[@feature='svtx:text-variant-type']/@value_key" as="xs:string"/>
                <!-- presentation.issue alle-Relationen-Typ Target => Assets Type slide => Alle Relationen Artikel                                                  Artikel                   Text -->
                <xsl:variable name="ids" as="xs:string*">
                    <xsl:for-each  select="asset/cs:child-rel()[@key='target.']/cs:asset()[@censhare:asset.type = 'presentation.slide.']/cs:child-rel()[@key='target.']/cs:child-rel()[@key='user.main-content.']">
                        <xsl:if test="svtx:isForPPTX(.)">
                            <xsl:value-of select="svtx:getVariantID(.,$textType)"/>
                        </xsl:if>
                    </xsl:for-each>
                    <!-- ggf faq-Texte -->
                    <xsl:copy-of select="svtx:getFAQTextIDs(asset)"/>
                </xsl:variable>
                <xsl:value-of select="$ids"/>
            </xsl:when>
            <xsl:when test="contains(asset/@type,'layout.')">
                <xsl:message>==== getTextIds layout</xsl:message>
                <xsl:variable name="ids" select="asset/cs:child-rel()[@key='actual.']/cs:asset()[@censhare:asset.type = 'text.*']/@id"/>
                <xsl:value-of select="$ids"/>
            </xsl:when>
            <xsl:otherwise> </xsl:otherwise>
        </xsl:choose>


        <!--                                                                                                                     slide -->

    </xsl:function>


    <!-- root match -->
    <xsl:template match="/">
        <xsl:message>==== svtx:table_search_media_module <xsl:value-of select="$context-id"/> </xsl:message>

        <xsl:variable name="partyID" select="system-property('censhare:party-id')"/>
        <xsl:variable name="textIds" select="svtx:getTextIDs()"/>
        <xsl:message>==== svtx:searchmedia asset <xsl:value-of select="asset/@id"/></xsl:message>
        <xsl:message>==== svtx:getallTextIDs <xsl:value-of select="$textIds"/>    </xsl:message>
        <query type="asset" >
            <and>
                <!--
                    <relation direction="parent" >
                        <target>
                            <and>
                                <condition name="censhare:asset.id" op="=" value="{$context-id}"/>
                            </and>
                        </target>
                    </relation>
                    -->

                <condition name="censhare:asset.id" op="in"  value="{string-join($textIds, ' ')}" sepchar=" "/>

            </and>

        </query>

    </xsl:template>
</xsl:stylesheet>
