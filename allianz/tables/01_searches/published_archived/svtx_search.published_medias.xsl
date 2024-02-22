<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:svtx="http://www.savotex.com">



    <xsl:param name="filterProductName" select="'all'" as="xs:string"/>
    <xsl:param name="assetType" select="'all'"/>
    <xsl:param name="assetUsage" select="'all'"/>

    <xsl:param name="filterDomain" select="'root.allianz-leben-ag.contenthub.public.'" as="xs:string"/>
    <xsl:param name="filterOnlyPlayground" select="'false'"/>
    <xsl:param name="playgroundFilter" select="'both'"/>


    <xsl:function name="svtx:getIds">
        <xsl:param name="productName"  as="xs:string"/>
        <xsl:variable name="ids" select="(cs:asset()[@censhare:asset.domain=$filterDomain and  (@censhare:asset.type = 'presentation.*' or @censhare:asset.type = 'document.flyer.*'
        or @censhare:asset.type = 'document.psb.*' or @censhare:asset.type = 'text.public.*' )])
       /asset_feature[@feature='svtx:product-name' and @value_string=$productName ]/@asset_id"/>
        <xsl:copy-of select="$ids"/>
    </xsl:function>


    <!-- root match zeigt alle root.allianz-leben-ag.contenthub.public.-->
    <xsl:template match="/" name="published-media">
        <query>
            <or>
                <and>
                    <condition name="censhare:asset.type" value="article.*"/>
                    <condition name="censhare:asset-flag" op="ISNULL"/>
                    <or>
                        <relation direction="parent">
                            <target>
                                <and>
                                    <condition name="censhare:asset.type" value="product.*"/>
                                    <xsl:if test="$filterProductName !=  'all'">
                                        <condition name="censhare:asset.name" op="LIKE"  value="{$filterProductName}"/>
                                    </xsl:if>
                                </and>
                            </target>
                        </relation>
                        <relation direction="parent" type="variant.">
                            <target>
                                <and>
                                    <condition name="censhare:asset.type" value="article.*"/>
                                    <!--<condition name="censhare:target-group" op="NOTNULL"/>-->
                                    <relation direction="parent">
                                        <target>
                                            <and>
                                                <condition name="censhare:asset.type" value="product.*"/>
                                                <xsl:if test="$filterProductName !=  'all'">
                                                    <condition name="censhare:asset.name" op="LIKE"  value="{$filterProductName}"/>
                                                </xsl:if>
                                            </and>
                                        </target>
                                    </relation>
                                </and>
                            </target>
                        </relation>
                    </or>
                    <or>
                        <!-- texts -->
                        <relation direction="child" type="user.web-usage.">
                            <target>
                                <and>
                                    <condition name="censhare:asset.domain" op="=" value="{$filterDomain}"/>

                                    <xsl:choose>
                                        <xsl:when test="$assetUsage = 'bs'">
                                            <condition name="censhare:output-channel" value="root.web.bs."/>
                                        </xsl:when>
                                        <xsl:when test="$assetUsage = 'vp'">
                                            <condition name="censhare:output-channel" value="root.web.aem.aem-vp."/>
                                        </xsl:when>
                                        <xsl:when test="$assetUsage = 'az'">
                                            <condition name="censhare:output-channel" value="root.web.aem.aem-azde."/>
                                        </xsl:when>
                                        <xsl:when test="$assetUsage = ('pptx','flyer','psb')">
                                            <condition name="censhare:asset.id" value="-1"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <condition name="censhare:output-channel" op="NOTNULL"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </and>
                            </target>
                        </relation>
                        <!-- layout -->
                        <relation direction="child" type="user.main-content.">
                            <target>
                                <condition name="censhare:asset.type" op="=" value="text.*"/>
                                <relation direction="parent">
                                    <target>
                                        <condition name="censhare:asset.type" op="=" value="layout.*"/>
                                        <condition name="censhare:asset.wf_id" value="80"/>
                                        <or>
                                            <condition name="censhare:function.workflow-step" value="30"/>
                                            <condition name="censhare:function.workflow-step" value="60"/>
                                            <condition name="censhare:function.workflow-step" value="55"/>
                                            <condition name="censhare:function.workflow-step" value="90"/>
                                        </or>
                                        <xsl:choose>
                                            <xsl:when test="$assetUsage = 'flyer'">
                                                <condition name="svtx:layout-template-resource-key" value="svtx:indd.template.flyer.allianz"/>
                                            </xsl:when>
                                            <xsl:when test="$assetUsage = 'psb'">
                                                <condition name="svtx:layout-template-resource-key" value="svtx:indd.template.twopager.allianz"/>
                                            </xsl:when>
                                            <xsl:when test="$assetUsage = ('az','vp','bs','pptx')">
                                                <condition name="censhare:asset.id" value="-1"/>
                                            </xsl:when>
                                        </xsl:choose>
                                    </target>
                                </relation>
                            </target>
                        </relation>
                        <!-- PPTX SLIDE -->
                        <relation direction="parent" type="target.">
                            <target>
                                <condition name="censhare:asset.type" op="=" value="presentation.slide.*"/>
                                <relation direction="parent" type="target.">
                                    <target>
                                        <condition name="censhare:asset.type" op="=" value="presentation.issue.*"/>
                                        <condition name="censhare:asset.wf_id" value="80"/>
                                        <or>
                                            <condition name="censhare:function.workflow-step" value="30"/>
                                            <condition name="censhare:function.workflow-step" value="60"/>
                                            <condition name="censhare:function.workflow-step" value="55"/>
                                            <condition name="censhare:function.workflow-step" value="90"/>
                                        </or>
                                        <xsl:if test="$assetUsage = ('flyer','psb','az','vp','bs')">
                                            <condition name="censhare:asset.id" value="-1"/>
                                        </xsl:if>
                                    </target>
                                </relation>
                            </target>
                        </relation>
                    </or>
                </and>
                <and>
                    <condition name="censhare:asset.domain" value="root.allianz-leben-ag.contenthub.public."/>
                    <or>
                        <xsl:choose>
                            <xsl:when test="$assetUsage = 'all'">
                                <condition name="censhare:asset.type" value="document.flyer.*"/>
                                <condition name="censhare:asset.type" value="document.psb.*"/>
                                <condition name="censhare:asset.type" value="presentation."/>
                            </xsl:when>
                            <xsl:when test="$assetUsage = 'flyer'">
                                <condition name="censhare:asset.type" value="document.flyer.*"/>
                            </xsl:when>
                            <xsl:when test="$assetUsage = 'psb'">
                                <condition name="censhare:asset.type" value="document.psb.*"/>
                            </xsl:when>
                            <xsl:when test="$assetUsage = 'pptx'">
                                <condition name="censhare:asset.type" value="presentation."/>
                            </xsl:when>
                            <xsl:otherwise>
                                <condition name="censhare:asset.id" value="-1"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </or>
                    <xsl:if test="$filterProductName !=  'all'">
                        <or>
                            <relation direction="parent">
                                <target>
                                    <and>
                                        <or>
                                            <condition name="censhare:asset.type" value="layout.*"/>
                                            <condition name="censhare:asset.type" value="presentation.*"/>
                                        </or>
                                        <relation direction="parent">
                                            <target>
                                                <and>
                                                    <condition name="censhare:asset.type" value="product.*"/>
                                                    <condition name="censhare:asset.name" op="LIKE"  value="{$filterProductName}"/>
                                                </and>
                                            </target>
                                        </relation>
                                    </and>
                                </target>
                            </relation>

                        </or>
                    </xsl:if>
                </and>
            </or>


            <sortorders>
                <grouping mode="none"/>
                <order ascending="false" by="censhare:storage_item.mimetype"/>
                <order ascending="true" by="censhare:asset.name"/>
            </sortorders>
        </query>


        <!--<query>
            <and>
                <or>

                    <condition name="censhare:asset.type" value="layout.*"/>
                    <condition name="censhare:asset.type" value="text.public.*"/>
                </or>
                <xsl:if test="$assetType !=  'all'">
                    <condition name="censhare:asset.type" op="=" value="{$assetType}"/>
                </xsl:if>
                <xsl:if test="$filterProductName !=  'all'">
                    <xsl:variable name="ids" select="svtx:getIds($filterProductName)"/>
                    <condition name="censhare:asset.id" op="IN"  value="{string-join($ids, ' ')}" sepchar=" "/>
                </xsl:if>
                <condition name="censhare:asset.domain" op="=" value="{$filterDomain}"/>
                <xsl:choose>
                    <xsl:when test="$playgroundFilter = 'only_playground'">
                        <relation direction="parent">
                            <target>
                                <and>
                                    <or>
                                        <condition name="censhare:asset.domain" op="=" value="root.allianz-leben-ag.contenthub.playground.*"/>
                                        <condition name="censhare:asset.domain" op="=" value="root.allianz-leben-ag.contenthub.playground-sach.*"/>
                                    </or>
                                </and>
                            </target>
                        </relation>
                    </xsl:when>
                    <xsl:when test="$playgroundFilter = 'only_live'">
                        <not>
                            <relation direction="parent">
                                <target>
                                    <and>
                                        <or>
                                            <condition name="censhare:asset.domain" op="=" value="root.allianz-leben-ag.contenthub.playground.*"/>
                                            <condition name="censhare:asset.domain" op="=" value="root.allianz-leben-ag.contenthub.playground-sach.*"/>
                                        </or>
                                    </and>
                                </target>
                            </relation>
                        </not>
                    </xsl:when>
                    <xsl:when test="$playgroundFilter = 'both'">
                        &lt;!&ndash; do nothing ? &ndash;&gt;
                    </xsl:when>
                </xsl:choose>
            </and>
            <sortorders>
                <grouping mode="none"/>
                <order ascending="true" by="censhare:asset.type"/>
                <order ascending="true" by="censhare:asset.name"/>
            </sortorders>
        </query>-->
    </xsl:template>
</xsl:stylesheet>
